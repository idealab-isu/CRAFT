#!/usr/bin/env python3
"""
CADence Qualitative Comparison Evaluation

Generates comparison figure for paper showing:
- GPT-4o (No Pipeline): Direct single API call
- GPT-5.2 (No Pipeline): Direct single API call
- CADence (No RAG): Full pipeline without knowledge base
- CADence (With RAG): Full pipeline with knowledge base

For each prompt:
- SCAD file
- Main PNG render
- 6-view multiview renders (front, back, left, right, top, bottom)
- STL file (for Chamfer distance computation)

Usage:
    python run_qualitative_comparison.py                    # Full run
    python run_qualitative_comparison.py --quick            # Quick test (1 per category)
    python run_qualitative_comparison.py --methods cadence  # Only CADence methods
    python run_qualitative_comparison.py --category complex # Only complex prompts
"""

import os
import sys
import json
import time
import argparse
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict, field
from typing import Dict, List, Any, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor
import traceback

# Add parent paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()


# =============================================================================
# COMPARISON PROMPTS
# =============================================================================

@dataclass
class ComparisonPrompt:
    """Prompt for qualitative comparison."""
    id: str
    text: str
    category: str  # easy, medium, complex
    expected_parts: List[str]
    source: str  # basic, mechanical, nopscadlib-style

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


# Easy prompts (3)
EASY_PROMPTS = [
    ComparisonPrompt(
        id="easy_01",
        text="A cube with 20mm sides",
        category="easy",
        expected_parts=["cube"],
        source="basic"
    ),
    ComparisonPrompt(
        id="easy_02",
        text="A hollow cylinder with outer diameter 30mm, inner diameter 20mm, height 40mm",
        category="easy",
        expected_parts=["outer_cylinder", "inner_hole"],
        source="basic"
    ),
    ComparisonPrompt(
        id="easy_03",
        text="A washer with 10mm outer diameter, 5mm inner hole, and 2mm thickness",
        category="easy",
        expected_parts=["washer", "hole"],
        source="basic"
    ),
]

# Medium prompts (3)
MEDIUM_PROMPTS = [
    ComparisonPrompt(
        id="medium_01",
        text="A coffee mug with a handle on the right side",
        category="medium",
        expected_parts=["body", "handle", "cavity"],
        source="custom"
    ),
    ComparisonPrompt(
        id="medium_02",
        text="A simple L-bracket 50mm x 30mm with 2 mounting holes",
        category="medium",
        expected_parts=["bracket", "holes"],
        source="mechanical"
    ),
    ComparisonPrompt(
        id="medium_03",
        text="A pulley wheel 40mm diameter with 8mm center bore and V-groove",
        category="medium",
        expected_parts=["wheel", "bore", "groove"],
        source="mechanical"
    ),
]

