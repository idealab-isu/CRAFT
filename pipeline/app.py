"""
CRAFT - Unified Text-to-CAD Pipeline

**CRAFT v3** (``CRAFT_VERSION=3``): after baseline plan→compile→render, runs an
intent sketch (if needed), six ortho renders, one structured gap analysis vs
text/sketch, then a single text-only OpenSCAD patch. Replaces the multi-iterate
VLM self-correction loop. Still gated by ``USE_VLM_CORRECTION`` (treat it as
“post-render visual refinement enabled”).

Main Flask application providing:
- Text input → CAD generation
- Vision input → Caption → CAD generation
- Automatic validation and repair
- Manual refinement with user hints
- KB-augmented generation for accurate component reproduction (NopSCADlib)

Routes:
- GET  /           : Main UI
- POST /generate   : Text-to-CAD generation
- POST /vision     : Vision-to-CAD generation
- POST /repair     : Manual repair with hint
- GET  /download/* : Download generated files
- GET  /kb/status  : Knowledge base status
- POST /kb/search  : Search knowledge base
"""

import os
import json
import secrets
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional, List

from flask import Flask, render_template, request, jsonify, send_from_directory, session, Response
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
from openai import OpenAI
from queue import Queue

# Import CRAFT modules
from core.progress import ProgressTracker, PipelineStage, create_sse_progress_handler
from core.schema import validate_plan, postprocess_plan
from core.reasoner import TextReasoner, DesignBrief, KBComponentContext
from core.vision import (
    VisionAnalyzer,
    vision_to_design_brief,
    DEFAULT_VIEW_NAMES,
    SingleImageAnalyzer,
    SingleImageAnalysis,
    single_image_to_design_brief,
    SINGLE_IMAGE_MODEL
)
from core.planner import Planner, PlanResult
from core.compiler import Compiler, strip_to_scad
from core.render_checks import Validator, ValidationResult, validate_scad
# core.repair was removed in CRAFT v2 — manual repair is now handled by the
# Phase B unified-feedback stage; the /repair endpoint below returns HTTP 410.
from core.llm_client import create_unified_client
from core.visual_corrector import VisualSelfCorrector, VisualCorrectionResult, VLMAssessment
from core.component_verifier import ComponentVerifier, ComponentVerificationOutput
from core.gap_refiner import GapRefiner
# CRAFT v2.1: PromptEnhancer removed from the live pipeline — it was a silent
# prompt rewriter that could shift user intent and double the upfront latency
# for little measured win. Detection bundle is still shared with the reasoner.
from core.sketch_generator import (
    SketchGenerator,
    SketchResult,
    SKETCH_ENABLED_DEFAULT,
    SKETCH_MODE_DEFAULT,
    sketch_from_design_brief,
)
from core.scad_autofix import preemptive_render_safety_fix

from utils.openscad_runner import OpenScadRunner, RenderMode, export_stl
from utils.parameter_parser import (
    parse_parameters_from_scad,
    parameters_to_dict,
    update_multiple_parameters,
    categorize_parameters_with_llm
)

# Import KB modules (optional - gracefully handle if not ready)
try:
    from kb import (
        is_kb_ready,
        get_kb_status,
        detect_components,
        retrieve_components,
        get_retriever,
        VisualVerifier,
        get_component_images,
        KB_CONFIG
    )
    KB_AVAILABLE = True
except ImportError:
    KB_AVAILABLE = False
    print("KB module not available - running without knowledge base")


# =============================================================================
# CONFIGURATION
# =============================================================================

load_dotenv()

def load_keys(json_path: str = "keys.json") -> dict:
    """Load API keys from JSON file."""
    try:
        with open(json_path, "r", encoding="utf-8") as f:
            keys_data = json.load(f)
    except FileNotFoundError:
        keys_data = {}

    if "gpt" in keys_data and not os.getenv("OPENAI_API_KEY"):
        os.environ["OPENAI_API_KEY"] = keys_data["gpt"]

    if "gemini" in keys_data and not os.getenv("GEMINI_API_KEY"):
        os.environ["GEMINI_API_KEY"] = keys_data["gemini"]

    return keys_data

load_keys()

# Initialize OpenAI client
openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Initialize unified LLM client (supports OpenAI and Gemini)
client = create_unified_client(
    openai_client=openai_client,
    gemini_api_key=os.getenv("GEMINI_API_KEY")
)

# Model configuration
MODEL_PRIMARY = os.getenv("MODEL_PRIMARY", "gpt-4o")
MODEL_SECONDARY = os.getenv("MODEL_SECONDARY", "gpt-4o")

# CRAFT v2.1 model configuration
# - MODEL_REASONING drives every critical reasoning stage: reasoner, planner,
#   compiler, VLM self-correction, component verification. Keeping them on the
#   same model family eliminates the "5.2-planned-but-4o-compiled" mismatch
#   that produced SCAD which technically matched the plan but visually didn't.
# - MODEL_FAST is only used for non-critical, deterministic-ish side tasks
#   (single-image captioning fallback, parameter categorization for the UI).
MODEL_REASONING = os.getenv("MODEL_REASONING", "gpt-5.2")
MODEL_FAST = os.getenv("MODEL_FAST", "gpt-4o")

# Back-compat aliases — existing call sites reference MODEL_PIPELINE / MODEL_VLM.
MODEL_PIPELINE = MODEL_REASONING   # compiler / vision analyzer / enhancer → now 5.2
MODEL_VLM = MODEL_REASONING        # VLM / component verifier / reasoner / planner

# Supported models (for backward compatibility)
SUPPORTED_MODELS = [
    "gpt-4o",
    "gpt-5.1",
    "gpt-5.2",
    "gemini-2.0-flash",
    "gemini-2.5-flash",
    "gemini-3-pro-preview"
]

# Pipeline settings
MAX_PLAN_ATTEMPTS = int(os.getenv("MAX_PLAN_ATTEMPTS", "2"))
MAX_REPAIR_ATTEMPTS = int(os.getenv("MAX_REPAIR_ATTEMPTS", "2"))
AUTO_REPAIR = os.getenv("AUTO_REPAIR", "true").lower() == "true"
PASS_THRESHOLD = float(os.getenv("PASS_THRESHOLD", "0.80"))

# VLM Self-Correction settings
# Default 1: one assess + fix pass; visual_corrector still tracks best candidate
# if MAX_VLM_ITERATIONS is raised via env. Same rollback semantics as v2.1.
MAX_VLM_ITERATIONS = int(os.getenv("MAX_VLM_ITERATIONS", "1"))
USE_VLM_CORRECTION = os.getenv("USE_VLM_CORRECTION", "true").lower() == "true"

# CRAFT v3 — baseline → intent sketch + ortho renders → gap JSON → single patch
# (replaces the multi-iterate VLM loop when CRAFT_VERSION=3)
CRAFT_VERSION = os.getenv("CRAFT_VERSION", "2").strip().lower()

# Component Verification settings (runs after VLM correction)
MAX_COMPONENT_ITERATIONS = int(os.getenv("MAX_COMPONENT_ITERATIONS", "1"))
USE_COMPONENT_VERIFICATION = os.getenv("USE_COMPONENT_VERIFICATION", "true").lower() == "true"
# Only run component verification if VLM confidence < threshold or match != "good"
COMPONENT_VERIFY_THRESHOLD = float(os.getenv("COMPONENT_VERIFY_THRESHOLD", "0.95"))

# Image settings
IMG_SIZE = (800, 600)

# Directories
SCAD_DIR = "scad_scripts"
PLAN_DIR = "plans"
IMAGE_DIR = os.path.join("static", "images")
STL_DIR = os.path.join("static", "stl")
UPLOAD_DIR = os.path.join("tmp_views")


# =============================================================================
# PIPELINE STATE
# =============================================================================

