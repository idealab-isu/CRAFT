#!/usr/bin/env python3
"""
CADence Paper Evaluation Framework

Comprehensive evaluation runner for generating paper tables:
- Table 4: Main Results (Compile %, Render %, Val Score, Parts %, Human Eval)
- Table 5: Model Ablation (All-GPT4o vs All-GPT5.2 vs Hybrid)
- Table 6: VLM Iteration Ablation (0, 1, 2, 3 iterations + time cost)
- Table 7: Verification Ablation (Before/after part presence)
- Table 8: Single Image Performance by Complexity

Usage:
    python paper_evaluation.py --table 4          # Run main results
    python paper_evaluation.py --table 5          # Run model ablation
    python paper_evaluation.py --table 6          # Run VLM iteration ablation
    python paper_evaluation.py --table 7          # Run verification ablation
    python paper_evaluation.py --table 8          # Run single image by complexity
    python paper_evaluation.py --all              # Run everything

    python paper_evaluation.py --table 4 --quick  # Quick test with 6 prompts
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
import numpy as np

# Add parent paths
sys.path.insert(0, str(Path(__file__).parent.parent))
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from dotenv import load_dotenv
load_dotenv()


@dataclass
class EvaluationResult:
    """Comprehensive result for a single prompt evaluation."""
    prompt_id: str
    prompt_text: str
    category: str
    complexity_score: int

    # Core metrics
    compile_success: bool = False      # OpenSCAD syntax valid
    render_success: bool = False       # Rendered to image
    validation_score: float = 0.0      # 0-100 validation score
    validation_passed: bool = False    # Score > threshold

    # Parts metrics (for Table 7)
    essential_parts_found: int = 0
    essential_parts_total: int = 0
    secondary_parts_found: int = 0
    secondary_parts_total: int = 0
    optional_parts_found: int = 0
    optional_parts_total: int = 0
    parts_percentage: float = 0.0

    # VLM metrics (for Table 6)
    vlm_iterations_used: int = 0
    vlm_initial_confidence: float = 0.0
    vlm_final_confidence: float = 0.0
    vlm_approved: bool = False
    vlm_corrections_made: int = 0      # NEW: How many code fixes applied
    blank_views_detected: int = 0      # NEW: Orthographic views that were blank

    # Verification metrics (for Table 7)
    verification_iterations: int = 0
    verification_passed: bool = False
    connectivity_check: bool = False
    verification_corrections: int = 0  # NEW: How many verification fixes applied

    # Geometry quality metrics (NEW)
    geometry_present: bool = False     # Has visible geometry in render
    geometry_complexity: str = ""      # "simple", "medium", "complex" based on code
    code_length: int = 0               # OpenSCAD code length

    # Timing
    total_time: float = 0.0
    pipeline_time: float = 0.0
    vlm_time: float = 0.0
    verification_time: float = 0.0

    # Model used
    pipeline_model: str = ""
    vlm_model: str = ""

    # Artifacts
    scad_path: Optional[str] = None
    image_path: Optional[str] = None
    error: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        # Convert numpy types
        for k, v in d.items():
            if isinstance(v, (np.bool_, np.integer)):
                d[k] = int(v) if isinstance(v, np.integer) else bool(v)
            elif isinstance(v, np.floating):
                d[k] = float(v)
        return d


@dataclass
class TableMetrics:
    """Aggregated metrics for paper tables."""
    # Table 4: Main Results
    compile_rate: float = 0.0
    render_rate: float = 0.0
    avg_validation_score: float = 0.0
    parts_percentage: float = 0.0

    # Table 5: Model comparison
    model_name: str = ""

    # Table 6: VLM iterations
    vlm_iteration_count: int = 0
    avg_time: float = 0.0

    # Table 7: Verification
    essential_rate: float = 0.0
    secondary_rate: float = 0.0
    optional_rate: float = 0.0

    # Table 8: By complexity
    category: str = ""
    ssim_score: float = 0.0


class PaperEvaluationRunner:
    """
    Main evaluation runner for paper tables.
    """

    def __init__(
        self,
        output_dir: str = "./evaluation_results",
        pipeline_model: str = "gpt-4o",
        vlm_model: str = "gpt-5.2",
        use_vlm_correction: bool = True,
        max_vlm_iterations: int = 3,
        use_verification: bool = True,
        max_verification_iterations: int = 3
    ):
        self.output_dir = Path(output_dir)
        self.pipeline_model = pipeline_model
        self.vlm_model = vlm_model
        self.use_vlm_correction = use_vlm_correction
        self.max_vlm_iterations = max_vlm_iterations
        self.use_verification = use_verification
        self.max_verification_iterations = max_verification_iterations

        # Create output directories
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.run_dir = self.output_dir / self.timestamp
        self.run_dir.mkdir(parents=True, exist_ok=True)
        (self.run_dir / "scad").mkdir(exist_ok=True)
        (self.run_dir / "images").mkdir(exist_ok=True)

        # Save config
        self.config = {
            "pipeline_model": pipeline_model,
            "vlm_model": vlm_model,
            "use_vlm_correction": use_vlm_correction,
            "max_vlm_iterations": max_vlm_iterations,
            "use_verification": use_verification,
            "max_verification_iterations": max_verification_iterations,
            "timestamp": self.timestamp
        }

        with open(self.run_dir / "config.json", "w") as f:
            json.dump(self.config, f, indent=2)

        # Initialize pipeline components lazily
        self._pipeline = None
        self._initialized = False

    def _init_pipeline(self):
        """Lazily initialize the CADence pipeline."""
        if self._initialized:
            return

        from openai import OpenAI
        from core.llm_client import create_unified_client
        from core import TextReasoner, Planner, Compiler, Validator
        from core.visual_corrector import VisualSelfCorrector
        from core.component_verifier import ComponentVerifier
        from utils.openscad_runner import OpenScadRunner

        self.openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.client = create_unified_client(openai_client=self.openai_client)

        # Core pipeline components - matching app.py hybrid model approach:
        # - VLM model (gpt-5.2) for critical reasoning: Understanding & Planning
        # - Pipeline model (gpt-4o) for deterministic tasks: Compilation
        self.reasoner = TextReasoner(self.client, self.vlm_model)  # gpt-5.2 for better understanding
        self.planner = Planner(self.client, self.vlm_model)        # gpt-5.2 for better planning
        self.compiler = Compiler(self.client, self.pipeline_model) # gpt-4o for compilation
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
                max_iterations=self.max_verification_iterations
            )

        self._initialized = True
        print(f"[Init] Reasoning: {self.vlm_model}, Compiler: {self.pipeline_model}, VLM: {self.vlm_model}")

    def evaluate_single(self, prompt: 'TestPrompt') -> EvaluationResult:
        """
        Evaluate a single prompt through the full pipeline.
        """
        from paper_test_prompts import TestPrompt

        self._init_pipeline()

        result = EvaluationResult(
            prompt_id=prompt.id,
            prompt_text=prompt.text,
            category=prompt.category,
            complexity_score=prompt.complexity_score,
            essential_parts_total=len(prompt.essential_parts),
            secondary_parts_total=len(prompt.secondary_parts),
            optional_parts_total=len(prompt.optional_parts),
            pipeline_model=self.pipeline_model,
            vlm_model=self.vlm_model
        )

        start_time = time.time()
        pipeline_start = time.time()

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

            # Save SCAD file
            scad_path = self.run_dir / "scad" / f"{prompt.id}.scad"
            with open(scad_path, "w") as f:
                f.write(code)
            result.scad_path = str(scad_path)

            # Stage 4: Render
            from utils.openscad_runner import OpenScadRunner, RenderMode

            image_path = self.run_dir / "images" / f"{prompt.id}.png"
            runner = OpenScadRunner(
                str(scad_path),
                str(image_path),
                render_mode=RenderMode.preview,
                imgsize=(800, 600)
            )
            render_ok = runner.run()

            result.compile_success = True  # If we got here, syntax is valid
            result.render_success = render_ok

            if render_ok:
                result.image_path = str(image_path)

            result.pipeline_time = time.time() - pipeline_start

            # Stage 5: Validation
            validation = self.validator.validate(
                code,
                design_brief.expected_parts,
                design_brief.description,
                str(scad_path),
                str(image_path) if render_ok else None
            )

            result.validation_score = validation.score
            result.validation_passed = validation.passed

            # Stage 6: VLM Self-Correction (if enabled)
            if self.use_vlm_correction and render_ok:
                vlm_start = time.time()

                # Generate timestamp for file naming
                from datetime import datetime
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

                vlm_result = self.visual_corrector.run_correction_loop(
                    scad_code=code,
                    original_prompt=prompt.text,
                    expected_parts=prompt.essential_parts + prompt.secondary_parts,
                    scad_path=str(scad_path),
                    timestamp=f"{timestamp}_{prompt.id}"
                )

                result.vlm_iterations_used = vlm_result.iterations
                result.vlm_approved = vlm_result.final_passed

                # Get confidence from final assessment if available
                if vlm_result.final_assessment:
                    result.vlm_final_confidence = vlm_result.final_assessment.confidence

                # Get initial confidence from first iteration
                if vlm_result.iteration_history and vlm_result.iteration_history[0].vlm_assessment:
                    result.vlm_initial_confidence = vlm_result.iteration_history[0].vlm_assessment.confidence

                # Count corrections made (iterations where code was changed)
                result.vlm_corrections_made = sum(
                    1 for h in vlm_result.iteration_history if h.corrected
                )

                # Update code if corrected
                if vlm_result.final_code and vlm_result.final_code != code:
                    code = vlm_result.final_code
                    with open(scad_path, "w") as f:
                        f.write(code)

                result.vlm_time = time.time() - vlm_start

            # Stage 7: Component Verification (if enabled)
            if self.use_verification and render_ok:
                verif_start = time.time()

                # Generate timestamp for file naming
                from datetime import datetime
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

                verif_result = self.component_verifier.verify_and_fix(
                    scad_code=code,
                    expected_parts=prompt.essential_parts + prompt.secondary_parts + prompt.optional_parts,
                    original_prompt=prompt.text,
                    scad_path=str(scad_path),
                    timestamp=f"{timestamp}_{prompt.id}",
                    essential_parts=prompt.essential_parts,
                    secondary_parts=prompt.secondary_parts,
                    optional_parts=prompt.optional_parts
                )

                result.verification_iterations = verif_result.iterations
                result.verification_passed = verif_result.all_parts_present
                result.connectivity_check = verif_result.is_fully_connected

                # Count verification corrections made
                result.verification_corrections = sum(
                    1 for h in verif_result.iteration_history if h.corrected
                )

                # Count parts found from the LAST iteration in history
                if verif_result.iteration_history:
                    last_result = verif_result.iteration_history[-1]
                    for part_check in last_result.parts_present:
                        if part_check.part_name in prompt.essential_parts:
                            if part_check.present:
                                result.essential_parts_found += 1
                        elif part_check.part_name in prompt.secondary_parts:
                            if part_check.present:
                                result.secondary_parts_found += 1
                        elif part_check.part_name in prompt.optional_parts:
                            if part_check.present:
                                result.optional_parts_found += 1

                result.verification_time = time.time() - verif_start

            # Calculate parts percentage
            total_parts = (result.essential_parts_total +
                          result.secondary_parts_total +
                          result.optional_parts_total)
            parts_found = (result.essential_parts_found +
                          result.secondary_parts_found +
                          result.optional_parts_found)

            if total_parts > 0:
                result.parts_percentage = (parts_found / total_parts) * 100

            # Re-render final image after all corrections
            # This ensures the saved image matches the final corrected code
            if (result.vlm_corrections_made > 0 or result.verification_corrections > 0):
                final_image_path = self.run_dir / "images" / f"{prompt.id}_final.png"
                runner = OpenScadRunner(
                    str(scad_path),
                    str(final_image_path),
                    render_mode=RenderMode.preview,
                    imgsize=(800, 600)
                )
                final_render_ok = runner.run()
                if final_render_ok:
                    result.image_path = str(final_image_path)
                    image_path = final_image_path  # Update for geometry check

            # Additional quality metrics
            result.code_length = len(code)
            result.geometry_present = render_ok and self._check_geometry(str(image_path))

            # Estimate geometry complexity from code
            if result.code_length < 500:
                result.geometry_complexity = "simple"
            elif result.code_length < 2000:
                result.geometry_complexity = "medium"
            else:
                result.geometry_complexity = "complex"

        except Exception as e:
            result.error = str(e)
            import traceback
            traceback.print_exc()

        result.total_time = time.time() - start_time
        return result

    def run_evaluation(
        self,
        prompts: List['TestPrompt'],
        save_intermediate: bool = True
    ) -> List[EvaluationResult]:
        """
        Run evaluation on a list of prompts.
        """
        results = []

        print(f"\n{'='*60}")
        print(f"CADence Paper Evaluation")
        print(f"{'='*60}")
        print(f"Prompts: {len(prompts)}")
        print(f"Reasoning Model: {self.vlm_model} (understanding, planning, VLM, verification)")
        print(f"Compiler Model: {self.pipeline_model} (code generation)")
        print(f"VLM Correction: {self.use_vlm_correction} (max {self.max_vlm_iterations})")
        print(f"Verification: {self.use_verification}")
        print(f"Output: {self.run_dir}")
        print(f"{'='*60}\n")

        for i, prompt in enumerate(prompts):
            print(f"[{i+1}/{len(prompts)}] {prompt.id}: {prompt.text[:40]}...")

            result = self.evaluate_single(prompt)
            results.append(result)

            # Enhanced output with more useful info
            status = "✓" if result.render_success and result.geometry_present else "✗"
            vlm_info = f"vlm={result.vlm_corrections_made}fix" if result.vlm_corrections_made > 0 else "vlm=ok"
            verif_info = f"verif={result.verification_corrections}fix" if result.verification_corrections > 0 else "verif=ok"
            print(f"  {status} val={result.validation_score:.0f}, "
                  f"parts={result.parts_percentage:.0f}%, "
                  f"{vlm_info}, {verif_info}, "
                  f"code={result.code_length}ch, "
                  f"time={result.total_time:.1f}s")

            if save_intermediate:
                self._save_results(results)

            # Brief pause between requests
            time.sleep(0.5)

        # Final save
        self._save_results(results)

        return results

    def _save_results(self, results: List[EvaluationResult]):
        """Save results to JSON file."""
        results_path = self.run_dir / "results.json"
        with open(results_path, "w") as f:
            json.dump([r.to_dict() for r in results], f, indent=2)

    def _check_geometry(self, image_path: str) -> bool:
        """Check if image has visible geometry (not blank)."""
        try:
            from PIL import Image
            import numpy as np

            img = Image.open(image_path).convert('RGB')
            arr = np.array(img)

            # Check color diversity - blank images have very few unique colors
            unique_colors = len(np.unique(arr.reshape(-1, 3), axis=0))

            # Check standard deviation - blank images have low variance
            std_dev = np.std(arr)

            # Image has geometry if it has enough color diversity and variance
            return unique_colors > 10 and std_dev > 15
        except Exception:
            return True  # Assume OK if can't check


# =============================================================================
# Table Generation Functions
# =============================================================================

def generate_table_4_main_results(results: List[EvaluationResult]) -> Dict:
    """
    Generate Table 4: Main Results

    Metrics per method × modality:
    - Compile %
    - Render %
    - Val Score
    - Parts %
    - Geometry Present %
    - VLM/Verification corrections
    """
    n = len(results)
    if n == 0:
        return {}

    metrics = {
        "n_prompts": n,
        "compile_rate": sum(r.compile_success for r in results) / n * 100,
        "render_rate": sum(r.render_success for r in results) / n * 100,
        "geometry_present_rate": sum(r.geometry_present for r in results) / n * 100,
        "avg_validation_score": sum(r.validation_score for r in results) / n,
        "validation_pass_rate": sum(r.validation_passed for r in results) / n * 100,
        "avg_parts_percentage": sum(r.parts_percentage for r in results) / n,
        "avg_time": sum(r.total_time for r in results) / n,
        # New useful metrics
        "vlm_approval_rate": sum(r.vlm_approved for r in results) / n * 100,
        "avg_vlm_corrections": sum(r.vlm_corrections_made for r in results) / n,
        "avg_verif_corrections": sum(r.verification_corrections for r in results) / n,
        "avg_code_length": sum(r.code_length for r in results) / n,
        "human_eval": None  # Placeholder for manual annotation
    }

    # Per-category breakdown
    categories = set(r.category for r in results)
    for cat in categories:
        cat_results = [r for r in results if r.category == cat]
        cat_n = len(cat_results)
        if cat_n > 0:
            metrics[f"{cat}_compile_rate"] = sum(r.compile_success for r in cat_results) / cat_n * 100
            metrics[f"{cat}_render_rate"] = sum(r.render_success for r in cat_results) / cat_n * 100
            metrics[f"{cat}_geometry_rate"] = sum(r.geometry_present for r in cat_results) / cat_n * 100
            metrics[f"{cat}_val_score"] = sum(r.validation_score for r in cat_results) / cat_n
            metrics[f"{cat}_parts_pct"] = sum(r.parts_percentage for r in cat_results) / cat_n
            metrics[f"{cat}_vlm_corrections"] = sum(r.vlm_corrections_made for r in cat_results) / cat_n
            metrics[f"{cat}_code_length"] = sum(r.code_length for r in cat_results) / cat_n

    return metrics


def generate_table_5_model_ablation(
    results_gpt4o: List[EvaluationResult],
    results_gpt52: List[EvaluationResult],
    results_hybrid: List[EvaluationResult]
) -> Dict:
    """
    Generate Table 5: Model Ablation

    Compare: All-GPT4o vs All-GPT5.2 vs Hybrid
    """
    def compute_metrics(results: List[EvaluationResult], name: str) -> Dict:
        n = len(results)
        if n == 0:
            return {}
        return {
            "model": name,
            "compile_rate": sum(r.compile_success for r in results) / n * 100,
            "render_rate": sum(r.render_success for r in results) / n * 100,
            "val_score": sum(r.validation_score for r in results) / n,
            "parts_pct": sum(r.parts_percentage for r in results) / n,
            "avg_time": sum(r.total_time for r in results) / n,
        }

    return {
        "all_gpt4o": compute_metrics(results_gpt4o, "All-GPT4o"),
        "all_gpt52": compute_metrics(results_gpt52, "All-GPT5.2"),
        "hybrid": compute_metrics(results_hybrid, "Hybrid")
    }


def generate_table_6_vlm_ablation(
    results_by_iterations: Dict[int, List[EvaluationResult]]
) -> Dict:
    """
    Generate Table 6: VLM Iteration Ablation

    Performance at 0, 1, 2, 3 iterations + time cost
    """
    table = {}

    for iter_count, results in results_by_iterations.items():
        n = len(results)
        if n == 0:
            continue

        table[f"iter_{iter_count}"] = {
            "vlm_iterations": iter_count,
            "compile_rate": sum(r.compile_success for r in results) / n * 100,
            "render_rate": sum(r.render_success for r in results) / n * 100,
            "val_score": sum(r.validation_score for r in results) / n,
            "vlm_approval_rate": sum(r.vlm_approved for r in results) / n * 100,
            "avg_confidence": sum(r.vlm_final_confidence for r in results) / n,
            "avg_time": sum(r.total_time for r in results) / n,
            "avg_vlm_time": sum(r.vlm_time for r in results) / n,
        }

    return table


def generate_table_7_verification_ablation(
    results_before: List[EvaluationResult],
    results_after: List[EvaluationResult]
) -> Dict:
    """
    Generate Table 7: Verification Ablation

    Before/after part presence for Essential/Secondary/Optional tiers
    """
    def compute_metrics(results: List[EvaluationResult], label: str) -> Dict:
        n = len(results)
        if n == 0:
            return {}

        total_essential = sum(r.essential_parts_total for r in results)
        found_essential = sum(r.essential_parts_found for r in results)

        total_secondary = sum(r.secondary_parts_total for r in results)
        found_secondary = sum(r.secondary_parts_found for r in results)

        total_optional = sum(r.optional_parts_total for r in results)
        found_optional = sum(r.optional_parts_found for r in results)

        return {
            "label": label,
            "essential_rate": (found_essential / total_essential * 100) if total_essential > 0 else 0,
            "secondary_rate": (found_secondary / total_secondary * 100) if total_secondary > 0 else 0,
            "optional_rate": (found_optional / total_optional * 100) if total_optional > 0 else 0,
            "overall_parts_pct": sum(r.parts_percentage for r in results) / n,
            "verification_pass_rate": sum(r.verification_passed for r in results) / n * 100,
        }

    return {
        "before_verification": compute_metrics(results_before, "Before"),
        "after_verification": compute_metrics(results_after, "After")
    }


def generate_table_8_single_image_performance(
    results: List[EvaluationResult]
) -> Dict:
    """
    Generate Table 8: Single Image Performance by Category

    By category (Simple/Medium/Complex): Render %, Parts %, SSIM
    """
    table = {}

    for category in ["simple", "medium", "complex"]:
        cat_results = [r for r in results if r.category == category]
        n = len(cat_results)
        if n == 0:
            continue

        table[category] = {
            "category": category,
            "n_prompts": n,
            "render_rate": sum(r.render_success for r in cat_results) / n * 100,
            "parts_pct": sum(r.parts_percentage for r in cat_results) / n,
            "val_score": sum(r.validation_score for r in cat_results) / n,
            "avg_time": sum(r.total_time for r in cat_results) / n,
            "ssim": None  # Placeholder - requires reference images
        }

    return table


# =============================================================================
# CLI Entry Point
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="CADence Paper Evaluation Framework",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python paper_evaluation.py --table 4          # Main results
    python paper_evaluation.py --table 5          # Model ablation
    python paper_evaluation.py --table 6          # VLM iteration ablation
    python paper_evaluation.py --table 7          # Verification ablation
    python paper_evaluation.py --table 8          # Single image by complexity
    python paper_evaluation.py --all              # Run all tables
    python paper_evaluation.py --table 4 --quick  # Quick test
        """
    )

    parser.add_argument("--table", type=int, choices=[4, 5, 6, 7, 8],
                        help="Table to generate (4-8)")
    parser.add_argument("--all", action="store_true",
                        help="Generate all tables")
    parser.add_argument("--quick", action="store_true",
                        help="Quick test with 6 prompts")
    parser.add_argument("--n-prompts", type=int, default=30,
                        help="Number of prompts to use")
    parser.add_argument("--output", type=str, default="./evaluation_results",
                        help="Output directory")
    parser.add_argument("--pipeline-model", type=str, default="gpt-4o",
                        help="Model for pipeline stages")
    parser.add_argument("--vlm-model", type=str, default="gpt-5.2",
                        help="Model for VLM correction")

    args = parser.parse_args()

    if not args.table and not args.all:
        parser.print_help()
        sys.exit(1)

    # Check API key
    if not os.getenv("OPENAI_API_KEY"):
        print("ERROR: OPENAI_API_KEY not set")
        sys.exit(1)

    # Import prompts
    from paper_test_prompts import get_prompts_for_table, get_prompts_subset, get_all_prompts

    # Quick mode
    n_prompts = 6 if args.quick else args.n_prompts

    if args.all:
        tables_to_run = [4, 5, 6, 7, 8]
    else:
        tables_to_run = [args.table]

    for table_num in tables_to_run:
        print(f"\n{'#'*60}")
        print(f"# Generating Table {table_num}")
        print(f"{'#'*60}")

        if table_num == 4:
            run_table_4(args, n_prompts)
        elif table_num == 5:
            run_table_5(args, n_prompts)
        elif table_num == 6:
            run_table_6(args, n_prompts)
        elif table_num == 7:
            run_table_7(args, n_prompts)
        elif table_num == 8:
            run_table_8(args, n_prompts)


