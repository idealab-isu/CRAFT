"""
CADence - Unified Text-to-CAD Pipeline

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
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, Optional, List

from flask import Flask, render_template, request, jsonify, send_from_directory, session
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
from openai import OpenAI

# Import CADence modules
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
from core.validator import Validator, ValidationResult, validate_scad
from core.repair import CodeRepairer, RepairOrchestrator
from core.llm_client import create_unified_client
from core.visual_corrector import VisualSelfCorrector, VisualCorrectionResult, VLMAssessment
from core.component_verifier import ComponentVerifier, ComponentVerificationOutput
from core.prompt_enhancer import PromptEnhancer, EnhancementResult

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

# Hybrid model configuration: Use fast model for pipeline, reasoning model for VLM
MODEL_PIPELINE = "gpt-4o"      # Fast model for Understanding, Planning, Compilation
MODEL_VLM = "gpt-5.2"          # Reasoning model for Visual Self-Correction

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
MAX_VLM_ITERATIONS = int(os.getenv("MAX_VLM_ITERATIONS", "3"))
USE_VLM_CORRECTION = os.getenv("USE_VLM_CORRECTION", "true").lower() == "true"

# Component Verification settings (runs after VLM correction)
MAX_COMPONENT_ITERATIONS = int(os.getenv("MAX_COMPONENT_ITERATIONS", "3"))
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

        return result


# =============================================================================
# PIPELINE ORCHESTRATOR
# =============================================================================

class CADencePipeline:
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
        use_kb: bool = True
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

        # Hybrid model approach:
        # - GPT-5.2 (reasoning model) for critical reasoning tasks: Understanding & Planning
        # - GPT-4o (fast model) for deterministic tasks: Vision Analysis, Compilation, Repair
        self.reasoner = TextReasoner(client, model_vlm, use_kb=use_kb)  # GPT-5.2 for better understanding
        self.planner = Planner(client, model_vlm)  # GPT-5.2 for better planning logic
        
        # Keep GPT-4o for faster, more deterministic tasks
        self.vision_analyzer = VisionAnalyzer(client, model_pipeline)
        self.compiler = Compiler(client, model_pipeline)
        self.validator = Validator(PASS_THRESHOLD)
        self.repair_orchestrator = RepairOrchestrator(
            client, model_pipeline, max_repair_attempts
        )

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

        # Prompt Enhancer (uses fast model for efficiency)
        self.prompt_enhancer = PromptEnhancer(
            client=client,
            model=model_pipeline  # Use fast model for enhancement
        )
    
    def run_text(self, prompt: str) -> PipelineState:
        """
        Run pipeline with text input.

        Args:
            prompt: Natural language description

        Returns:
            PipelineState with results
        """
        state = PipelineState(input_type="text", original_input=prompt)

        # Stage 0: Prompt Enhancement (if KB available)
        # This transforms vague prompts into specific ones using KB knowledge
        working_prompt = prompt
        if self.use_kb:
            try:
                enhancement = self.prompt_enhancer.enhance(prompt)
                if enhancement.was_enhanced:
                    working_prompt = enhancement.enhanced_prompt
                    state.prompt_enhanced = True
                    state.enhanced_prompt = enhancement.enhanced_prompt
                    state.enhancement_notes = enhancement.enhancement_notes
                    print(f"[Pipeline] Prompt enhanced: {prompt[:50]}... → {working_prompt[:80]}...")
            except Exception as e:
                print(f"[Pipeline] Prompt enhancement failed (continuing with original): {e}")

        # Stage 1: Understanding (with automatic KB detection)
        # Pass original prompt so hardware filtering knows what user actually requested
        state.design_brief = self.reasoner.analyze(
            working_prompt,
            original_prompt=prompt  # Original user prompt before enhancement
        )

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
        pipeline with 6 iterations of VLM correction.

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

    def _run_core_pipeline(self, state: PipelineState) -> PipelineState:
        """
        Run the core pipeline stages.

        Args:
            state: Pipeline state with design_brief populated

        Returns:
            Updated state
        """
        # Stage 3: Planning
        plan_result = self.planner.create_plan(
            state.design_brief,
            self.max_plan_attempts
        )

        state.plan = plan_result.plan
        state.plan_valid = plan_result.valid
        state.plan_error = plan_result.error
        state.plan_attempts = plan_result.attempts

        if not plan_result.valid:
            return state

        # Stage 4: Compilation (with KB component injection)
        kb_components = state.design_brief.kb_components if hasattr(state.design_brief, 'kb_components') else None
        state.scad_code = self.compiler.compile(state.plan, kb_components=kb_components)

        # Save files
        self._save_files(state)

        # Stage 5: Render initial preview
        self._render(state)

        # Stage 6 & 7: VLM Self-Correction Loop (replaces old validation + repair)
        if self.use_vlm_correction:
            state = self._run_vlm_correction(state)
        else:
            # Fallback to old validation + repair
            state.validation = self.validator.validate(
                state.scad_code,
                state.design_brief.expected_parts,
                state.design_brief.description,
                state.scad_path,
                state.image_path
            )

            if self.auto_repair and not state.validation.passed:
                state = self._auto_repair(state)

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

        # Run the visual correction loop (with KB components for reference images)
        kb_components = state.design_brief.kb_components if hasattr(state.design_brief, 'kb_components') else None
        correction_result = self.visual_corrector.run_correction_loop(
            scad_code=state.scad_code,
            original_prompt=state.design_brief.description,
            expected_parts=state.design_brief.expected_parts,
            scad_path=state.scad_path,
            timestamp=state.timestamp,
            kb_components=kb_components
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

        # Run the component verification loop with TIERED parts (with KB components for reference images)
        kb_components = state.design_brief.kb_components if hasattr(state.design_brief, 'kb_components') else None
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
            kb_components=kb_components
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

    def _auto_repair(self, state: PipelineState) -> PipelineState:
        """Attempt automatic repair."""
        original_code = state.scad_code
        
        for attempt in range(self.max_repair_attempts):
            if state.validation.passed:
                break
            
            state.repair_attempts += 1
            
            # Repair
            repairer = CodeRepairer(self.client, self.model_pipeline)
            result = repairer.repair(
                state.scad_code,
                state.validation,
                state.design_brief.description,
                "",  # No user hint for auto-repair
                state.plan
            )
            
            if result.success:
                state.scad_code = result.code
                
                # Re-save and re-render
                self._save_files(state)
                self._render(state)
                
                # Re-validate
                state.validation = self.validator.validate(
                    state.scad_code,
                    state.design_brief.expected_parts,
                    state.design_brief.description,
                    state.scad_path,
                    state.image_path
                )
        
        return state
    
    def repair_with_hint(
        self,
        state: PipelineState,
        hint: str
    ) -> PipelineState:
        """
        Manual repair with user hint.
        
        Args:
            state: Current pipeline state
            hint: User's feedback/hint
            
        Returns:
            Updated state
        """
        repairer = CodeRepairer(self.client, self.model_pipeline)
        result = repairer.repair(
            state.scad_code,
            state.validation,
            state.design_brief.description,
            hint,
            state.plan
        )
        
        if result.success:
            state.scad_code = result.code
            state.repair_attempts += 1
            
            # Update timestamp for new files
            state.timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
            
            # Re-save and re-render
            self._save_files(state)
            self._render(state)
            
            # Re-validate
            state.validation = self.validator.validate(
                state.scad_code,
                state.design_brief.expected_parts,
                state.design_brief.description,
                state.scad_path,
                state.image_path
            )
        
        return state
    
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

def get_pipeline(use_kb: bool = True, model_pipeline: Optional[str] = None) -> CADencePipeline:
    """Get a pipeline instance with hybrid model configuration.

    Uses GPT-5.2 for critical reasoning (Understanding, Planning, VLM correction)
    and GPT-4o for deterministic tasks (Vision Analysis, Compilation, Repair).
    """
    return CADencePipeline(
        client,
        model_pipeline=model_pipeline or MODEL_PIPELINE,
        model_vlm=MODEL_VLM,
        use_kb=use_kb
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
    """
    text = request.form.get("text", "").strip()
    if not text:
        return jsonify({"error": "Empty prompt"})

    # RAG toggle - default to true for backward compatibility
    use_rag_str = request.form.get("use_rag", "true").lower()
    use_rag = use_rag_str in ("true", "1", "yes", "on")

    try:
        # Get pipeline with hybrid model configuration
        pipeline = get_pipeline(use_kb=use_rag)

        # Run pipeline
        state = pipeline.run_text(text)

        # Store state for potential repair
        session_id = secrets.token_hex(8)
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

        # Get pipeline with hybrid model configuration
        pipeline = get_pipeline(use_kb=True)

        # Run pipeline
        state = pipeline.run_vision(image_paths, view_names)
        
        # Store state
        session_id = secrets.token_hex(8)
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
    OpenSCAD code through the CADence pipeline.

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

        # Get pipeline with hybrid model configuration
        # KB is disabled for single image mode (concept images, not NopSCADlib components)
        pipeline = get_pipeline(use_kb=False)

        # Run single image pipeline
        state = pipeline.run_single_image(image_path)

        # Store state for potential repair
        session_id = secrets.token_hex(8)
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

    Form data:
        hint: User's feedback/hint
        session_id: Session ID from previous generation
        model: Model to use for repair (optional, defaults to gpt-4o)
    """
    hint = request.form.get("hint", "").strip()
    session_id = request.form.get("session_id") or session.get("state_id")
    model = request.form.get("model", MODEL_PRIMARY)

    # Validate model
    if model not in SUPPORTED_MODELS:
        return jsonify({"error": f"Unsupported model: {model}"})

    if not session_id or session_id not in current_states:
        return jsonify({"error": "No active session. Please generate first."})

    state = current_states[session_id]

    if not state.scad_code:
        return jsonify({"error": "No code to repair"})

    try:
        # Get pipeline with selected model
        pipeline = get_pipeline(model_pipeline=model)

        # Run repair with hint
        state = pipeline.repair_with_hint(state, hint)

        # Update stored state
        current_states[session_id] = state

        # Build response
        response = state.to_dict()
        response["session_id"] = session_id
        response["model_used"] = model

        if state.image_path and os.path.exists(state.image_path):
            response["image"] = f"static/images/{state.timestamp}.png"
            response["filename"] = state.timestamp

        # Parse parameters for customizer UI
        if state.scad_code:
            params = parse_parameters_from_scad(state.scad_code)
            response["parameters"] = parameters_to_dict(params)

        return jsonify(response)

    except Exception as e:
        return jsonify({"error": f"Repair error: {str(e)}"})


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