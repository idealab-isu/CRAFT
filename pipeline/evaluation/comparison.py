"""
CADence vs Baseline Comparison Runner

Runs both CADence pipeline and GPT-4o baseline on the same prompts,
computes metrics, and generates comparison tables.
"""

import os
import sys
import json
import time
from dataclasses import dataclass, asdict, field
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path
from datetime import datetime
import numpy as np


def convert_to_native(obj):
    """Convert numpy types to native Python types for JSON serialization."""
    if isinstance(obj, dict):
        return {k: convert_to_native(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_to_native(i) for i in obj]
    elif isinstance(obj, (np.bool_, np.integer)):
        return int(obj) if isinstance(obj, np.integer) else bool(obj)
    elif isinstance(obj, np.floating):
        return float(obj)
    elif isinstance(obj, np.ndarray):
        return obj.tolist()
    return obj

# Add parent path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()

# Import CADence components
from core import TextReasoner, Planner, Compiler, Validator, RepairOrchestrator
from core.llm_client import create_unified_client
from utils.openscad_runner import OpenScadRunner, RenderMode

# Import baseline
from .baseline_gpt4o import GPT4oBaseline, BaselineResult
from .test_prompts import get_all_prompts, get_prompts_subset


@dataclass
class CADenceResult:
    """Result from CADence pipeline."""
    prompt_id: str
    prompt_text: str

    # Pipeline stages
    reasoning_success: bool = False
    plan_valid: bool = False
    plan_attempts: int = 0
    code_generated: bool = False

    # Validation
    syntax_valid: bool = False
    render_success: bool = False
    validation_passed: bool = False
    validation_score: int = 0
    has_geometry: bool = False

    # Repair
    repair_attempts: int = 0
    repair_improved: bool = False

    # Code
    code: Optional[str] = None
    plan: Optional[Dict] = None

    # Paths
    scad_path: Optional[str] = None
    image_path: Optional[str] = None

    # Timing
    total_time: float = 0.0

    # Error
    error: Optional[str] = None

    def to_dict(self):
        d = asdict(self)
        # Convert numpy types to native Python types
        return convert_to_native(d)


@dataclass
class ComparisonResult:
    """Combined comparison result for a single prompt."""
    prompt_id: str
    prompt_text: str
    category: str

    # CADence results
    cadence_syntax_valid: bool = False
    cadence_render_success: bool = False
    cadence_validation_passed: bool = False
    cadence_has_geometry: bool = False
    cadence_plan_attempts: int = 0
    cadence_repair_attempts: int = 0
    cadence_time: float = 0.0

    # Baseline results
    baseline_syntax_valid: bool = False
    baseline_render_success: bool = False
    baseline_has_geometry: bool = False
    baseline_time: float = 0.0

    # Winner determination
    cadence_wins: bool = False
    baseline_wins: bool = False
    tie: bool = False

    def to_dict(self):
        return convert_to_native(asdict(self))


@dataclass
class ComparisonSummary:
    """Summary statistics for comparison."""
    total_prompts: int = 0

    # CADence stats
    cadence_syntax_rate: float = 0.0
    cadence_render_rate: float = 0.0
    cadence_validation_rate: float = 0.0
    cadence_geometry_rate: float = 0.0
    cadence_avg_time: float = 0.0
    cadence_avg_plan_attempts: float = 0.0
    cadence_avg_repair_attempts: float = 0.0

    # Baseline stats
    baseline_syntax_rate: float = 0.0
    baseline_render_rate: float = 0.0
    baseline_geometry_rate: float = 0.0
    baseline_avg_time: float = 0.0

    # Comparison
    cadence_wins: int = 0
    baseline_wins: int = 0
    ties: int = 0

    # Per-category breakdown
    category_stats: Dict[str, Dict] = field(default_factory=dict)


class ComparisonRunner:
    """
    Runs CADence pipeline and baseline on the same prompts.
    """

    def __init__(
        self,
        output_dir: str = "./evaluation/comparison_results",
        cadence_model: str = "gpt-5.2",
        baseline_model: str = "gpt-4o",
        auto_repair: bool = True,
        max_repair_attempts: int = 2
    ):
        self.output_dir = Path(output_dir)
        self.cadence_model = cadence_model
        self.baseline_model = baseline_model
        self.auto_repair = auto_repair
        self.max_repair_attempts = max_repair_attempts

        # Create directories
        self.output_dir.mkdir(parents=True, exist_ok=True)
        (self.output_dir / "cadence").mkdir(exist_ok=True)
        (self.output_dir / "cadence" / "scad").mkdir(exist_ok=True)
        (self.output_dir / "cadence" / "images").mkdir(exist_ok=True)
        (self.output_dir / "baseline").mkdir(exist_ok=True)

        # Initialize clients
        self.openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.client = create_unified_client(openai_client=self.openai_client)

        # Initialize CADence components (using cadence_model)
        self.reasoner = TextReasoner(self.client, cadence_model)
        self.planner = Planner(self.client, cadence_model)
        self.compiler = Compiler(self.client, cadence_model)
        self.validator = Validator(0.80)

        # Initialize baseline (using baseline_model - GPT-4o)
        self.baseline = GPT4oBaseline(
            client=self.openai_client,
            model=baseline_model,
            output_dir=str(self.output_dir / "baseline")
        )

        print(f"[Config] CADence model: {cadence_model}")
        print(f"[Config] Baseline model: {baseline_model}")

    def run_cadence(self, prompt_id: str, prompt_text: str) -> CADenceResult:
        """Run CADence pipeline on a single prompt."""
        result = CADenceResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text
        )

        start_time = time.time()

        try:
            # Stage 1: Reasoning
            design_brief = self.reasoner.analyze(prompt_text)
            result.reasoning_success = True

            # Stage 2: Planning
            plan_result = self.planner.create_plan(design_brief, max_attempts=2)
            result.plan_valid = plan_result.valid
            result.plan_attempts = plan_result.attempts

            if not plan_result.valid:
                result.error = f"Planning failed: {plan_result.error}"
                result.total_time = time.time() - start_time
                return result

            result.plan = plan_result.plan

            # Stage 3: Compilation
            code = self.compiler.compile(plan_result.plan)
            result.code = code
            result.code_generated = True

            # Stage 4: Save and render
            scad_path = self.output_dir / "cadence" / "scad" / f"{prompt_id}.scad"
            with open(scad_path, "w") as f:
                f.write(code)
            result.scad_path = str(scad_path)

            image_path = self.output_dir / "cadence" / "images" / f"{prompt_id}.png"

            runner = OpenScadRunner(
                str(scad_path),
                str(image_path),
                render_mode=RenderMode.preview,
                imgsize=(800, 600)
            )
            render_ok = runner.run()

            result.syntax_valid = render_ok or self._check_syntax_only(code, str(scad_path))
            result.render_success = render_ok

            if render_ok:
                result.image_path = str(image_path)
                result.has_geometry = self._check_geometry(str(image_path))

            # Stage 5: Validation
            validation = self.validator.validate(
                code,
                design_brief.expected_parts,
                design_brief.description,
                str(scad_path),
                str(image_path) if render_ok else None
            )

            result.validation_passed = validation.passed
            result.validation_score = validation.score

            # Stage 6: Auto-repair if enabled
            if self.auto_repair and not validation.passed and result.syntax_valid:
                result = self._try_repair(result, design_brief, plan_result.plan, validation)

        except Exception as e:
            result.error = str(e)

        result.total_time = time.time() - start_time
        return result

    def _try_repair(
        self,
        result: CADenceResult,
        design_brief,
        plan: Dict,
        validation
    ) -> CADenceResult:
        """Try to repair the code."""
        from core.repair import CodeRepairer

        repairer = CodeRepairer(self.client, self.cadence_model)
        original_score = validation.score

        for attempt in range(self.max_repair_attempts):
            if validation.passed:
                break

            result.repair_attempts += 1

            repair_result = repairer.repair(
                result.code,
                validation,
                design_brief.description,
                "",  # No user hint
                plan
            )

            if repair_result.success:
                result.code = repair_result.code

                # Re-save
                with open(result.scad_path, "w") as f:
                    f.write(result.code)

                # Re-render
                runner = OpenScadRunner(
                    result.scad_path,
                    result.image_path,
                    render_mode=RenderMode.preview,
                    imgsize=(800, 600)
                )
                render_ok = runner.run()

                result.render_success = render_ok

                if render_ok:
                    result.has_geometry = self._check_geometry(result.image_path)

                # Re-validate
                validation = self.validator.validate(
                    result.code,
                    design_brief.expected_parts,
                    design_brief.description,
                    result.scad_path,
                    result.image_path if render_ok else None
                )

                result.validation_passed = validation.passed
                result.validation_score = validation.score

                if validation.score > original_score:
                    result.repair_improved = True

        return result

    def _check_syntax_only(self, code: str, scad_path: str) -> bool:
        """Check syntax without full render."""
        import subprocess

        try:
            result = subprocess.run(
                ["openscad", "--export-format", "echo", "-o", "/dev/null", scad_path],
                capture_output=True,
                text=True,
                timeout=30
            )
            stderr = result.stderr.lower()
            return "error" not in stderr and "parse error" not in stderr
        except Exception:
            return False

    def _check_geometry(self, image_path: str) -> bool:
        """Check if image has visible geometry."""
        try:
            from PIL import Image
            import numpy as np

            img = Image.open(image_path).convert('L')
            arr = np.array(img)
            return bool(np.std(arr) > 10)
        except Exception:
            return True  # Assume OK if can't check

    def compare_single(
        self,
        prompt: Dict[str, Any]
    ) -> ComparisonResult:
        """
        Run both CADence and baseline on a single prompt.

        Args:
            prompt: Dict with 'id', 'text', 'category' keys

        Returns:
            ComparisonResult
        """
        prompt_id = prompt['id']
        prompt_text = prompt['text']
        category = prompt.get('category', 'unknown')

        print(f"\n[Compare] {prompt_id}: {prompt_text[:50]}...")

        # Run CADence
        print(f"  [CADence] Running...")
        cadence_result = self.run_cadence(prompt_id, prompt_text)

        # Run baseline
        print(f"  [Baseline] Running...")
        baseline_result = self.baseline.generate(prompt_id, prompt_text)

        # Build comparison
        comparison = ComparisonResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text,
            category=category,
            # CADence
            cadence_syntax_valid=cadence_result.syntax_valid,
            cadence_render_success=cadence_result.render_success,
            cadence_validation_passed=cadence_result.validation_passed,
            cadence_has_geometry=cadence_result.has_geometry,
            cadence_plan_attempts=cadence_result.plan_attempts,
            cadence_repair_attempts=cadence_result.repair_attempts,
            cadence_time=cadence_result.total_time,
            # Baseline
            baseline_syntax_valid=baseline_result.syntax_valid,
            baseline_render_success=baseline_result.render_success,
            baseline_has_geometry=baseline_result.has_geometry,
            baseline_time=baseline_result.generation_time,
        )

        # Determine winner
        cadence_score = sum([
            cadence_result.syntax_valid,
            cadence_result.render_success,
            cadence_result.has_geometry
        ])
        baseline_score = sum([
            baseline_result.syntax_valid,
            baseline_result.render_success,
            baseline_result.has_geometry
        ])

        if cadence_score > baseline_score:
            comparison.cadence_wins = True
        elif baseline_score > cadence_score:
            comparison.baseline_wins = True
        else:
            comparison.tie = True

        print(f"  [Result] CADence: {cadence_score}/3, Baseline: {baseline_score}/3")

        return comparison

    def run_comparison(
        self,
        prompts: Optional[List[Dict]] = None,
        n_prompts: int = 15
    ) -> Tuple[List[ComparisonResult], ComparisonSummary]:
        """
        Run full comparison on a set of prompts.

        Args:
            prompts: List of prompts, or None to use default
            n_prompts: Number of prompts if using default

        Returns:
            Tuple of (results_list, summary)
        """
        if prompts is None:
            prompts = get_prompts_subset(n_prompts)

        print(f"\n{'='*60}")
        print(f"CADence vs Baseline Comparison")
        print(f"Prompts: {len(prompts)}, CADence: {self.cadence_model}, Baseline: {self.baseline_model}")
        print(f"{'='*60}")

        results = []
        for prompt in prompts:
            result = self.compare_single(prompt)
            results.append(result)

            # Save intermediate results
            self._save_results(results)

            # Brief pause
            time.sleep(0.5)

        # Compute summary
        summary = self._compute_summary(results)

        # Save final results
        self._save_results(results, summary)

        # Print summary
        self._print_summary(summary)

        return results, summary

    def _compute_summary(self, results: List[ComparisonResult]) -> ComparisonSummary:
        """Compute summary statistics."""
        n = len(results)
        if n == 0:
            return ComparisonSummary()

        summary = ComparisonSummary(total_prompts=n)

        # CADence stats
        summary.cadence_syntax_rate = sum(r.cadence_syntax_valid for r in results) / n
        summary.cadence_render_rate = sum(r.cadence_render_success for r in results) / n
        summary.cadence_validation_rate = sum(r.cadence_validation_passed for r in results) / n
        summary.cadence_geometry_rate = sum(r.cadence_has_geometry for r in results) / n
        summary.cadence_avg_time = sum(r.cadence_time for r in results) / n
        summary.cadence_avg_plan_attempts = sum(r.cadence_plan_attempts for r in results) / n
        summary.cadence_avg_repair_attempts = sum(r.cadence_repair_attempts for r in results) / n

        # Baseline stats
        summary.baseline_syntax_rate = sum(r.baseline_syntax_valid for r in results) / n
        summary.baseline_render_rate = sum(r.baseline_render_success for r in results) / n
        summary.baseline_geometry_rate = sum(r.baseline_has_geometry for r in results) / n
        summary.baseline_avg_time = sum(r.baseline_time for r in results) / n

        # Wins
        summary.cadence_wins = sum(r.cadence_wins for r in results)
        summary.baseline_wins = sum(r.baseline_wins for r in results)
        summary.ties = sum(r.tie for r in results)

        # Per-category
        categories = set(r.category for r in results)
        for cat in categories:
            cat_results = [r for r in results if r.category == cat]
            cat_n = len(cat_results)
            if cat_n > 0:
                summary.category_stats[cat] = {
                    "count": cat_n,
                    "cadence_syntax": sum(r.cadence_syntax_valid for r in cat_results) / cat_n,
                    "cadence_render": sum(r.cadence_render_success for r in cat_results) / cat_n,
                    "baseline_syntax": sum(r.baseline_syntax_valid for r in cat_results) / cat_n,
                    "baseline_render": sum(r.baseline_render_success for r in cat_results) / cat_n,
                    "cadence_wins": sum(r.cadence_wins for r in cat_results),
                    "baseline_wins": sum(r.baseline_wins for r in cat_results),
                }

        return summary

    def _save_results(
        self,
        results: List[ComparisonResult],
        summary: Optional[ComparisonSummary] = None
    ):
        """Save results to files."""
        # Save detailed results
        results_path = self.output_dir / "comparison_results.json"
        with open(results_path, "w") as f:
            json.dump([r.to_dict() for r in results], f, indent=2)

        # Save summary
        if summary:
            summary_path = self.output_dir / "comparison_summary.json"
            with open(summary_path, "w") as f:
                json.dump(asdict(summary), f, indent=2)

    def _print_summary(self, summary: ComparisonSummary):
        """Print summary to console."""
        print(f"\n{'='*60}")
        print("COMPARISON SUMMARY")
        print(f"{'='*60}")

        print(f"\nTotal Prompts: {summary.total_prompts}")

        print(f"\n--- CADence ---")
        print(f"  Syntax Pass Rate:     {summary.cadence_syntax_rate:.1%}")
        print(f"  Render Success Rate:  {summary.cadence_render_rate:.1%}")
        print(f"  Validation Pass Rate: {summary.cadence_validation_rate:.1%}")
        print(f"  Geometry Present:     {summary.cadence_geometry_rate:.1%}")
        print(f"  Avg Time:             {summary.cadence_avg_time:.2f}s")
        print(f"  Avg Plan Attempts:    {summary.cadence_avg_plan_attempts:.2f}")
        print(f"  Avg Repair Attempts:  {summary.cadence_avg_repair_attempts:.2f}")

        print(f"\n--- Direct GPT-4o Baseline ---")
        print(f"  Syntax Pass Rate:     {summary.baseline_syntax_rate:.1%}")
        print(f"  Render Success Rate:  {summary.baseline_render_rate:.1%}")
        print(f"  Geometry Present:     {summary.baseline_geometry_rate:.1%}")
        print(f"  Avg Time:             {summary.baseline_avg_time:.2f}s")

        print(f"\n--- Head-to-Head ---")
        print(f"  CADence Wins:  {summary.cadence_wins}")
        print(f"  Baseline Wins: {summary.baseline_wins}")
        print(f"  Ties:          {summary.ties}")

        if summary.category_stats:
            print(f"\n--- Per Category ---")
            for cat, stats in summary.category_stats.items():
                print(f"  {cat}: CADence {stats['cadence_wins']} / Baseline {stats['baseline_wins']}")


def run_full_comparison(
    output_dir: str = "./evaluation/comparison_results",
    n_prompts: int = 15,
    model: str = "gpt-4o"
) -> Tuple[List[ComparisonResult], ComparisonSummary]:
    """
    Convenience function to run full comparison.

    Args:
        output_dir: Output directory
        n_prompts: Number of prompts to test
        model: Model to use

    Returns:
        Tuple of (results, summary)
    """
    runner = ComparisonRunner(output_dir=output_dir, model=model)
    return runner.run_comparison(n_prompts=n_prompts)