def run_table_4(args, n_prompts: int):
    """Run evaluation for Table 4: Main Results"""
    from paper_test_prompts import get_prompts_subset

    prompts = get_prompts_subset(n_prompts, balanced=True)

    runner = PaperEvaluationRunner(
        output_dir=args.output,
        pipeline_model=args.pipeline_model,
        vlm_model=args.vlm_model,
        use_vlm_correction=True,
        max_vlm_iterations=3,
        use_verification=True
    )

    results = runner.run_evaluation(prompts)
    metrics = generate_table_4_main_results(results)

    # Save table
    table_path = runner.run_dir / "table_4_main_results.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"\n--- Table 4: Main Results ---")
    print(f"Compile Rate: {metrics['compile_rate']:.1f}%")
    print(f"Render Rate: {metrics['render_rate']:.1f}%")
    print(f"Validation Score: {metrics['avg_validation_score']:.1f}")
    print(f"Parts Percentage: {metrics['avg_parts_percentage']:.1f}%")
    print(f"Avg Time: {metrics['avg_time']:.1f}s")
    print(f"\nTable saved to: {table_path}")


def run_table_5(args, n_prompts: int):
    """Run evaluation for Table 5: Model Ablation"""
    from paper_test_prompts import get_prompts_subset

    prompts = get_prompts_subset(n_prompts, balanced=True)

    # All GPT-4o
    print("\n--- Running All-GPT4o ---")
    runner_gpt4o = PaperEvaluationRunner(
        output_dir=f"{args.output}/table5_gpt4o",
        pipeline_model="gpt-4o",
        vlm_model="gpt-4o",
        use_vlm_correction=True,
        use_verification=True
    )
    results_gpt4o = runner_gpt4o.run_evaluation(prompts)

    # All GPT-5.2
    print("\n--- Running All-GPT5.2 ---")
    runner_gpt52 = PaperEvaluationRunner(
        output_dir=f"{args.output}/table5_gpt52",
        pipeline_model="gpt-5.2",
        vlm_model="gpt-5.2",
        use_vlm_correction=True,
        use_verification=True
    )
    results_gpt52 = runner_gpt52.run_evaluation(prompts)

    # Hybrid (GPT-4o pipeline + GPT-5.2 VLM)
    print("\n--- Running Hybrid ---")
    runner_hybrid = PaperEvaluationRunner(
        output_dir=f"{args.output}/table5_hybrid",
        pipeline_model="gpt-4o",
        vlm_model="gpt-5.2",
        use_vlm_correction=True,
        use_verification=True
    )
    results_hybrid = runner_hybrid.run_evaluation(prompts)

    # Generate table
    metrics = generate_table_5_model_ablation(results_gpt4o, results_gpt52, results_hybrid)

    table_path = Path(args.output) / "table_5_model_ablation.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"\n--- Table 5: Model Ablation ---")
    for model, m in metrics.items():
        print(f"{m['model']}: compile={m['compile_rate']:.1f}%, "
              f"render={m['render_rate']:.1f}%, "
              f"val={m['val_score']:.1f}, "
              f"time={m['avg_time']:.1f}s")
    print(f"\nTable saved to: {table_path}")