# Complex prompts (9) - 7 with NopSCADlib-style components
COMPLEX_PROMPTS = [
    # NopSCADlib-style prompts (7)
    ComparisonPrompt(
        id="complex_01",
        text="A NEMA 17 stepper motor mount plate with 4 M3 mounting holes in 31mm square pattern and 22mm center bore for the shaft",
        category="complex",
        expected_parts=["mount_plate", "mounting_holes", "center_bore"],
        source="nopscadlib-style"
    ),
    ComparisonPrompt(
        id="complex_02",
        text="Design a cooling fan mount for a 40mm axial fan attached to a NEMA17 stepper motor. The bracket should hold the fan 10mm away from the motor face with proper ventilation.",
        category="complex",
        expected_parts=["fan_mount", "motor_interface", "standoffs", "ventilation"],
        source="nopscadlib-style"
    ),
    ComparisonPrompt(
        id="complex_03",
        text="A linear rail carriage mount for MGN12 rail with M3 bolt holes on 20mm x 20mm pattern",
        category="complex",
        expected_parts=["carriage_block", "rail_slot", "bolt_holes"],
        source="nopscadlib-style"
    ),
    ComparisonPrompt(
        id="complex_04",
        text="A GT2 belt tensioner with idler pulley mount, 3mm pivot hole, and spring attachment point",
        category="complex",
        expected_parts=["tensioner_arm", "idler_mount", "pivot_hole", "spring_mount"],
        source="nopscadlib-style"
    ),
    ComparisonPrompt(
        id="complex_05",
        text="A shaft coupling for connecting 5mm motor shaft to 8mm leadscrew with set screw holes",
        category="complex",
        expected_parts=["coupling_body", "5mm_bore", "8mm_bore", "set_screw_holes"],
        source="nopscadlib-style"
    ),
    ComparisonPrompt(
        id="complex_06",
        text="A DIN rail mounting clip for 35mm top-hat rail with snap-fit mechanism",
        category="complex",
        expected_parts=["clip_body", "rail_groove", "snap_hooks", "mounting_surface"],
        source="nopscadlib-style"
    ),
    ComparisonPrompt(
        id="complex_07",
        text="An endstop mount bracket for mechanical limit switch with slot for position adjustment and M3 mounting holes",
        category="complex",
        expected_parts=["bracket", "switch_mount", "adjustment_slot", "mounting_holes"],
        source="nopscadlib-style"
    ),
    # Standard complex prompts (2)
    ComparisonPrompt(
        id="complex_08",
        text="An electronics enclosure box 100x60x30mm with lid, ventilation slots on sides, and cable gland hole",
        category="complex",
        expected_parts=["box", "lid", "ventilation_slots", "cable_hole"],
        source="mechanical"
    ),
    ComparisonPrompt(
        id="complex_09",
        text="A gear with 20 teeth, 50mm pitch diameter, 8mm thickness, and 10mm center bore with keyway",
        category="complex",
        expected_parts=["gear_body", "teeth", "center_bore", "keyway"],
        source="mechanical"
    ),
]

ALL_COMPARISON_PROMPTS = EASY_PROMPTS + MEDIUM_PROMPTS + COMPLEX_PROMPTS


def get_prompts_by_category(category: str) -> List[ComparisonPrompt]:
    """Get prompts for a specific category."""
    return [p for p in ALL_COMPARISON_PROMPTS if p.category == category]


def get_quick_prompts() -> List[ComparisonPrompt]:
    """Get 1 prompt per category for quick testing."""
    return [EASY_PROMPTS[0], MEDIUM_PROMPTS[0], COMPLEX_PROMPTS[0]]


# =============================================================================
# RESULT DATA STRUCTURES
# =============================================================================

@dataclass
class GenerationResult:
    """Result from a single generation attempt."""
    prompt_id: str
    method: str

    # Status
    success: bool = False
    compile_success: bool = False
    render_success: bool = False
    stl_success: bool = False
    multiview_success: bool = False

    # Paths
    scad_path: Optional[str] = None
    image_path: Optional[str] = None
    stl_path: Optional[str] = None
    multiview_dir: Optional[str] = None
    multiview_paths: Dict[str, str] = field(default_factory=dict)

    # Code
    code: Optional[str] = None
    code_length: int = 0

    # Timing
    generation_time: float = 0.0
    render_time: float = 0.0
    stl_time: float = 0.0
    multiview_time: float = 0.0
    total_time: float = 0.0

    # Error
    error: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


# =============================================================================
# GENERATION METHODS
# =============================================================================

# System prompt for direct baseline (no pipeline)
BASELINE_SYSTEM_PROMPT = """You are an expert OpenSCAD code generator. Generate valid, executable OpenSCAD code based on user descriptions.

Requirements:
1. Output ONLY valid OpenSCAD code - no explanations, no markdown, no comments about the design
2. The code must be syntactically correct and render without errors
3. Use appropriate primitives: cube(), cylinder(), sphere(), etc.
4. Use boolean operations: union(), difference(), intersection()
5. Use transformations: translate(), rotate(), scale()
6. Use modules for repeated elements
7. Include precise dimensions as specified
8. Make the design centered at origin when appropriate
9. Add appropriate $fn values for smooth curves (e.g., $fn=64 for cylinders)

Output format: Raw OpenSCAD code only, starting immediately with code (no ```openscad or other markers)."""