class PipelineState:
    """
    Tracks state through the pipeline.

    This unified state object flows through all stages.
    """

    def __init__(
        self,
        input_type: str = "text",
        original_input: Any = None
    ):
        # Input
        self.input_type = input_type  # "text" or "vision"
        self.original_input = original_input

        # Understanding stage
        self.design_brief: Optional[DesignBrief] = None
        self.captions: Optional[Dict[str, Any]] = None  # Vision only

        # Planning stage
        self.plan: Optional[Dict[str, Any]] = None
        self.plan_valid: bool = False
        self.plan_error: Optional[str] = None
        self.plan_attempts: int = 0

        # Compilation stage
        self.scad_code: Optional[str] = None

        # Validation stage
        self.validation: Optional[ValidationResult] = None
        self.repair_attempts: int = 0

        # Output
        self.scad_path: Optional[str] = None
        self.image_path: Optional[str] = None
        self.timestamp: str = datetime.now().strftime("%Y%m%d-%H%M%S")

        # KB augmentation
        self.kb_augmented: bool = False
        self.kb_components: List[Dict[str, Any]] = []
        self.kb_verification_results: List[Dict[str, Any]] = []

        # VLM Self-Correction
        self.vlm_correction_used: bool = False
        self.vlm_iterations: int = 0
        self.vlm_approved: bool = False
        self.vlm_assessment: Optional[Dict[str, Any]] = None
        self.multi_view_images: Dict[str, str] = {}  # view_name -> relative path
        self.vlm_iteration_history: List[Dict[str, Any]] = []

        # Component Verification (post-VLM structural checks)
        self.component_verification_used: bool = False
        self.component_verification_iterations: int = 0
        self.component_verification_passed: bool = False
        self.all_parts_present: bool = False
        self.is_fully_connected: bool = False
        self.component_verification_issues: List[str] = []
        self.component_verification_history: List[Dict[str, Any]] = []

        # Prompt Enhancement
        self.prompt_enhanced: bool = False
        self.enhanced_prompt: Optional[str] = None
        self.enhancement_notes: List[str] = []

        # v2: sketch (planner grounding vs post-render verification — see CRAFT_SKETCH_MODE)
        self.sketch_used: bool = False
        self.sketch_path: Optional[str] = None        # absolute path on disk
        self.sketch_web_path: Optional[str] = None    # relative for <img src=>
        self.sketch_prompt: Optional[str] = None
        self.sketch_error: Optional[str] = None
        self.sketch_role: Optional[str] = None        # "planner" | "verification" | "v3_intent"

        # CRAFT v3
        self.craft_version: str = "2"
        self.v3_gap_refinement: Optional[Dict[str, Any]] = None

    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary for JSON response."""
        result = {
            "input_type": self.input_type,
            "timestamp": self.timestamp,
        }

        if self.design_brief:
            result["design_brief"] = {
                "description": self.design_brief.description,
                "expected_parts": self.design_brief.expected_parts,
                "essential_parts": getattr(self.design_brief, 'essential_parts', []),
                "secondary_parts": getattr(self.design_brief, 'secondary_parts', []),
                "optional_parts": getattr(self.design_brief, 'optional_parts', []),
                "parameters": self.design_brief.parameters,
                "kb_augmented": self.design_brief.kb_augmented if hasattr(self.design_brief, 'kb_augmented') else False
            }

        if self.captions:
            result["captions"] = self.captions

        if self.plan:
            result["plan"] = self.plan

        if self.scad_code:
            result["code"] = self.scad_code

        if self.validation:
            result["validation"] = self.validation.to_dict()

        result["stats"] = {
            "plan_attempts": self.plan_attempts,
            "repair_attempts": self.repair_attempts
        }

        # KB information
        result["kb"] = {
            "augmented": self.kb_augmented,
            "components": self.kb_components,
            "verification_results": self.kb_verification_results
        }

        # VLM Self-Correction information
        result["vlm_correction"] = {
            "used": self.vlm_correction_used,
            "iterations": self.vlm_iterations,
            "approved": self.vlm_approved,
            "assessment": self.vlm_assessment,
            "multi_view_images": self.multi_view_images,
            "iteration_history": self.vlm_iteration_history
        }

        # Component Verification information
        result["component_verification"] = {
            "used": self.component_verification_used,
            "iterations": self.component_verification_iterations,
            "passed": self.component_verification_passed,
            "all_parts_present": self.all_parts_present,
            "is_fully_connected": self.is_fully_connected,
            "issues": self.component_verification_issues,
            "history": self.component_verification_history
        }

        # Prompt Enhancement information
        result["prompt_enhancement"] = {
            "enhanced": self.prompt_enhanced,
            "enhanced_prompt": self.enhanced_prompt,
            "notes": self.enhancement_notes
        }

        # v2: sketch — role is "planner" (fed to planner) or "verification" (after render)
        result["sketch"] = {
            "used": self.sketch_used,
            "role": self.sketch_role,
            "web_path": self.sketch_web_path,
            "prompt": self.sketch_prompt,
            "error": self.sketch_error,
        }

        result["craft_version"] = getattr(self, "craft_version", "2")
        result["gap_refinement"] = getattr(self, "v3_gap_refinement", None)

        return result


# =============================================================================
# PIPELINE ORCHESTRATOR
# =============================================================================

class CRAFTPipeline:
    """
    Main pipeline orchestrator.

    Handles the full flow from input to validated output.
    Uses hybrid model approach:
    - Reasoning model (GPT-5.2) for critical reasoning: Understanding, Planning, VLM correction
    - Fast model (GPT-4o) for deterministic tasks: Vision Analysis, Compilation, Repair
    """

    def __init__(
        self,
        client,
        model_pipeline: str = MODEL_PIPELINE,
        model_vlm: str = MODEL_VLM,
        auto_repair: bool = AUTO_REPAIR,
        max_plan_attempts: int = MAX_PLAN_ATTEMPTS,
        max_repair_attempts: int = MAX_REPAIR_ATTEMPTS,
        use_vlm_correction: bool = USE_VLM_CORRECTION,
        max_vlm_iterations: int = MAX_VLM_ITERATIONS,
        use_component_verification: bool = USE_COMPONENT_VERIFICATION,
        max_component_iterations: int = MAX_COMPONENT_ITERATIONS,
        use_kb: bool = True,
        use_sketch: bool = SKETCH_ENABLED_DEFAULT,
    ):
        self.client = client
        self.model_pipeline = model_pipeline  # For vision analysis, compilation, repair, enhancement
        self.model_vlm = model_vlm            # For understanding, planning, VLM correction (reasoning model)
        self.auto_repair = auto_repair
        self.max_plan_attempts = max_plan_attempts
        self.max_repair_attempts = max_repair_attempts
        self.use_vlm_correction = use_vlm_correction
        self.max_vlm_iterations = max_vlm_iterations
        self.use_component_verification = use_component_verification
        self.max_component_iterations = max_component_iterations
        self.use_kb = use_kb
        # v2: Sketch step is optional so users can skip the image-gen call
        # (cost / latency) when they just want fast text→SCAD.
        self.use_sketch = use_sketch
        # CRAFT v2 vs v3: v3 uses baseline + gap refinement instead of the VLM loop
        _cv = CRAFT_VERSION if CRAFT_VERSION in ("2", "3") else "2"
        self.craft_version_str = _cv

        # Sketch modes (CRAFT v2.1):
        #   - "reference" (default): generate sketch early from the design
        #     brief, DO NOT feed it to the planner (so it can't pollute the
        #     plan with hallucinated details), but thread it through the VLM
        #     correction + component verifier as a visual intent anchor.
        #   - "plan" (legacy): generate early AND feed as a planner reference.
        #     Kept for backward-compat but discouraged — sketches hallucinate
        #     confidently and the planner takes them too literally.
        #   - "verify" (legacy): defer generation until AFTER render as a
        #     post-hoc comparison. Still supported for ablation.
        _sm = os.getenv("CRAFT_SKETCH_MODE", "reference").strip().lower()
        self.sketch_mode = _sm if _sm in ("plan", "verify", "reference") else "reference"

        # Hybrid model approach:
        # - GPT-5.2 (reasoning model) for critical reasoning tasks: Understanding & Planning
        # - GPT-4o (fast model) for deterministic tasks: Vision Analysis, Compilation, Repair
        self.reasoner = TextReasoner(client, model_vlm, use_kb=use_kb)  # GPT-5.2 for better understanding
        self.planner = Planner(client, model_vlm)  # GPT-5.2 for better planning logic
        
        # Keep GPT-4o for faster, more deterministic tasks
        self.vision_analyzer = VisionAnalyzer(client, model_pipeline)
        self.compiler = Compiler(client, model_pipeline)
        # v2: Validator is now the lightweight blank-render / bracket gate
        # from core.render_checks. The LLM-driven RepairOrchestrator is gone;
        # repair is handled inside the VLM self-correction loop (Phase B will
        # replace it with the unified-feedback stage emitting JSON Patches).
        self.validator = Validator(PASS_THRESHOLD)

        # VLM Self-Corrector with reasoning model (GPT-5.2)
        self.visual_corrector = VisualSelfCorrector(
            client=client,
            model=model_vlm,
            max_iterations=max_vlm_iterations,
            image_dir=IMAGE_DIR,
            pass_threshold=PASS_THRESHOLD
        )

        # Component Verifier with reasoning model (GPT-5.2)
        self.component_verifier = ComponentVerifier(
            client=client,
            model=model_vlm,
            max_iterations=max_component_iterations,
            image_dir=IMAGE_DIR
        )

        # CRAFT v3: single vision gap analysis + one text-only SCAD patch
        self.gap_refiner = GapRefiner(
            client=client,
            model=model_vlm,
            image_dir=IMAGE_DIR,
        )

        # CRAFT v2.1: PromptEnhancer removed. If someone wants to reintroduce
        # it, do it as an opt-in wrapper around run_text, not as a mandatory
        # stage — it silently shifted user intent and was the single easiest
        # place for the pipeline to start drifting away from the request.

        # v2: Sketch generator — orthographic concept image. In ``plan`` mode it
        # runs before planning; in ``verify`` mode (default) only after render.
        # Gated per-request by ``self.use_sketch``. Instance kept for reuse.
        self.sketch_generator = SketchGenerator(
            client=client,
            enabled=self.use_sketch,
        )

        # Progress callback (set by Flask if available)
        self._progress_callback = None

    def _emit_progress(self, stage: str, progress: float, message: str, details: dict = None):
        """Emit progress update if callback is set."""
        if self._progress_callback:
            try:
                self._progress_callback({
                    "stage": stage,
                    "progress": progress,
                    "message": message,
                    "details": details or {}
                })
            except Exception as e:
                print(f"[Progress] Emit failed: {e}")
    
    def run_text(self, prompt: str) -> PipelineState:
        """
        Run pipeline with text input.

        Args:
            prompt: Natural language description

        Returns:
            PipelineState with results
        """
        state = PipelineState(input_type="text", original_input=prompt)

        # CRAFT v2.1: unified KB detection — one pass over the user's prompt.
        # The detection bundle is passed directly to the reasoner so we only
        # run component detection once per request.
        detection_bundle = self.reasoner.detect(prompt, original_prompt=prompt)

        # Stage 0 (removed): PromptEnhancer used to rewrite the prompt here
        # before the reasoner saw it. In practice that silently drifted user
        # intent ("simple cup" → "ergonomic ceramic cup with lip curvature")
        # and doubled upfront latency. The reasoner is strong enough on
        # modern models that this rewrite is not earning its keep. The prompt
        # is now passed straight through.
        working_prompt = prompt

        # Stage 1: Understanding — the reasoner receives the user's raw
        # prompt plus the shared detection bundle.
        state.design_brief = self.reasoner.analyze_with_bundle(
            working_prompt, detection_bundle
        )

        # v2.1 Stage 1.5: Sketch. Two modes generate the sketch early from
        # the design brief so it can anchor downstream stages:
        #   - "plan": sketch feeds the planner (legacy, can over-constrain)
        #   - "reference" (default): sketch does NOT feed the planner; it is
        #     threaded through VLM correction + component verifier as a loose
        #     visual intent anchor. This keeps the plan robust while still
        #     giving the vision stages a target silhouette.
        # "verify" defers generation until after render (legacy).
        if self.use_sketch and self.sketch_mode in ("plan", "reference"):
            try:
                sketch: SketchResult = sketch_from_design_brief(
                    client=self.client,
                    brief=state.design_brief,
                    timestamp=state.timestamp,
                    enhanced_prompt=state.enhanced_prompt or working_prompt,
                    enabled=True,
                    for_post_render_verification=False,
                )
                state.sketch_used = sketch.success
                state.sketch_path = sketch.image_path
                state.sketch_web_path = sketch.web_path
                state.sketch_prompt = sketch.prompt_used
                state.sketch_error = sketch.error
                if sketch.success:
                    state.sketch_role = (
                        "planner" if self.sketch_mode == "plan" else "reference"
                    )
                    print(
                        f"[Pipeline] Early sketch ({state.sketch_role}) → "
                        f"{sketch.web_path or sketch.image_path}"
                    )
                else:
                    state.sketch_role = None
                    if sketch.error:
                        print(f"[Pipeline] Early sketch skipped: {sketch.error}")
            except Exception as e:
                state.sketch_used = False
                state.sketch_role = None
                state.sketch_error = f"{type(e).__name__}: {e}"
                print(f"[Pipeline] Early sketch raised (continuing without it): {e}")
        elif self.use_sketch and self.sketch_mode == "verify":
            state.sketch_used = False
            state.sketch_role = None
            state.sketch_error = None
            state.sketch_path = None
            state.sketch_web_path = None
            state.sketch_prompt = None
            print(
                "[Pipeline] Sketch deferred to post-render verification "
                f"(CRAFT_SKETCH_MODE={self.sketch_mode})"
            )
        else:
            state.sketch_used = False
            state.sketch_role = None
            state.sketch_error = "disabled by request (use_sketch=false)"
            print("[Pipeline] Sketch stage skipped (use_sketch=false)")

        # Capture KB augmentation info
        if hasattr(state.design_brief, 'kb_augmented') and state.design_brief.kb_augmented:
            state.kb_augmented = True
            state.kb_components = [
                {
                    "id": c.component_id,
                    "name": c.component_name,
                    "module": c.module_name,
                    "confidence": c.confidence
                }
                for c in state.design_brief.kb_components
            ]
            print(f"[KB] Using {len(state.kb_components)} components from knowledge base")

        # Stage 2-6: Core pipeline
        return self._run_core_pipeline(state)
    
    def run_vision(
        self,
        image_paths: List[str],
        view_names: Optional[List[str]] = None
    ) -> PipelineState:
        """
        Run pipeline with vision input.
        
        Args:
            image_paths: List of view image paths
            view_names: Optional view names
            
        Returns:
            PipelineState with results
        """
        state = PipelineState(input_type="vision", original_input=image_paths)
        
        # Stage 1: Vision analysis
        vision_result = self.vision_analyzer.analyze(image_paths, view_names)
        
        state.captions = {
            "best": vision_result.best_caption,
            "alternatives": vision_result.alternatives,
            "features": vision_result.identified_features
        }
        
        # Stage 2: Convert caption to design brief
        state.design_brief = self.reasoner.analyze(vision_result.best_caption)
        state.design_brief.source = "vision"

        # Stage 3-6: Core pipeline
        return self._run_core_pipeline(state)

    def run_single_image(self, image_path: str) -> PipelineState:
        """
        Run pipeline with a single concept image input.

        Uses GPT-5.2 (best reasoning model) to understand the object in the image
        and generate a comprehensive CAD description. Then runs through the normal
        pipeline with VLM self-correction (up to ``MAX_VLM_ITERATIONS``).

        This is designed for real-world photographs of objects (ice cream, coffee mug, etc.)
        that need to be translated into 3D CAD models.

        Args:
            image_path: Path to the single image file

        Returns:
            PipelineState with results
        """
        state = PipelineState(input_type="single_image", original_input=image_path)

        print(f"[Pipeline] Single image mode - Using {SINGLE_IMAGE_MODEL} for image understanding")

        # Stage 1: Single image analysis with GPT-5.2
        single_image_analyzer = SingleImageAnalyzer(self.client)
        image_result = single_image_analyzer.analyze(image_path)

        # Store the detailed analysis
        state.captions = {
            "object_identified": image_result.object_identified,
            "best": image_result.best_caption,
            "alternatives": image_result.alternatives,
            "geometric_breakdown": image_result.geometric_breakdown,
            "proportions": image_result.proportions,
            "distinctive_features": image_result.distinctive_features,
            "cad_hints": image_result.cad_hints
        }

        # Stage 2: Build enhanced prompt and create design brief
        enhanced_prompt = self._build_enhanced_prompt_from_single_image(image_result)

        # Use reasoner to create design brief from enhanced prompt
        # No KB for concept images - they're not from NopSCADlib
        reasoner_no_kb = TextReasoner(self.client, self.model_pipeline, use_kb=False)
        state.design_brief = reasoner_no_kb.analyze(enhanced_prompt)
        state.design_brief.source = "single_image"

        print(f"[Pipeline] Object identified: {image_result.object_identified}")
        print(f"[Pipeline] CAD hints: {image_result.cad_hints}")

        # Stage 3-6: Core pipeline (Planning, Compilation, Rendering, VLM correction)
        return self._run_core_pipeline(state)

    def _build_enhanced_prompt_from_single_image(self, analysis: SingleImageAnalysis) -> str:
        """
        Build an enhanced prompt from SingleImageAnalysis for the TextReasoner.

        Combines the best caption with geometric insights from GPT-5.2's analysis.
        """
        parts = [
            f"Create a 3D CAD model of: {analysis.object_identified}.",
            "",
            analysis.best_caption
        ]

        # Add geometric guidance
        geo = analysis.geometric_breakdown
        if geo.get("primary_form"):
            parts.append(f"\nPrimary form: {geo['primary_form']}")

        if geo.get("components"):
            components_desc = []
            for c in geo["components"][:5]:
                comp_str = f"- {c.get('part', 'part')}: {c.get('primitive', 'shape')}"
                if c.get('position'):
                    comp_str += f" ({c['position']})"
                components_desc.append(comp_str)
            if components_desc:
                parts.append("\nKey components:")
                parts.extend(components_desc)

        if geo.get("suggested_primitives"):
            parts.append(f"\nSuggested primitives: {', '.join(geo['suggested_primitives'][:6])}")

        # Add proportions
        props = analysis.proportions
        if props.get("key_ratios"):
            parts.append(f"\nProportions: {'; '.join(props['key_ratios'][:3])}")

        # Add CAD hints
        if analysis.cad_hints:
            parts.append(f"\nCAD implementation hint: {analysis.cad_hints}")

        return "\n".join(parts)

    def _maybe_run_verification_sketch(self, state: PipelineState) -> None:
        """If ``CRAFT_SKETCH_MODE=verify``, generate a post-render reference sketch."""
        if not (self.use_sketch and self.sketch_mode == "verify"):
            return
        if not state.plan_valid or not state.scad_code:
            return
        desc = (
            (state.enhanced_prompt or "").strip()
            or getattr(state.design_brief, "description", "") or ""
        ).strip()
        if not desc:
            return
        try:
            sketch: SketchResult = sketch_from_design_brief(
                client=self.client,
                brief=state.design_brief,
                timestamp=state.timestamp,
                enhanced_prompt=desc,
                enabled=True,
                for_post_render_verification=True,
            )
            state.sketch_used = sketch.success
            state.sketch_path = sketch.image_path
            state.sketch_web_path = sketch.web_path
            state.sketch_prompt = sketch.prompt_used
            state.sketch_error = sketch.error
            state.sketch_role = "verification" if sketch.success else None
            if sketch.success:
                print(
                    f"[Pipeline] Verification sketch → {sketch.web_path or sketch.image_path}"
                )
            elif sketch.error:
                print(f"[Pipeline] Verification sketch skipped: {sketch.error}")
        except Exception as e:
            state.sketch_used = False
            state.sketch_role = None
            state.sketch_error = f"{type(e).__name__}: {e}"
            print(f"[Pipeline] Verification sketch raised (non-fatal): {e}")

    def _run_core_pipeline(self, state: PipelineState) -> PipelineState:
        """
        Run the core pipeline stages.

        Args:
            state: Pipeline state with design_brief populated

        Returns:
            Updated state
        """
        # Emit progress: Starting planning
        self._emit_progress("planning", 0.1, "Creating CAD plan from design brief...")

        # Stage 3: Planning. We ONLY pass the sketch to the planner when
        # sketch_mode == "plan" (role=="planner"). In the new default
        # "reference" mode the sketch is withheld from the planner to keep
        # the plan grounded in the user prompt, and surfaces instead during
        # VLM correction and component verification.
        plan_result = self.planner.create_plan(
            state.design_brief,
            self.max_plan_attempts,
            reference_image_path=(
                state.sketch_path
                if (
                    state.sketch_used
                    and state.sketch_role == "planner"
                    and state.sketch_path
                )
                else None
            ),
        )

        state.plan = plan_result.plan
        state.plan_valid = plan_result.valid
        state.plan_error = plan_result.error
        state.plan_attempts = plan_result.attempts

        if not plan_result.valid:
            return state

        self._emit_progress("compilation", 0.35, "Compiling plan into OpenSCAD code...")

        # Stage 4: Compilation (with KB component injection)
        kb_components = state.design_brief.kb_components if hasattr(state.design_brief, 'kb_components') else None
        state.scad_code = self.compiler.compile(state.plan, kb_components=kb_components)

        self._emit_progress("compilation", 0.45, "Optimizing OpenSCAD code...")

        # Stage 4b: Preemptive render-safety scan (rule-based, no LLM call).
        # Strips patterns we KNOW timeout OpenSCAD (minkowski, $fn > 32)
        # BEFORE we burn ~6 minutes trying to render them across 6 views.
        # The planner prompt already bans these, but this is the belt to
        # the planner's suspenders.
        try:
            preemptive = preemptive_render_safety_fix(state.scad_code)
            if preemptive.changed:
                print(
                    f"[CRAFTPipeline] Preemptive render-safety fix applied: "
                    f"issues={preemptive.issues_found} changes={preemptive.changes_made}"
                )
                state.scad_code = preemptive.fixed_code
        except Exception as e:
            # Never let the safety scan block the pipeline — degrade gracefully.
            print(f"[CRAFTPipeline] Preemptive render-safety scan failed (non-fatal): {e}")

        # Save files
        self._save_files(state)

        self._emit_progress("rendering", 0.50, "Rendering 3D preview (this may take 30-60 seconds)...")

        # Stage 5: Render initial preview
        self._render(state)

        self._emit_progress("rendering", 0.75, "Render complete, validating model...")

        # Stage 5.5 — CRAFT v2.1 sanity gate.
        # Run the cheap, deterministic quality gate on the initial render
        # BEFORE feeding it to the VLM. If the render is clearly broken
        # (blank, CSG explosion, huge bounding box) we surface that to the
        # log so the VLM's iterations are interpreted in context. This
        # uses render_checks.render_quality_gate — the same primitive the
        # v2 Phase B.7 gate was built on.
        try:
            from core.render_checks import render_quality_gate
            gate = render_quality_gate(
                scad_code=state.scad_code,
                render_path=state.image_path,
                scad_path=state.scad_path,
            )
            if not gate.passed:
                print(
                    f"[CRAFTPipeline] Sanity gate FAILED on initial render "
                    f"(score={gate.score:.2f}): {', '.join(gate.issues) or 'no details'}"
                )
            else:
                print(
                    f"[CRAFTPipeline] Sanity gate passed "
                    f"(score={gate.score:.2f})"
                )
        except Exception as e:
            # Gate is advisory — never fail the pipeline on a gate error.
            print(f"[CRAFTPipeline] Sanity gate check raised (non-fatal): {e}")

        # Stage 6 & 7: post-render refinement (VLM v2, or v3 gap refinement)
        if self.use_vlm_correction:
            self._emit_progress("vlm_correction", 0.80, "Running visual quality check...")
            if self.craft_version_str == "3":
                state = self._run_v3_refinement(state)
            else:
                state = self._run_vlm_correction(state)
        else:
            # v2: the legacy validate → LLM-repair fallback is gone. When
            # VLM correction is disabled (ablation / offline) we still run
            # the lightweight deterministic blank-render gate so callers
            # see a sane `state.validation`.
            state.validation = self.validator.validate(
                state.scad_code,
                state.design_brief.expected_parts,
                state.design_brief.description,
                state.scad_path,
                state.image_path,
            )

        # v2 post-render sketch: skip in v3 (intent sketch is part of v3 path)
        if self.craft_version_str != "3":
            self._maybe_run_verification_sketch(state)

        self._emit_progress("complete", 1.0, "Generation complete!")
        return state

    def _run_v3_refinement(self, state: PipelineState) -> PipelineState:
        """
        CRAFT v3: keep baseline plan+compile, then compare intent (sketch + text)
        to six ortho renders, output structured gaps, apply one text-only SCAD patch.
        """
        print(
            "[Pipeline] CRAFT v3 — gap refinement (sketch/ortho → JSON gaps → single apply)"
        )
        state.craft_version = "3"

        sketch_ref = None
        if state.sketch_used and state.sketch_path and os.path.exists(state.sketch_path):
            sketch_ref = state.sketch_path
        elif self.use_sketch:
            desc = (getattr(state.design_brief, "description", None) or "").strip()
            if desc:
                try:
                    sk = sketch_from_design_brief(
                        client=self.client,
                        brief=state.design_brief,
                        timestamp=state.timestamp,
                        enabled=True,
                        for_post_render_verification=True,
                    )
                    if sk.success and sk.image_path:
                        state.sketch_used = True
                        state.sketch_path = sk.image_path
                        state.sketch_web_path = sk.web_path
                        state.sketch_prompt = sk.prompt_used
                        state.sketch_error = sk.error
                        state.sketch_role = "v3_intent"
                        sketch_ref = sk.image_path
                        print(
                            f"[Pipeline] v3 intent sketch → "
                            f"{sk.web_path or sk.image_path}"
                        )
                except Exception as e:
                    state.sketch_error = f"{type(e).__name__}: {e}"
                    print(f"[Pipeline] v3 sketch failed (continuing without): {e}")

        kb_components = (
            state.design_brief.kb_components
            if hasattr(state.design_brief, "kb_components")
            else None
        )
        ref_imgs = None
        if kb_components:
            ref_imgs = self.visual_corrector._get_kb_reference_images(
                kb_components
            )

        gr = self.gap_refiner.run(
            scad_code=state.scad_code,
            scad_path=state.scad_path,
            original_prompt=state.design_brief.description,
            expected_parts=state.design_brief.expected_parts or [],
            timestamp=state.timestamp,
            sketch_path=sketch_ref,
            kb_reference_images=ref_imgs,
        )

        state.v3_gap_refinement = {
            "used": True,
            "success": gr.success,
            "applied_patch": gr.applied_patch,
            "analysis": gr.analysis,
            "error": gr.error,
        }

        if gr.applied_patch and gr.final_code:
            state.scad_code = strip_to_scad(gr.final_code)
            self._save_files(state)

        state.multi_view_images = {}
        for vn, pth in (gr.view_images or {}).items():
            if pth and os.path.exists(pth):
                state.multi_view_images[vn] = self._to_web_path(pth)

        state.vlm_correction_used = False
        state.vlm_iterations = 0
        state.vlm_approved = gr.success
        state.vlm_assessment = None
        state.vlm_iteration_history = []

        v_issues: List[str] = []
        if gr.error:
            v_issues.append(gr.error)
        state.validation = ValidationResult(
            score=90 if gr.success else 40,
            passed=gr.success,
            checks={},
            issues=v_issues,
        )

        # Main UI preview (800x600) from final on-disk SCAD; ortho paths stay in multi_view_images
        self._render(state)

        if self.use_component_verification:
            state = self._run_component_verification(state)
        return state

    def _run_vlm_correction(self, state: PipelineState) -> PipelineState:
        """
        Run the VLM self-correction loop.

        This replaces the old validation + repair with visual feedback.

        Args:
            state: Pipeline state with SCAD code compiled

        Returns:
            Updated state with VLM correction results
        """
        print(f"[Pipeline] Starting VLM self-correction loop (max {self.max_vlm_iterations} iterations)")

        # Run the visual correction loop (with KB components for reference
        # images and, in v2.1, the early design-intent sketch as a visual
        # anchor for the VLM). The sketch is only used when sketch_role is
        # "reference" or "planner" — "verify" mode generates it post-hoc
        # so it's not available yet.
        kb_components = state.design_brief.kb_components if hasattr(state.design_brief, 'kb_components') else None
        sketch_ref = (
            state.sketch_path
            if (state.sketch_used and state.sketch_path and os.path.exists(state.sketch_path))
            else None
        )
        correction_result = self.visual_corrector.run_correction_loop(
            scad_code=state.scad_code,
            original_prompt=state.design_brief.description,
            expected_parts=state.design_brief.expected_parts,
            scad_path=state.scad_path,
            timestamp=state.timestamp,
            kb_components=kb_components,
            reference_sketch_path=sketch_ref,
        )

        # Update state with correction results
        state.vlm_correction_used = True
        state.vlm_iterations = correction_result.iterations
        state.vlm_approved = correction_result.success
        state.scad_code = correction_result.final_code

        # Store final view images with relative paths for frontend
        state.multi_view_images = {}
        for view_name, abs_path in correction_result.final_view_images.items():
            # Convert to relative path for web serving
            if abs_path and os.path.exists(abs_path):
                # Use pathlib for cross-platform path handling
                rel_path = self._to_web_path(abs_path)
                state.multi_view_images[view_name] = rel_path

        # Store assessment
        if correction_result.final_assessment:
            state.vlm_assessment = {
                "approved": correction_result.final_assessment.approved,
                "confidence": correction_result.final_assessment.confidence,
                "overall_match": correction_result.final_assessment.overall_match,
                "issues": correction_result.final_assessment.issues,
                "suggestions": correction_result.final_assessment.suggestions,
                "view_assessments": correction_result.final_assessment.view_assessments
            }

        # Store iteration history (simplified for JSON)
        state.vlm_iteration_history = []
        for iter_result in correction_result.iteration_history:
            iter_data = {
                "iteration": iter_result.iteration,
                "deterministic_score": iter_result.deterministic_score,
                "deterministic_passed": iter_result.deterministic_passed,
                "corrected": iter_result.corrected,
                "view_images": {}
            }
            # Add relative paths for view images using cross-platform helper
            for vname, vpath in iter_result.view_images.items():
                if vpath and os.path.exists(vpath):
                    iter_data["view_images"][vname] = self._to_web_path(vpath)

            if iter_result.vlm_assessment:
                iter_data["vlm_assessment"] = {
                    "approved": iter_result.vlm_assessment.approved,
                    "confidence": iter_result.vlm_assessment.confidence,
                    "overall_match": iter_result.vlm_assessment.overall_match,
                    "issues": iter_result.vlm_assessment.issues
                }
            state.vlm_iteration_history.append(iter_data)

        # Create a validation result for compatibility
        state.validation = ValidationResult(
            score=correction_result.final_score,
            passed=correction_result.success,
            checks={},
            issues=correction_result.final_assessment.issues if correction_result.final_assessment else []
        )

        # Update image path to first view (for backward compatibility)
        if state.multi_view_images:
            first_view = list(state.multi_view_images.values())[0]
            # Copy the front view as the main preview
            if "front" in state.multi_view_images:
                state.image_path = state.multi_view_images["front"]
            else:
                state.image_path = first_view

        # Re-save the final corrected code
        self._save_files(state)

        # Re-render the main preview image with the final corrected SCAD code
        # This ensures the "final output" matches the corrected code, not the pre-VLM state
        self._render(state)

        print(f"[Pipeline] VLM correction complete: {correction_result.iterations} iterations, approved={correction_result.success}")

        # Run Component Verification if enabled and VLM didn't fully approve
        should_verify_components = (
            self.use_component_verification and
            (not correction_result.success or
             (correction_result.final_assessment and
              correction_result.final_assessment.confidence < COMPONENT_VERIFY_THRESHOLD))
        )

        if should_verify_components:
            print(f"[Pipeline] Running component verification (VLM confidence below threshold or not approved)")
            state = self._run_component_verification(state)
        elif self.use_component_verification:
            print(f"[Pipeline] Skipping component verification (VLM approved with high confidence)")

        return state

    def _run_component_verification(self, state: PipelineState) -> PipelineState:
        """
        Run targeted component verification after VLM correction.

        Checks:
        1. All expected parts are present
        2. Model is a single connected object
        3. Parts are properly attached

        Args:
            state: Pipeline state after VLM correction

        Returns:
            Updated state with component verification results
        """
        print(f"[Pipeline] Starting component verification (max {self.max_component_iterations} iterations)")

        # Run the component verification loop with TIERED parts (with KB
        # reference images and the v2.1 early design-intent sketch).
        kb_components = state.design_brief.kb_components if hasattr(state.design_brief, 'kb_components') else None
        sketch_ref = (
            state.sketch_path
            if (state.sketch_used and state.sketch_path and os.path.exists(state.sketch_path))
            else None
        )
        verification_result = self.component_verifier.verify_and_fix(
            scad_code=state.scad_code,
            expected_parts=state.design_brief.expected_parts,
            original_prompt=state.design_brief.description,
            scad_path=state.scad_path,
            timestamp=state.timestamp,
            existing_view_images=state.multi_view_images,  # Reuse VLM images for first iteration
            essential_parts=getattr(state.design_brief, 'essential_parts', []),
            secondary_parts=getattr(state.design_brief, 'secondary_parts', []),
            optional_parts=getattr(state.design_brief, 'optional_parts', []),
            kb_components=kb_components,
            reference_sketch_path=sketch_ref,
        )

        # Update state with verification results
        state.component_verification_used = True
        state.component_verification_iterations = verification_result.iterations
        state.component_verification_passed = verification_result.success
        state.all_parts_present = verification_result.all_parts_present
        state.is_fully_connected = verification_result.is_fully_connected
        state.component_verification_issues = verification_result.final_issues

        # Update code if verification made corrections
        if verification_result.final_code != state.scad_code:
            state.scad_code = verification_result.final_code
            self._save_files(state)
            # Re-render the main preview with the corrected code
            self._render(state)

        # Store iteration history
        state.component_verification_history = []
        for iter_result in verification_result.iteration_history:
            iter_data = {
                "iteration": iter_result.iteration,
                "all_parts_found": iter_result.all_parts_found,
                "is_connected": iter_result.is_connected,
                "issues": iter_result.issues,
                "corrected": iter_result.corrected,
                "parts_present": [
                    {
                        "part_name": p.part_name,
                        "present": p.present,
                        "confidence": p.confidence,
                        "notes": p.notes
                    }
                    for p in iter_result.parts_present
                ],
                "connectivity": {
                    "is_single_object": iter_result.connectivity.is_single_object,
                    "floating_parts": iter_result.connectivity.floating_parts,
                    "attachment_issues": iter_result.connectivity.attachment_issues,
                    "confidence": iter_result.connectivity.confidence
                }
            }
            state.component_verification_history.append(iter_data)

        # Update overall validation status
        if verification_result.success:
            state.validation.passed = True
            state.vlm_approved = True  # Override since component verification passed
            print(f"[Pipeline] Component verification PASSED after {verification_result.iterations} iterations")
        else:
            print(f"[Pipeline] Component verification completed with issues: {verification_result.final_issues}")

        return state

    # NOTE: _auto_repair and repair_with_hint were removed in CRAFT v2.
    # Automatic repair is handled by the VLM self-correction loop and, in
    # Phase B, by the unified-feedback stage (structured JSON Patch on the
    # plan IR). Manual user-hint repair is reintroduced through that same
    # stage; the /repair endpoint below currently returns HTTP 410.
    
    def _save_files(self, state: PipelineState):
        """Save SCAD and plan files."""
        os.makedirs(SCAD_DIR, exist_ok=True)
        os.makedirs(PLAN_DIR, exist_ok=True)
        
        # Save SCAD
        state.scad_path = os.path.join(SCAD_DIR, f"{state.timestamp}.scad")
        with open(state.scad_path, "w", encoding="utf-8") as f:
            f.write(state.scad_code)
        
        # Save plan
        if state.plan:
            plan_path = os.path.join(PLAN_DIR, f"{state.timestamp}.json")
            with open(plan_path, "w", encoding="utf-8") as f:
                json.dump(state.plan, f, indent=2)
    
    def _render(self, state: PipelineState):
        """Render the SCAD file."""
        os.makedirs(IMAGE_DIR, exist_ok=True)

        state.image_path = os.path.join(IMAGE_DIR, f"{state.timestamp}.png")

        runner = OpenScadRunner(
            state.scad_path,
            state.image_path,
            render_mode=RenderMode.preview,
            imgsize=IMG_SIZE
        )
        runner.run()

    def _to_web_path(self, file_path: str) -> str:
        """
        Convert a file path to a web-safe relative path.

        Handles both Windows and Unix paths, normalizing to forward slashes
        and extracting the relative path from static/ onwards.
        """
        if not file_path:
            return ""

        # Use pathlib for cross-platform handling
        path = Path(file_path)

        # Convert to posix-style path (forward slashes)
        posix_path = path.as_posix()

        # Check if it's already relative and starts with static/
        if posix_path.startswith("static/"):
            return posix_path

        # Try to find static/ in the path
        parts = path.parts
        for i, part in enumerate(parts):
            if part == "static":
                # Join from static/ onwards with forward slashes
                return "/".join(parts[i:])

        # Fallback: just return the filename in static/images
        return f"static/images/{path.name}"


# =============================================================================
# FLASK APPLICATION
# =============================================================================

app = Flask(__name__)
app.secret_key = secrets.token_hex(16)

# Session storage for current state
# In production, use Redis or database
current_states: Dict[str, PipelineState] = {}

# Progress tracking for real-time frontend updates
progress_queues: Dict[str, Queue] = {}


def get_progress_queue(session_id: str) -> Queue:
    """Get or create progress queue for a session."""
    if session_id not in progress_queues:
        progress_queues[session_id] = Queue()
    return progress_queues[session_id]


def get_pipeline(
    use_kb: bool = True,
    model_pipeline: Optional[str] = None,
    use_sketch: bool = SKETCH_ENABLED_DEFAULT,
) -> CRAFTPipeline:
    """Get a pipeline instance with hybrid model configuration.

    Uses GPT-5.2 for critical reasoning (Understanding, Planning, VLM correction)
    and GPT-4o for deterministic tasks (Vision Analysis, Compilation, Repair).

    Args:
        use_kb: Enable RAG / knowledge-base augmentation.
        model_pipeline: Override the fast model used for deterministic tasks.
        use_sketch: Whether sketch image-gen runs at all. Role is set by
            ``CRAFT_SKETCH_MODE``: ``plan`` (before planner) or ``verify`` (after render).
    """
    return CRAFTPipeline(
        client,
        model_pipeline=model_pipeline or MODEL_PIPELINE,
        model_vlm=MODEL_VLM,
        use_kb=use_kb,
        use_sketch=use_sketch,
    )


@app.route("/")
def index():
    """Main UI page."""
    return render_template("index.html")


@app.route("/generate", methods=["POST"])
def generate():
    """
    Text-to-CAD generation endpoint.

    Uses hybrid model approach:
    - GPT-5.2 for critical reasoning: Understanding, Planning, VLM Correction
    - GPT-4o for deterministic tasks: Vision Analysis, Compilation, Repair

    Form data:
        text: Natural language description
        use_rag: Whether to use RAG/Knowledge Base (default: true)
        use_sketch: Whether to run the optional sketch-grounding stage
            (default: follows CRAFT_SKETCH_ENABLED env var).
    """
    text = request.form.get("text", "").strip()
    if not text:
        return jsonify({"error": "Empty prompt"})

    # RAG toggle - default to true for backward compatibility
    use_rag_str = request.form.get("use_rag", "true").lower()
    use_rag = use_rag_str in ("true", "1", "yes", "on")

    # Sketch toggle — default mirrors env. Accept any truthy spelling.
    sketch_default = "true" if SKETCH_ENABLED_DEFAULT else "false"
    use_sketch_str = request.form.get("use_sketch", sketch_default).lower()
    use_sketch = use_sketch_str in ("true", "1", "yes", "on")

    try:
        # Create session_id early for progress streaming
        session_id = secrets.token_hex(8)
        progress_queue = get_progress_queue(session_id)

        # Create progress callback
        _gen_start = time.time()
        def emit_progress(update):
            try:
                # Handle both dict and ProgressUpdate object formats
                if isinstance(update, dict):
                    stage = update.get("stage", "unknown")
                    progress = update.get("progress", 0)
                    message = update.get("message", "Processing...")
                    eta_seconds = update.get("eta_seconds")
                    details = update.get("details", {})
                else:
                    # ProgressUpdate dataclass
                    stage = update.stage
                    progress = update.progress
                    message = update.message
                    eta_seconds = update.eta_seconds
                    details = update.details or {}

                # Estimate eta if not provided
                if eta_seconds is None or eta_seconds == 0:
                    elapsed = time.time() - _gen_start
                    if progress > 0.01:
                        estimated_total = elapsed / progress
                        eta_seconds = int(max(0, estimated_total - elapsed))
                    else:
                        eta_seconds = 120  # default 2 min estimate

                progress_queue.put({
                    "stage": stage,
                    "progress": round(progress, 3),
                    "message": message,
                    "eta": eta_seconds,
                    "details": details
                })
            except Exception as e:
                print(f"[Progress] Failed to emit event: {e}")

        # Get pipeline with hybrid model configuration
        pipeline = get_pipeline(use_kb=use_rag, use_sketch=use_sketch)

        # Monkey-patch pipeline to emit progress (will be called from pipeline methods)
        pipeline._progress_callback = emit_progress

        # Send initial progress update
        emit_progress({
            "stage": "understanding",
            "progress": 0.05,
            "message": "Analyzing design requirements...",
            "eta_seconds": 120,
            "details": {}
        })

        # Run pipeline with progress tracking
        state = pipeline.run_text(text)

        # Store state for potential repair
        current_states[session_id] = state
        session["state_id"] = session_id

        # Build response
        response = state.to_dict()
        response["session_id"] = session_id

        # Model configuration info
        response["model_pipeline"] = MODEL_PIPELINE  # GPT-4o for deterministic tasks
        response["model_vlm"] = MODEL_VLM            # GPT-5.2 for critical reasoning (Understanding, Planning, VLM)

        # RAG/KB status for A/B comparison tracking
        response["rag_enabled"] = use_rag
        response["rag_used"] = state.kb_augmented  # Whether KB actually contributed
        response["sketch_enabled"] = use_sketch  # Whether sketch stage was requested
        response["sketch_mode"] = pipeline.sketch_mode  # plan | verify (from CRAFT_SKETCH_MODE)
        response["rag_components_count"] = len(state.kb_components) if state.kb_components else 0

        # Prompt Enhancement status
        response["prompt_enhanced"] = state.prompt_enhanced
        if state.prompt_enhanced:
            response["enhanced_prompt"] = state.enhanced_prompt
            response["enhancement_notes"] = state.enhancement_notes

        if state.image_path and os.path.exists(state.image_path):
            response["image"] = f"static/images/{state.timestamp}.png"
            response["filename"] = state.timestamp

        if not state.plan_valid:
            response["error"] = f"Plan generation failed: {state.plan_error}"

        # Parse parameters for customizer UI with LLM-based categorization
        if state.scad_code:
            params = parse_parameters_from_scad(state.scad_code)
            print(f"[Param] Parsed {len(params)} params from SCAD: {[p['name'] for p in params]}")

            # Ask LLM which parameters are essential for this design
            design_desc = state.design_brief.description if state.design_brief else text
            essential_params = categorize_parameters_with_llm(
                client, state.scad_code, design_desc, MODEL_PIPELINE
            )
            print(f"[Param] Essential params from LLM: {essential_params}")

            param_dict = parameters_to_dict(params, essential_params)
            print(f"[Param] Final params dict: {param_dict}")
            response["parameters"] = param_dict

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"})


@app.route("/vision", methods=["POST"])
def vision():
    """
    Vision-to-CAD generation endpoint.
    
    Form data:
        images[]: 6-10 view images
    """
    files = request.files.getlist("images[]")
    
    if not files:
        return jsonify({"error": "No images uploaded"})
    
    if len(files) not in (6, 10):
        return jsonify({"error": "Expected 6 or 10 view images"})
    
    try:
        # Save uploaded images
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        upload_dir = os.path.join(UPLOAD_DIR, timestamp)
        os.makedirs(upload_dir, exist_ok=True)
        
        image_paths = []
        for i, f in enumerate(files):
            filename = secure_filename(f.filename or f"view_{i}.png")
            ext = os.path.splitext(filename)[1].lower() or ".png"
            path = os.path.join(upload_dir, f"view_{i}{ext}")
            f.save(path)
            image_paths.append(path)
        
        # Set view names
        view_names = DEFAULT_VIEW_NAMES[:len(image_paths)]

        # Create session early for progress
        session_id = secrets.token_hex(8)
        progress_queue = get_progress_queue(session_id)
        _gen_start = time.time()

        def emit_progress(update):
            try:
                # Handle both dict and ProgressUpdate object formats
                if isinstance(update, dict):
                    stage = update.get("stage", "unknown")
                    progress = update.get("progress", 0)
                    message = update.get("message", "Processing...")
                    eta_seconds = update.get("eta_seconds")
                    details = update.get("details", {})
                else:
                    # ProgressUpdate dataclass
                    stage = update.stage
                    progress = update.progress
                    message = update.message
                    eta_seconds = update.eta_seconds
                    details = update.details or {}

                # Estimate eta if not provided
                if eta_seconds is None or eta_seconds == 0:
                    elapsed = time.time() - _gen_start
                    if progress > 0.01:
                        estimated_total = elapsed / progress
                        eta_seconds = int(max(0, estimated_total - elapsed))
                    else:
                        eta_seconds = 120  # default 2 min estimate

                progress_queue.put({
                    "stage": stage,
                    "progress": round(progress, 3),
                    "message": message,
                    "eta": eta_seconds,
                    "details": details
                })
            except Exception as e:
                print(f"[Progress] Failed to emit: {e}")

        # Get pipeline with hybrid model configuration
        pipeline = get_pipeline(use_kb=True)
        pipeline._progress_callback = emit_progress

        # Run pipeline
        state = pipeline.run_vision(image_paths, view_names)

        # Store state
        current_states[session_id] = state
        session["state_id"] = session_id
        
        # Build response
        response = state.to_dict()
        response["session_id"] = session_id
        
        if state.image_path and os.path.exists(state.image_path):
            response["image"] = f"static/images/{state.timestamp}.png"
            response["filename"] = state.timestamp

        # Parse parameters for customizer UI with LLM-based categorization
        if state.scad_code:
            params = parse_parameters_from_scad(state.scad_code)
            design_desc = state.design_brief.description if state.design_brief else "Vision-generated model"
            essential_params = categorize_parameters_with_llm(
                client, state.scad_code, design_desc, MODEL_PIPELINE
            )
            response["parameters"] = parameters_to_dict(params, essential_params)

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": f"Server error: {str(e)}"})


@app.route("/vision-single", methods=["POST"])
def vision_single():
    """
    Single Image to CAD generation endpoint.

    Takes a single concept image (e.g., ice cream, coffee mug, toy car) and uses
    GPT-5.2 (best reasoning model) to understand the object and generate
    OpenSCAD code through the CRAFT pipeline.

    Form data:
        image: Single image file (JPEG, PNG, etc.)

    Returns:
        JSON with:
        - object_identified: What GPT-5.2 identified in the image
        - captions: Detailed analysis including geometric breakdown
        - design_brief: Parsed design requirements
        - code: Generated OpenSCAD code
        - image: Rendered preview
        - vlm_correction: VLM self-correction results
    """
    file = request.files.get("image")

    if not file:
        return jsonify({"error": "No image uploaded"})

    # Validate file type
    filename = secure_filename(file.filename or "image.png")
    ext = os.path.splitext(filename)[1].lower()
    if ext not in ('.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'):
        return jsonify({"error": f"Unsupported image format: {ext}"})

    try:
        # Save uploaded image
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        upload_dir = os.path.join(UPLOAD_DIR, f"single_{timestamp}")
        os.makedirs(upload_dir, exist_ok=True)

        image_path = os.path.join(upload_dir, f"concept{ext}")
        file.save(image_path)

        print(f"[Vision-Single] Processing single image: {image_path}")
        print(f"[Vision-Single] Using {SINGLE_IMAGE_MODEL} for image understanding")

        # Create session early for progress
        session_id = secrets.token_hex(8)
        progress_queue = get_progress_queue(session_id)
        _gen_start = time.time()

        def emit_progress(update):
            try:
                # Handle both dict and ProgressUpdate object formats
                if isinstance(update, dict):
                    stage = update.get("stage", "unknown")
                    progress = update.get("progress", 0)
                    message = update.get("message", "Processing...")
                    eta_seconds = update.get("eta_seconds")
                    details = update.get("details", {})
                else:
                    # ProgressUpdate dataclass
                    stage = update.stage
                    progress = update.progress
                    message = update.message
                    eta_seconds = update.eta_seconds
                    details = update.details or {}

                # Estimate eta if not provided
                if eta_seconds is None or eta_seconds == 0:
                    elapsed = time.time() - _gen_start
                    if progress > 0.01:
                        estimated_total = elapsed / progress
                        eta_seconds = int(max(0, estimated_total - elapsed))
                    else:
                        eta_seconds = 120  # default 2 min estimate

                progress_queue.put({
                    "stage": stage,
                    "progress": round(progress, 3),
                    "message": message,
                    "eta": eta_seconds,
                    "details": details
                })
            except Exception as e:
                print(f"[Progress] Failed to emit: {e}")

        # Get pipeline with hybrid model configuration
        # KB is disabled for single image mode (concept images, not NopSCADlib components)
        pipeline = get_pipeline(use_kb=False)
        pipeline._progress_callback = emit_progress

        # Run single image pipeline
        state = pipeline.run_single_image(image_path)

        # Store state for potential repair
        current_states[session_id] = state
        session["state_id"] = session_id

        # Build response
        response = state.to_dict()
        response["session_id"] = session_id

        # Add single image specific info
        response["mode"] = "single_image"
        response["model_used"] = SINGLE_IMAGE_MODEL
        response["model_pipeline"] = MODEL_PIPELINE
        response["model_vlm"] = MODEL_VLM

        if state.image_path and os.path.exists(state.image_path):
            response["image"] = f"static/images/{state.timestamp}.png"
            response["filename"] = state.timestamp

        if not state.plan_valid:
            response["error"] = f"Plan generation failed: {state.plan_error}"

        # Parse parameters for customizer UI
        if state.scad_code:
            params = parse_parameters_from_scad(state.scad_code)
            design_desc = state.design_brief.description if state.design_brief else "Single image model"
            essential_params = categorize_parameters_with_llm(
                client, state.scad_code, design_desc, MODEL_PIPELINE
            )
            response["parameters"] = parameters_to_dict(params, essential_params)

        return jsonify(response)

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({"error": f"Server error: {str(e)}"})


@app.route("/repair", methods=["POST"])
def repair():
    """
    Manual repair endpoint.

    DISABLED in CRAFT v2 during the Phase A cleanup. The v1 CodeRepairer
    path has been removed; user-hint-driven repair will be reintroduced
    through the unified-feedback stage (Phase B) which emits structured
    JSON Patch operations against the plan IR.
    """
    return jsonify({
        "error": "Manual /repair is temporarily disabled in CRAFT v2.",
        "detail": (
            "The legacy CodeRepairer path was removed as part of Phase A "
            "cleanup. Use /generate to re-run the VLM self-correction loop, "
            "or wait for the Phase B unified-feedback stage."
        ),
    }), 410


@app.route("/download/<filename>")
def download_scad(filename: str):
    """Download SCAD file."""
    return send_from_directory(SCAD_DIR, f"{filename}.scad", as_attachment=True)


@app.route("/download_plan/<filename>")
def download_plan(filename: str):
    """Download JSON plan file."""
    return send_from_directory(PLAN_DIR, f"{filename}.json", as_attachment=True)


@app.route("/download_stl/<filename>")
def download_stl(filename: str):
    """Download STL file."""
    return send_from_directory(STL_DIR, f"{filename}.stl", as_attachment=True)


@app.route("/generate-stl", methods=["POST"])
def generate_stl():
    """
    Generate STL file from current SCAD code.

    Expected request JSON:
    {
        "session_id": "string",  // optional, to retrieve from session
        "scad_code": "string",   // optional, if not using session
        "filename": "string"     // optional, timestamp-based if not provided
    }

    Returns:
    {
        "success": true/false,
        "stl_path": "path/to/file.stl",
        "error": "error message if failed"
    }
    """
    data = request.get_json()

    # Get SCAD code from request or session
    scad_code = data.get("scad_code")
    session_id = data.get("session_id")

    if not scad_code and session_id and session_id in current_states:
        state = current_states[session_id]
        scad_code = state.scad_code

    if not scad_code:
        return jsonify({
            "success": False,
            "error": "No SCAD code provided"
        }), 400

    # Generate filename
    filename = data.get("filename")
    if not filename:
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        filename = f"model_{timestamp}"

    # Ensure STL directory exists
    os.makedirs(STL_DIR, exist_ok=True)

    # Write SCAD code to temp file
    scad_path = os.path.join(SCAD_DIR, f"{filename}.scad")
    with open(scad_path, "w") as f:
        f.write(scad_code)

    # Export to STL (300s timeout for complex models)
    stl_path = os.path.join(STL_DIR, f"{filename}.stl")
    success, error = export_stl(scad_path, stl_path, timeout=300)

    if success:
        # Return relative path for frontend
        relative_stl_path = f"static/stl/{filename}.stl"
        return jsonify({
            "success": True,
            "stl_path": relative_stl_path,
            "filename": filename
        })
    else:
        return jsonify({
            "success": False,
            "error": error
        }), 500


@app.route("/regenerate", methods=["POST"])
def regenerate():
    """
    Regenerate CAD model with updated parameters.

    Expected request JSON:
    {
        "session_id": "string",
        "parameters": {
            "param_name": value,
            ...
        }
    }

    Returns: Same as /generate endpoint
    """
    data = request.get_json()
    session_id = data.get("session_id")
    new_params = data.get("parameters", {})

    if not session_id or session_id not in current_states:
        return jsonify({
            "success": False,
            "error": "Invalid session ID"
        }), 400

    state = current_states[session_id]

    if not state.scad_code:
        return jsonify({
            "success": False,
            "error": "No SCAD code in session"
        }), 400

    # Update parameters in SCAD code
    updated_code = update_multiple_parameters(state.scad_code, new_params)

    # Generate unique filename
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    filename = f"regenerated_{timestamp}"

    # Save updated SCAD code
    scad_path = os.path.join(SCAD_DIR, f"{filename}.scad")
    with open(scad_path, "w") as f:
        f.write(updated_code)

    # Render PNG
    image_filename = f"{filename}.png"
    image_path = os.path.join(IMAGE_DIR, image_filename)

    runner = OpenScadRunner(
        scad_path,
        image_path,
        render_mode=RenderMode.preview,
        imgsize=IMG_SIZE
    )

    if not runner.run():
        return jsonify({
            "success": False,
            "error": f"Render failed: {runner.get_errors()}"
        }), 500

    # Validate - create validator instance
    validator = Validator(PASS_THRESHOLD)
    validation = validator.validate(
        updated_code,
        state.design_brief.expected_parts if state.design_brief else [],
        state.design_brief.description if state.design_brief else "",
        scad_path,
        image_path
    )

    # Update session state
    state.scad_code = updated_code
    state.scad_path = scad_path
    state.image_path = image_path
    state.validation = validation

    # Parse parameters for frontend
    params = parse_parameters_from_scad(updated_code)
    param_dict = parameters_to_dict(params)

    return jsonify({
        "success": True,
        "image": image_filename,
        "code": updated_code,
        "validation": validation.to_dict(),
        "parameters": param_dict,
        "filename": filename
    })


@app.route("/healthz")
def healthz():
    """Health check endpoint."""
    return jsonify({
        "status": "ok",
        "model": MODEL_PRIMARY,
        "auto_repair": AUTO_REPAIR,
        "supported_models": SUPPORTED_MODELS,
        "kb_available": KB_AVAILABLE
    })


@app.route("/progress/<session_id>")
def progress_stream(session_id: str):
    """
    Server-Sent Events (SSE) endpoint for streaming progress updates.

    Client connects and receives real-time progress updates during generation:
    - Current stage (understanding, planning, compilation, rendering, VLM correction, etc.)
    - Progress percentage (0-100%)
    - Estimated time remaining
    - Stage-specific details

    Usage:
        const eventSource = new EventSource(`/progress/${sessionId}`);
        eventSource.onmessage = (e) => {
            const update = JSON.parse(e.data);
            updateProgressBar(update.progress * 100);
            updateETA(update.eta);
        };
        eventSource.onerror = () => eventSource.close();
    """
    def generate_progress():
        queue = get_progress_queue(session_id)
        timeout = 0  # Don't block
        while True:
            try:
                update = queue.get(timeout=timeout)
                yield f"data: {json.dumps(update)}\n\n"
            except:
                # Queue is empty, check if we should keep waiting
                if session_id in current_states:
                    # Still generating, keep connection open
                    yield ": heartbeat\n\n"
                    import time
                    time.sleep(0.1)
                else:
                    # Session done
                    break

    return Response(
        generate_progress(),
        mimetype="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        }
    )


# =============================================================================
# SETTINGS AND CONFIGURATION ENDPOINTS
# =============================================================================

@app.route("/api/settings", methods=["GET"])
def get_settings():
    """Get current model configuration and pipeline settings."""
    return jsonify({
        "models": {
            "primary": os.getenv("MODEL_PRIMARY", "gpt-4o"),
            "secondary": os.getenv("MODEL_SECONDARY", "gpt-4o"),
            "reasoning": os.getenv("MODEL_REASONING", "gpt-5.2"),
            "fast": os.getenv("MODEL_FAST", "gpt-4o"),
        },
        "pipeline": {
            "version": os.getenv("CRAFT_VERSION", "2"),
            "auto_repair": os.getenv("AUTO_REPAIR", "true").lower() == "true",
            "vlm_correction": os.getenv("USE_VLM_CORRECTION", "true").lower() == "true",
            "max_vlm_iterations": int(os.getenv("MAX_VLM_ITERATIONS", "1")),
            "component_verification": os.getenv("USE_COMPONENT_VERIFICATION", "true").lower() == "true",
            "max_plan_attempts": int(os.getenv("MAX_PLAN_ATTEMPTS", "2")),
        },
        "available_models": {
            "openai": ["gpt-4o", "gpt-4-turbo", "gpt-4", "gpt-3.5-turbo"],
        },
        "has_gemini_key": bool(os.getenv("GEMINI_API_KEY")),
        "has_openai_key": bool(os.getenv("OPENAI_API_KEY")),
    })


@app.route("/api/settings", methods=["POST"])
def update_settings():
    """Update model configuration dynamically."""
    try:
        data = request.get_json()

        # Update model configurations
        if "models" in data:
            models = data["models"]
            if "primary" in models:
                os.environ["MODEL_PRIMARY"] = models["primary"]
            if "secondary" in models:
                os.environ["MODEL_SECONDARY"] = models["secondary"]
            if "reasoning" in models:
                os.environ["MODEL_REASONING"] = models["reasoning"]
            if "fast" in models:
                os.environ["MODEL_FAST"] = models["fast"]

        # Update pipeline settings
        if "pipeline" in data:
            pipeline_cfg = data["pipeline"]
            if "auto_repair" in pipeline_cfg:
                os.environ["AUTO_REPAIR"] = str(pipeline_cfg["auto_repair"]).lower()
            if "vlm_correction" in pipeline_cfg:
                os.environ["USE_VLM_CORRECTION"] = str(pipeline_cfg["vlm_correction"]).lower()
            if "max_vlm_iterations" in pipeline_cfg:
                os.environ["MAX_VLM_ITERATIONS"] = str(pipeline_cfg["max_vlm_iterations"])

        return jsonify({
            "success": True,
            "message": "Settings updated successfully",
            "settings": {
                "models": {
                    "primary": os.getenv("MODEL_PRIMARY"),
                    "secondary": os.getenv("MODEL_SECONDARY"),
                    "reasoning": os.getenv("MODEL_REASONING"),
                    "fast": os.getenv("MODEL_FAST"),
                }
            }
        })

    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400


# =============================================================================
# KNOWLEDGE BASE ENDPOINTS
# =============================================================================

@app.route("/kb/status")
def kb_status():
    """
    Get knowledge base status.

    Returns information about:
    - Whether KB is ready
    - Number of indexed components
    - Categories available
    """
    if not KB_AVAILABLE:
        return jsonify({
            "available": False,
            "message": "Knowledge base module not installed"
        })

    try:
        status = get_kb_status()
        return jsonify({
            "available": True,
            "ready": status.get("ready", False),
            "components_indexed": status.get("components_indexed", 0),
            "nopscadlib_exists": status.get("nopscadlib_exists", False),
            "retriever_stats": status.get("retriever_stats", {})
        })
    except Exception as e:
        return jsonify({
            "available": True,
            "ready": False,
            "error": str(e)
        })


@app.route("/kb/search", methods=["POST"])
def kb_search():
    """
    Search the knowledge base for components.

    Form data:
        query: Search query
        top_k: Number of results (default: 5)

    Returns:
        List of matching components with metadata
    """
    if not KB_AVAILABLE:
        return jsonify({
            "error": "Knowledge base not available"
        }), 400

    query = request.form.get("query", "").strip()
    if not query:
        return jsonify({"error": "Empty query"}), 400

    top_k = int(request.form.get("top_k", 5))

    try:
        # Check if KB is ready
        if not is_kb_ready():
            return jsonify({
                "error": "Knowledge base not initialized. Run build_knowledge_base.py first."
            }), 400

        # Search
        results = retrieve_components(query, top_k)

        # Format results
        components = []
        for result in results.results:
            comp = result.component
            components.append({
                "id": comp.id,
                "name": comp.name,
                "module_name": comp.module_name,
                "category": comp.category,
                "subcategory": comp.subcategory,
                "description": comp.description,
                "score": result.score,
                "parameters": [
                    {"name": p.name, "default": p.default_value}
                    for p in comp.parameters[:5]  # Limit params shown
                ]
            })

        return jsonify({
            "query": query,
            "total_found": results.total_found,
            "components": components
        })

    except Exception as e:
        return jsonify({"error": f"Search failed: {str(e)}"}), 500


@app.route("/kb/component/<component_id>")
def kb_component_detail(component_id: str):
    """
    Get detailed information about a specific KB component.

    Returns:
        Full component info including source code
    """
    if not KB_AVAILABLE:
        return jsonify({"error": "Knowledge base not available"}), 400

    try:
        retriever = get_retriever()
        component = retriever.get_component(component_id)

        if not component:
            return jsonify({"error": f"Component not found: {component_id}"}), 404

        # Get reference images
        ref_images = get_component_images(component_id)
        image_paths = {
            view: str(path) for view, path in ref_images.items() if path
        }

        return jsonify({
            "id": component.id,
            "name": component.name,
            "module_name": component.module_name,
            "category": component.category,
            "subcategory": component.subcategory,
            "description": component.description,
            "source_file": component.source_file,
            "module_code": component.module_code,
            "parameters": [
                {
                    "name": p.name,
                    "default": p.default_value,
                    "type": p.param_type
                }
                for p in component.parameters
            ],
            "keywords": component.keywords,
            "reference_images": image_paths
        })

    except Exception as e:
        return jsonify({"error": f"Failed to get component: {str(e)}"}), 500


# =============================================================================
# MAIN
# =============================================================================

if __name__ == "__main__":
    # Ensure directories exist
    os.makedirs(SCAD_DIR, exist_ok=True)
    os.makedirs(PLAN_DIR, exist_ok=True)
    os.makedirs(IMAGE_DIR, exist_ok=True)
    os.makedirs(STL_DIR, exist_ok=True)
    os.makedirs(UPLOAD_DIR, exist_ok=True)
    
    # Run Flask app
    port = int(os.getenv("PORT", 5000))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    app.run(host="0.0.0.0", port=port, debug=debug)


## Now the pipeline looks good.