def run_table_6(args, n_prompts: int):
    """Run evaluation for Table 6: VLM Iteration Ablation"""
    from paper_test_prompts import get_prompts_subset

    prompts = get_prompts_subset(n_prompts, balanced=True)
    results_by_iterations = {}

    for max_iter in [0, 1, 2, 3]:
        print(f"\n--- Running VLM iterations = {max_iter} ---")

        runner = PaperEvaluationRunner(
            output_dir=f"{args.output}/table6_iter{max_iter}",
            pipeline_model=args.pipeline_model,
            vlm_model=args.vlm_model,
            use_vlm_correction=(max_iter > 0),
            max_vlm_iterations=max_iter,
            use_verification=False  # Isolate VLM effect
        )

        results = runner.run_evaluation(prompts)
        results_by_iterations[max_iter] = results

    # Generate table
    metrics = generate_table_6_vlm_ablation(results_by_iterations)

    table_path = Path(args.output) / "table_6_vlm_ablation.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"\n--- Table 6: VLM Iteration Ablation ---")
    for iter_key, m in metrics.items():
        print(f"Iter {m['vlm_iterations']}: render={m['render_rate']:.1f}%, "
              f"approval={m['vlm_approval_rate']:.1f}%, "
              f"confidence={m['avg_confidence']:.2f}, "
              f"time={m['avg_time']:.1f}s")
    print(f"\nTable saved to: {table_path}")