class DirectBaseline:
    """
    Direct LLM baseline - single API call to generate OpenSCAD.
    No pipeline stages, no validation, no repair.
    """

    def __init__(
        self,
        model: str = "gpt-4o",
        output_dir: Path = None,
        temperature: float = 0.2
    ):
        from openai import OpenAI
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.model = model
        self.output_dir = output_dir
        self.temperature = temperature

    def generate(self, prompt: ComparisonPrompt) -> GenerationResult:
        """Generate OpenSCAD code directly from prompt."""
        import re

        result = GenerationResult(
            prompt_id=prompt.id,
            method=f"{self.model}_baseline"
        )

        start_time = time.time()

        try:
            # Generate code via single API call
            response = self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": BASELINE_SYSTEM_PROMPT},
                    {"role": "user", "content": f"Generate OpenSCAD code for: {prompt.text}\n\nOutput only the raw OpenSCAD code, nothing else."}
                ],
                temperature=0.0,  # Deterministic output for reproducibility
            )

            raw_code = response.choices[0].message.content.strip()

            # Clean up code (remove markdown if present)
            if "```" in raw_code:
                pattern = r"```(?:openscad|scad)?\s*\n?(.*?)```"
                match = re.search(pattern, raw_code, re.DOTALL)
                if match:
                    raw_code = match.group(1)

            result.code = raw_code.strip()
            result.code_length = len(result.code)
            result.generation_time = time.time() - start_time
            result.success = True

        except Exception as e:
            result.error = str(e)
            result.generation_time = time.time() - start_time

        result.total_time = time.time() - start_time
        return result


class CADencePipeline:
    """
    Full CADence pipeline for generation.
    Supports RAG toggle via use_kb parameter.
    """

    def __init__(
        self,
        use_kb: bool = True,
        output_dir: Path = None,
        pipeline_model: str = "gpt-4o",
        vlm_model: str = "gpt-5.2",
        use_vlm_correction: bool = True,
        max_vlm_iterations: int = 3,
        use_verification: bool = True
    ):
        self.use_kb = use_kb
        self.output_dir = output_dir
        self.pipeline_model = pipeline_model
        self.vlm_model = vlm_model
        self.use_vlm_correction = use_vlm_correction
        self.max_vlm_iterations = max_vlm_iterations
        self.use_verification = use_verification

        self._initialized = False

    def _init_components(self):
        """Lazily initialize pipeline components."""
        if self._initialized:
            return

        from openai import OpenAI
        from core.llm_client import create_unified_client
        from core import TextReasoner, Planner, Compiler, Validator
        from core.visual_corrector import VisualSelfCorrector
        from core.component_verifier import ComponentVerifier

        self.openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.client = create_unified_client(openai_client=self.openai_client)

        # Core components with hybrid model approach
        self.reasoner = TextReasoner(self.client, self.vlm_model, use_kb=self.use_kb)
        self.planner = Planner(self.client, self.vlm_model)
        self.compiler = Compiler(self.client, self.pipeline_model)
        self.validator = Validator(pass_threshold=0.80)

        # VLM correction
        if self.use_vlm_correction:
            self.visual_corrector = VisualSelfCorrector(
                client=self.client,
                model=self.vlm_model,
                max_iterations=self.max_vlm_iterations
            )

        # Component verification
        if self.use_verification:
            self.component_verifier = ComponentVerifier(
                client=self.client,
                model=self.vlm_model,
                max_iterations=3
            )

        self._initialized = True

    def generate(self, prompt: ComparisonPrompt) -> GenerationResult:
        """Generate using full CADence pipeline."""
        self._init_components()

        method_name = "cadence_with_rag" if self.use_kb else "cadence_no_rag"
        result = GenerationResult(
            prompt_id=prompt.id,
            method=method_name
        )

        start_time = time.time()

        try:
            # Stage 1: Understanding
            design_brief = self.reasoner.analyze(prompt.text)

            # Stage 2: Planning
            plan_result = self.planner.create_plan(design_brief, max_attempts=2)
            if not plan_result.valid:
                result.error = f"Planning failed: {plan_result.error}"
                result.total_time = time.time() - start_time
                return result

            # Stage 3: Compilation
            code = self.compiler.compile(plan_result.plan)
            result.code = code
            result.code_length = len(code)
            result.generation_time = time.time() - start_time

            # Save temporary SCAD for validation/correction
            temp_scad = self.output_dir / "temp" / f"{prompt.id}_temp.scad"
            temp_scad.parent.mkdir(parents=True, exist_ok=True)
            with open(temp_scad, "w") as f:
                f.write(code)

            # Stage 4: Validate and render check
            from utils.openscad_runner import OpenScadRunner, RenderMode

            temp_image = self.output_dir / "temp" / f"{prompt.id}_temp.png"
            runner = OpenScadRunner(
                str(temp_scad),
                str(temp_image),
                render_mode=RenderMode.preview
            )
            render_ok = runner.run()

            if not render_ok:
                result.error = f"Initial render failed: {runner.get_errors()}"
                result.compile_success = False
                result.total_time = time.time() - start_time
                return result

            result.compile_success = True

            # Stage 5: VLM Self-Correction (if enabled)
            if self.use_vlm_correction:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                vlm_result = self.visual_corrector.run_correction_loop(
                    scad_code=code,
                    original_prompt=prompt.text,
                    expected_parts=prompt.expected_parts,
                    scad_path=str(temp_scad),
                    timestamp=f"{timestamp}_{prompt.id}"
                )

                if vlm_result.final_code and vlm_result.final_code != code:
                    code = vlm_result.final_code
                    result.code = code
                    result.code_length = len(code)

            # Stage 6: Component Verification (if enabled)
            if self.use_verification:
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

                # Update temp scad with latest code
                with open(temp_scad, "w") as f:
                    f.write(code)

                verif_result = self.component_verifier.verify_and_fix(
                    scad_code=code,
                    expected_parts=prompt.expected_parts,
                    original_prompt=prompt.text,
                    scad_path=str(temp_scad),
                    timestamp=f"{timestamp}_{prompt.id}"
                )

                if verif_result.final_code and verif_result.final_code != code:
                    code = verif_result.final_code
                    result.code = code
                    result.code_length = len(code)

            result.success = True

        except Exception as e:
            result.error = str(e)
            traceback.print_exc()

        result.total_time = time.time() - start_time
        return result


# =============================================================================
# QUALITATIVE COMPARISON RUNNER
# =============================================================================

class QualitativeComparisonRunner:
    """
    Main runner for qualitative comparison evaluation.

    Generates outputs for all 4 methods across all prompts.
    """

    def __init__(
        self,
        output_dir: str = "./comparison_results",
        methods: List[str] = None
    ):
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.output_dir = Path(output_dir) / self.timestamp

        # Default: all 4 methods
        self.methods = methods or ["gpt4o_baseline", "gpt52_baseline", "cadence_no_rag", "cadence_with_rag"]

        # Create directory structure
        self._setup_directories()

        # Initialize generators
        self.generators = {}
        self._init_generators()

    def _setup_directories(self):
        """Create output directory structure."""
        self.output_dir.mkdir(parents=True, exist_ok=True)

        for method in self.methods:
            method_dir = self.output_dir / method
            (method_dir / "scad").mkdir(parents=True, exist_ok=True)
            (method_dir / "images").mkdir(parents=True, exist_ok=True)
            (method_dir / "stl").mkdir(parents=True, exist_ok=True)
            (method_dir / "multiview").mkdir(parents=True, exist_ok=True)

        # Temp directory for intermediate files
        (self.output_dir / "temp").mkdir(exist_ok=True)

    def _init_generators(self):
        """Initialize generation methods."""
        if "gpt4o_baseline" in self.methods:
            self.generators["gpt4o_baseline"] = DirectBaseline(
                model="gpt-4o",
                output_dir=self.output_dir / "gpt4o_baseline"
            )

        if "gpt52_baseline" in self.methods:
            self.generators["gpt52_baseline"] = DirectBaseline(
                model="gpt-5.2",
                output_dir=self.output_dir / "gpt52_baseline"
            )

        if "cadence_no_rag" in self.methods:
            self.generators["cadence_no_rag"] = CADencePipeline(
                use_kb=False,
                output_dir=self.output_dir / "cadence_no_rag"
            )

        if "cadence_with_rag" in self.methods:
            self.generators["cadence_with_rag"] = CADencePipeline(
                use_kb=True,
                output_dir=self.output_dir / "cadence_with_rag"
            )

    def _save_scad(self, result: GenerationResult, method: str) -> str:
        """Save SCAD code to file."""
        if not result.code:
            return None

        scad_path = self.output_dir / method / "scad" / f"{result.prompt_id}.scad"
        with open(scad_path, "w") as f:
            f.write(result.code)

        return str(scad_path)

    def _render_image(self, scad_path: str, method: str, prompt_id: str) -> Tuple[bool, str]:
        """Render main image."""
        from utils.openscad_runner import OpenScadRunner, RenderMode

        image_path = self.output_dir / method / "images" / f"{prompt_id}.png"

        runner = OpenScadRunner(
            scad_path,
            str(image_path),
            render_mode=RenderMode.preview,
            imgsize=(800, 600)
        )

        success = runner.run()
        return success, str(image_path) if success else None

    def _render_multiview(self, scad_path: str, method: str, prompt_id: str) -> Tuple[bool, str, Dict[str, str]]:
        """Render 6 orthographic views."""
        from utils.rendering import MultiViewRenderer, ORTHO_VIEWS

        multiview_dir = self.output_dir / method / "multiview" / prompt_id
        multiview_dir.mkdir(parents=True, exist_ok=True)

        renderer = MultiViewRenderer(
            imgsize=(400, 400),
            distance=200
        )

        view_paths = renderer.render_all_views(
            scad_path,
            str(multiview_dir),
            prefix="view",
            views=ORTHO_VIEWS
        )

        success = len(view_paths) == 6
        return success, str(multiview_dir), view_paths

    def _export_stl(self, scad_path: str, method: str, prompt_id: str) -> Tuple[bool, str]:
        """Export to STL format."""
        from utils.openscad_runner import export_stl

        stl_path = self.output_dir / method / "stl" / f"{prompt_id}.stl"

        success, error = export_stl(scad_path, str(stl_path), timeout=300)
        return success, str(stl_path) if success else None

    def run_single(self, prompt: ComparisonPrompt, method: str) -> GenerationResult:
        """Run a single prompt through a single method."""
        print(f"    [{method}] Generating...")

        # Generate code
        generator = self.generators[method]
        result = generator.generate(prompt)

        if not result.success or not result.code:
            print(f"    [{method}] FAILED: {result.error}")
            return result

        # Save SCAD
        scad_path = self._save_scad(result, method)
        result.scad_path = scad_path

        if not scad_path:
            result.success = False
            return result

        # Render main image
        render_start = time.time()
        render_ok, image_path = self._render_image(scad_path, method, result.prompt_id)
        result.render_success = render_ok
        result.image_path = image_path
        result.render_time = time.time() - render_start

        if not render_ok:
            print(f"    [{method}] Render failed")
            result.compile_success = False
        else:
            result.compile_success = True

        # Render multiview (even if main render failed, try anyway)
        if scad_path:
            multiview_start = time.time()
            mv_ok, mv_dir, mv_paths = self._render_multiview(scad_path, method, result.prompt_id)
            result.multiview_success = mv_ok
            result.multiview_dir = mv_dir
            result.multiview_paths = mv_paths
            result.multiview_time = time.time() - multiview_start

        # Export STL
        if scad_path:
            stl_start = time.time()
            stl_ok, stl_path = self._export_stl(scad_path, method, result.prompt_id)
            result.stl_success = stl_ok
            result.stl_path = stl_path
            result.stl_time = time.time() - stl_start

        # Update total time
        result.total_time = result.generation_time + result.render_time + result.multiview_time + result.stl_time

        status = "OK" if result.render_success else "FAIL"
        print(f"    [{method}] {status} - gen={result.generation_time:.1f}s, render={result.render_success}, stl={result.stl_success}")

        return result

    def run_prompt(self, prompt: ComparisonPrompt) -> Dict[str, GenerationResult]:
        """Run all methods on a single prompt."""
        results = {}

        for method in self.methods:
            results[method] = self.run_single(prompt, method)
            time.sleep(1)  # Brief pause between API calls

        return results

    def run_all(self, prompts: List[ComparisonPrompt]) -> Dict[str, Dict[str, GenerationResult]]:
        """Run full comparison on all prompts."""
        all_results = {}

        print(f"\n{'='*70}")
        print("CADence Qualitative Comparison Evaluation")
        print(f"{'='*70}")
        print(f"Output directory: {self.output_dir}")
        print(f"Methods: {', '.join(self.methods)}")
        print(f"Prompts: {len(prompts)}")
        print(f"  Easy: {len([p for p in prompts if p.category == 'easy'])}")
        print(f"  Medium: {len([p for p in prompts if p.category == 'medium'])}")
        print(f"  Complex: {len([p for p in prompts if p.category == 'complex'])}")
        print(f"{'='*70}\n")

        # Save prompts metadata
        prompts_path = self.output_dir / "prompts.json"
        with open(prompts_path, "w") as f:
            json.dump([p.to_dict() for p in prompts], f, indent=2)

        for i, prompt in enumerate(prompts):
            print(f"\n[{i+1}/{len(prompts)}] {prompt.id}: {prompt.text[:50]}...")

            results = self.run_prompt(prompt)
            all_results[prompt.id] = results

            # Save intermediate results
            self._save_results(all_results)

        # Generate comparison grid
        print("\n" + "="*70)
        print("Generating comparison grid...")
        self._generate_comparison_grid(prompts, all_results)

        # Final summary
        self._print_summary(prompts, all_results)

        return all_results

    def _save_results(self, results: Dict[str, Dict[str, GenerationResult]]):
        """Save results to JSON."""
        results_path = self.output_dir / "results.json"

        # Convert to serializable format
        serializable = {}
        for prompt_id, method_results in results.items():
            serializable[prompt_id] = {}
            for method, result in method_results.items():
                serializable[prompt_id][method] = result.to_dict()

        with open(results_path, "w") as f:
            json.dump(serializable, f, indent=2)

    def _generate_comparison_grid(self, prompts: List[ComparisonPrompt], results: Dict[str, Dict[str, GenerationResult]]):
        """Generate comparison grid image."""
        try:
            from PIL import Image, ImageDraw, ImageFont
            import numpy as np
        except ImportError:
            print("PIL not available, skipping grid generation")
            return

        # Grid parameters
        cell_width = 400
        cell_height = 300
        header_height = 60
        row_label_width = 200
        padding = 5

        n_cols = len(self.methods)
        n_rows = len(prompts)

        # Calculate total size
        total_width = row_label_width + n_cols * cell_width + (n_cols + 1) * padding
        total_height = header_height + n_rows * cell_height + (n_rows + 1) * padding

        # Create image
        grid = Image.new('RGB', (total_width, total_height), color=(40, 44, 52))
        draw = ImageDraw.Draw(grid)

        # Try to load font
        try:
            font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
            header_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 16)
        except:
            font = ImageFont.load_default()
            header_font = font

        # Method labels (header)
        method_labels = {
            "gpt4o_baseline": "GPT-4o",
            "gpt52_baseline": "GPT-5.2",
            "cadence_no_rag": "CADence (No RAG)",
            "cadence_with_rag": "CADence (With RAG)"
        }

        for col, method in enumerate(self.methods):
            x = row_label_width + col * cell_width + col * padding + cell_width // 2
            y = header_height // 2
            label = method_labels.get(method, method)
            draw.text((x, y), label, fill=(200, 200, 200), font=header_font, anchor="mm")

        # Draw cells
        for row, prompt in enumerate(prompts):
            # Row label
            y_center = header_height + row * cell_height + row * padding + cell_height // 2

            # Truncate prompt text
            label_text = prompt.id
            draw.text((10, y_center), label_text, fill=(150, 150, 150), font=font, anchor="lm")

            for col, method in enumerate(self.methods):
                x = row_label_width + col * cell_width + col * padding
                y = header_height + row * cell_height + row * padding

                # Get result
                if prompt.id in results and method in results[prompt.id]:
                    result = results[prompt.id][method]

                    if result.render_success and result.image_path and os.path.exists(result.image_path):
                        # Load and resize image
                        try:
                            img = Image.open(result.image_path)
                            img = img.resize((cell_width - padding*2, cell_height - padding*2), Image.Resampling.LANCZOS)
                            grid.paste(img, (x + padding, y + padding))
                        except Exception as e:
                            # Draw error cell
                            draw.rectangle([x, y, x + cell_width, y + cell_height], outline=(100, 100, 100))
                            draw.text((x + cell_width//2, y + cell_height//2), "Load Error", fill=(200, 100, 100), font=font, anchor="mm")
                    else:
                        # Draw failed cell
                        draw.rectangle([x, y, x + cell_width, y + cell_height], outline=(100, 100, 100))
                        draw.text((x + cell_width//2, y + cell_height//2), "Failed", fill=(200, 100, 100), font=font, anchor="mm")
                else:
                    # No result
                    draw.rectangle([x, y, x + cell_width, y + cell_height], outline=(100, 100, 100))
                    draw.text((x + cell_width//2, y + cell_height//2), "No Result", fill=(150, 150, 150), font=font, anchor="mm")

        # Save grid
        grid_path = self.output_dir / "comparison_grid.png"
        grid.save(grid_path)
        print(f"Comparison grid saved to: {grid_path}")

    def _print_summary(self, prompts: List[ComparisonPrompt], results: Dict[str, Dict[str, GenerationResult]]):
        """Print summary statistics."""
        print("\n" + "="*70)
        print("SUMMARY")
        print("="*70)

        for method in self.methods:
            method_results = [results[p.id][method] for p in prompts if p.id in results and method in results[p.id]]

            if not method_results:
                continue

            n = len(method_results)
            compile_rate = sum(1 for r in method_results if r.compile_success) / n * 100
            render_rate = sum(1 for r in method_results if r.render_success) / n * 100
            stl_rate = sum(1 for r in method_results if r.stl_success) / n * 100
            avg_time = sum(r.total_time for r in method_results) / n

            print(f"\n{method}:")
            print(f"  Compile: {compile_rate:.1f}%")
            print(f"  Render:  {render_rate:.1f}%")
            print(f"  STL:     {stl_rate:.1f}%")
            print(f"  Avg Time: {avg_time:.1f}s")

        print("\n" + "="*70)
        print(f"Results saved to: {self.output_dir}")
        print("="*70)


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="CADence Qualitative Comparison Evaluation",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python run_qualitative_comparison.py                      # Full run (15 prompts x 4 methods)
    python run_qualitative_comparison.py --quick              # Quick test (3 prompts x 4 methods)
    python run_qualitative_comparison.py --methods cadence    # Only CADence methods
    python run_qualitative_comparison.py --category complex   # Only complex prompts
    python run_qualitative_comparison.py --output ./my_results  # Custom output directory
        """
    )

    parser.add_argument("--quick", action="store_true",
                        help="Quick test with 1 prompt per category")
    parser.add_argument("--category", type=str, choices=["easy", "medium", "complex"],
                        help="Run only prompts from this category")
    parser.add_argument("--methods", type=str, default="all",
                        choices=["all", "baseline", "cadence", "gpt4o", "gpt52", "cadence_rag", "cadence_no_rag"],
                        help="Which methods to run")
    parser.add_argument("--output", type=str, default="./comparison_results",
                        help="Output directory")
    parser.add_argument("--prompt-ids", type=str, nargs="+",
                        help="Run specific prompt IDs only")

    args = parser.parse_args()

    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    # Determine prompts
    if args.quick:
        prompts = get_quick_prompts()
    elif args.category:
        prompts = get_prompts_by_category(args.category)
    elif args.prompt_ids:
        prompts = [p for p in ALL_COMPARISON_PROMPTS if p.id in args.prompt_ids]
    else:
        prompts = ALL_COMPARISON_PROMPTS

    if not prompts:
        print("ERROR: No prompts selected")
        sys.exit(1)

    # Determine methods
    if args.methods == "all":
        methods = ["gpt4o_baseline", "gpt52_baseline", "cadence_no_rag", "cadence_with_rag"]
    elif args.methods == "baseline":
        methods = ["gpt4o_baseline", "gpt52_baseline"]
    elif args.methods == "cadence":
        methods = ["cadence_no_rag", "cadence_with_rag"]
    elif args.methods == "gpt4o":
        methods = ["gpt4o_baseline"]
    elif args.methods == "gpt52":
        methods = ["gpt52_baseline"]
    elif args.methods == "cadence_rag":
        methods = ["cadence_with_rag"]
    elif args.methods == "cadence_no_rag":
        methods = ["cadence_no_rag"]
    else:
        methods = ["gpt4o_baseline", "gpt52_baseline", "cadence_no_rag", "cadence_with_rag"]

    # Run comparison
    runner = QualitativeComparisonRunner(
        output_dir=args.output,
        methods=methods
    )

    results = runner.run_all(prompts)

    print(f"\nDone! Results saved to: {runner.output_dir}")


if __name__ == "__main__":
    main()