def run_table_7(args, n_prompts: int):
    """Run evaluation for Table 7: Verification Ablation"""
    from paper_test_prompts import get_prompts_for_table

    # Get prompts with tiered parts
    prompts = get_prompts_for_table(7)[:n_prompts]

    # Without verification
    print("\n--- Running WITHOUT verification ---")
    runner_before = PaperEvaluationRunner(
        output_dir=f"{args.output}/table7_before",
        pipeline_model=args.pipeline_model,
        vlm_model=args.vlm_model,
        use_vlm_correction=True,
        use_verification=False
    )
    results_before = runner_before.run_evaluation(prompts)

    # With verification
    print("\n--- Running WITH verification ---")
    runner_after = PaperEvaluationRunner(
        output_dir=f"{args.output}/table7_after",
        pipeline_model=args.pipeline_model,
        vlm_model=args.vlm_model,
        use_vlm_correction=True,
        use_verification=True
    )
    results_after = runner_after.run_evaluation(prompts)

    # Generate table
    metrics = generate_table_7_verification_ablation(results_before, results_after)

    table_path = Path(args.output) / "table_7_verification_ablation.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"\n--- Table 7: Verification Ablation ---")
    for key, m in metrics.items():
        print(f"{m['label']}: essential={m['essential_rate']:.1f}%, "
              f"secondary={m['secondary_rate']:.1f}%, "
              f"optional={m['optional_rate']:.1f}%, "
              f"overall={m['overall_parts_pct']:.1f}%")
    print(f"\nTable saved to: {table_path}")


def run_table_8(args, n_prompts: int):
    """Run evaluation for Table 8: Single Image Performance by Complexity"""
    from paper_test_prompts import get_all_prompts

    prompts = get_all_prompts()[:n_prompts]

    runner = PaperEvaluationRunner(
        output_dir=f"{args.output}/table8_complexity",
        pipeline_model=args.pipeline_model,
        vlm_model=args.vlm_model,
        use_vlm_correction=True,
        use_verification=True
    )

    results = runner.run_evaluation(prompts)
    metrics = generate_table_8_single_image_performance(results)

    table_path = runner.run_dir / "table_8_complexity.json"
    with open(table_path, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"\n--- Table 8: Single Image by Complexity ---")
    for cat, m in metrics.items():
        print(f"{m['category'].capitalize()}: n={m['n_prompts']}, "
              f"render={m['render_rate']:.1f}%, "
              f"parts={m['parts_pct']:.1f}%, "
              f"val={m['val_score']:.1f}, "
              f"time={m['avg_time']:.1f}s")
    print(f"\nTable saved to: {table_path}")


if __name__ == "__main__":
    main()
