#!/usr/bin/env python3
"""
Run CRAFT pipeline for the 55 benchmark prompts.

For each prompt:
  1. Reasoner (GPT-5.2) → DesignBrief (with KB + dimensional matching)
  2. Planner (GPT-5.2) → JSON CAD Plan
  3. Compiler (GPT-4o) → OpenSCAD code
  4. Render check
  5. VLM Self-Correction (GPT-5.2, up to 3 iterations)
  6. Component Verification (GPT-5.2)
  7. Export to STL

Output:
  results/craft/scad/<id>.scad
  results/craft/stl/<id>.stl
  results/craft/png/<id>.png
  results/craft/results.json

Usage:
  python run_craft_benchmark.py                         # Run all 55
  python run_craft_benchmark.py --ids ball_bearing__BB608ZZ stepper_motor__NEMA17_40
  python run_craft_benchmark.py --resume                # Resume from last checkpoint
  python run_craft_benchmark.py --no-vlm --no-verify    # Skip VLM + verification
"""

import os
import sys
import json
import time
import argparse
import traceback
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict, field
from typing import Dict, List, Optional, Any

# Add craft to path
SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
CRAFT_DIR = REPO_ROOT / "pipeline"
sys.path.insert(0, str(CRAFT_DIR))

from dotenv import load_dotenv
load_dotenv()

# Models — same as app.py
MODEL_PIPELINE = "gpt-4o"
MODEL_VLM = "gpt-5.2"


@dataclass
class BenchmarkResult:
    """Result from one benchmark prompt."""
    prompt_id: str
    prompt_text: str
    family: str

    # Status
    success: bool = False
    reasoner_ok: bool = False
    planner_ok: bool = False
    compiler_ok: bool = False
    render_ok: bool = False
    vlm_ok: bool = False
    verify_ok: bool = False
    stl_ok: bool = False

    # Paths
    scad_path: Optional[str] = None
    stl_path: Optional[str] = None
    png_path: Optional[str] = None

    # Code
    code: Optional[str] = None
    code_length: int = 0

    # KB info
    kb_component_matched: Optional[str] = None
    kb_module_used: Optional[str] = None
    dimensional_match: bool = False

    # Timing
    reasoner_time: float = 0.0
    planner_time: float = 0.0
    compiler_time: float = 0.0
    render_time: float = 0.0
    vlm_time: float = 0.0
    verify_time: float = 0.0
    stl_time: float = 0.0
    total_time: float = 0.0

    # Error
    error: Optional[str] = None

    # Per-stage recovery telemetry (populated by RecoveryBudget; Phase 0b)
    recovery_budget: Optional[Dict[str, Any]] = None
    json_ir_bypassed: bool = False

    # VLM and component verification iteration histories (for recovery aggregation)
    vlm_iterations: int = 0
    vlm_iteration_history: List[Dict[str, Any]] = field(default_factory=list)
    component_iterations: int = 0
    component_iteration_history: List[Dict[str, Any]] = field(default_factory=list)

    def to_dict(self):
        return asdict(self)


class CRAFTBenchmarkRunner:
    """Runs the full CRAFT pipeline for benchmark prompts."""

    def __init__(
        self,
        output_dir: str = None,
        use_vlm: bool = True,
        use_verify: bool = True,
        use_kb: bool = True,
        use_json_ir: bool = True,
        max_vlm_iterations: int = 3,
        max_component_iterations: int = 3,
        recovery_budget_size: int = 10,
    ):
        self.output_dir = Path(output_dir or REPO_ROOT / "results" / "nopscadlib" / "craft")
        self.use_vlm = use_vlm
        self.use_verify = use_verify
        self.use_kb = use_kb
        self.use_json_ir = use_json_ir
        self.max_vlm_iterations = max_vlm_iterations
        self.max_component_iterations = max_component_iterations
        self.recovery_budget_size = recovery_budget_size

        # Create directories
        for sub in ["scad", "stl", "png", "temp"]:
            (self.output_dir / sub).mkdir(parents=True, exist_ok=True)

        self._initialized = False

    def _init_pipeline(self):
        """Lazily initialize all pipeline components."""
        if self._initialized:
            return

        print("Initializing CRAFT pipeline...")

        from openai import OpenAI
        from core.llm_client import create_unified_client
        from core.reasoner import TextReasoner
        from core.planner import Planner
        from core.compiler import Compiler, strip_to_scad
        from core.validator import Validator
        from core.recovery_budget import RecoveryBudget
        from utils.openscad_runner import OpenScadRunner, RenderMode, export_stl

        self.openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.client = create_unified_client(openai_client=self.openai_client)

        # Core pipeline (use_kb forwarded; KB-leak fixed in reasoner.py Phase 0b)
        self.reasoner = TextReasoner(self.client, MODEL_VLM, use_kb=self.use_kb)
        self.planner = Planner(self.client, MODEL_VLM)
        self.compiler = Compiler(self.client, MODEL_PIPELINE)
        self.validator = Validator(pass_threshold=0.80)
        self._RecoveryBudget = RecoveryBudget
        self._strip_to_scad = strip_to_scad

        # VLM correction
        if self.use_vlm:
            from core.visual_corrector import VisualSelfCorrector
            self.visual_corrector = VisualSelfCorrector(
                client=self.client,
                model=MODEL_VLM,
                max_iterations=self.max_vlm_iterations,
            )

        # Component verification
        if self.use_verify:
            from core.component_verifier import ComponentVerifier
            self.component_verifier = ComponentVerifier(
                client=self.client,
                model=MODEL_VLM,
                max_iterations=self.max_component_iterations,
            )

        self.export_stl = export_stl
        self.OpenScadRunner = OpenScadRunner
        self.RenderMode = RenderMode

        self._initialized = True
        print("Pipeline initialized.")

    def run_single(self, prompt_id: str, prompt_text: str, family: str) -> BenchmarkResult:
        """Run the full CRAFT pipeline for a single prompt."""
        self._init_pipeline()

        result = BenchmarkResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text,
            family=family,
        )
        result.json_ir_bypassed = not self.use_json_ir

        # Per-run shared recovery budget (paper's "10-attempt budget")
        budget = self._RecoveryBudget(total_attempts=self.recovery_budget_size)
        if self.use_vlm:
            self.visual_corrector.budget = budget
        if self.use_verify:
            self.component_verifier.budget = budget

        overall_start = time.time()

        try:
            # === Stage 1: Reasoner (with KB + dimensional matching) ===
            t0 = time.time()
            design_brief = self.reasoner.analyze(prompt_text)
            result.reasoner_time = time.time() - t0
            result.reasoner_ok = True

            # Check if KB component was matched
            if hasattr(design_brief, 'kb_components') and design_brief.kb_components:
                kb_comp = design_brief.kb_components[0]
                result.kb_component_matched = getattr(kb_comp, 'name', str(kb_comp))
                result.kb_module_used = getattr(kb_comp, 'module_call', None)
            if hasattr(design_brief, 'dimensional_match_used'):
                result.dimensional_match = design_brief.dimensional_match_used

            kb_components = getattr(design_brief, 'kb_components', None)

            if self.use_json_ir:
                # === Stage 2: Planner (charges schema_repair retries to budget) ===
                t0 = time.time()
                plan_result = self.planner.create_plan(design_brief, max_attempts=2, budget=budget)
                result.planner_time = time.time() - t0

                if not plan_result.valid:
                    result.error = f"Planning failed: {plan_result.error}"
                    result.recovery_budget = budget.to_dict()
                    result.total_time = time.time() - overall_start
                    return result
                result.planner_ok = True

                # === Stage 3: Compiler (with KB components) ===
                t0 = time.time()
                code = self.compiler.compile(plan_result.plan, kb_components=kb_components)
                result.compiler_time = time.time() - t0
                result.compiler_ok = True
            else:
                # JSON-IR ablation: ask LLM for SCAD directly (single call).
                t0 = time.time()
                code = self._direct_codegen(design_brief)
                result.compiler_time = time.time() - t0
                result.planner_ok = True   # no planner stage in this variant
                result.compiler_ok = bool(code.strip())

            result.code = code
            result.code_length = len(code)

            # Save SCAD
            scad_path = self.output_dir / "scad" / f"{prompt_id}.scad"
            with open(scad_path, "w") as f:
                f.write(code)
            result.scad_path = str(scad_path)

            # === Stage 4: Render check ===
            t0 = time.time()
            temp_image = self.output_dir / "temp" / f"{prompt_id}_temp.png"
            runner = self.OpenScadRunner(
                str(scad_path),
                str(temp_image),
                render_mode=self.RenderMode.preview,
            )
            render_ok = runner.run()
            result.render_time = time.time() - t0

            if not render_ok:
                result.error = f"Render failed: {runner.get_errors()}"
                result.recovery_budget = budget.to_dict()
                result.total_time = time.time() - overall_start
                return result
            result.render_ok = True

            # === Stage 5: VLM Self-Correction ===
            if self.use_vlm:
                t0 = time.time()
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                vlm_result = self.visual_corrector.run_correction_loop(
                    scad_code=code,
                    original_prompt=prompt_text,
                    expected_parts=[family.replace("_", " ")],
                    scad_path=str(scad_path),
                    timestamp=f"{timestamp}_{prompt_id}",
                    kb_components=kb_components,
                )
                result.vlm_time = time.time() - t0
                result.vlm_ok = True

                # Capture iteration history for recovery-stats aggregation
                result.vlm_iterations = vlm_result.iterations
                result.vlm_iteration_history = [
                    {
                        "iteration": ir.iteration,
                        "deterministic_passed": ir.deterministic_passed,
                        "deterministic_score": ir.deterministic_score,
                        "corrected": ir.corrected,
                        "autofix_attempted": getattr(ir, "autofix_attempted", 0),
                        "autofix_succeeded": getattr(ir, "autofix_succeeded", False),
                        "autofix_notes": getattr(ir, "autofix_notes", []),
                        "vlm_approved": ir.vlm_assessment.approved if ir.vlm_assessment else None,
                        "vlm_confidence": ir.vlm_assessment.confidence if ir.vlm_assessment else None,
                        "vlm_overall_match": ir.vlm_assessment.overall_match if ir.vlm_assessment else None,
                    }
                    for ir in vlm_result.iteration_history
                ]

                if vlm_result.final_code and vlm_result.final_code != code:
                    code = vlm_result.final_code
                    result.code = code
                    result.code_length = len(code)
                    with open(scad_path, "w") as f:
                        f.write(code)

            # === Stage 6: Component Verification ===
            if self.use_verify:
                t0 = time.time()
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                verif_result = self.component_verifier.verify_and_fix(
                    scad_code=code,
                    expected_parts=[family.replace("_", " ")],
                    original_prompt=prompt_text,
                    scad_path=str(scad_path),
                    timestamp=f"{timestamp}_{prompt_id}",
                    kb_components=kb_components,
                )
                result.verify_time = time.time() - t0
                result.verify_ok = True

                # Capture iteration history with per-tier pass info
                result.component_iterations = verif_result.iterations
                result.component_iteration_history = [
                    {
                        "iteration": ir.iteration,
                        "all_parts_found": ir.all_parts_found,
                        "is_connected": ir.is_connected,
                        "corrected": ir.corrected,
                        "parts_present": [
                            {
                                "part_name": p.part_name,
                                "present": p.present,
                                "confidence": p.confidence,
                                "tier": getattr(p, "tier", "secondary"),
                                "meets_threshold": getattr(p, "meets_threshold", True),
                            }
                            for p in ir.parts_present
                        ],
                    }
                    for ir in verif_result.iteration_history
                ]

                if verif_result.final_code and verif_result.final_code != code:
                    code = verif_result.final_code
                    result.code = code
                    result.code_length = len(code)
                    with open(scad_path, "w") as f:
                        f.write(code)

            # === Stage 7: Final render (PNG) ===
            png_path = self.output_dir / "png" / f"{prompt_id}.png"
            runner = self.OpenScadRunner(
                str(scad_path),
                str(png_path),
                render_mode=self.RenderMode.preview,
            )
            runner.run()
            if png_path.exists():
                result.png_path = str(png_path)

            # === Stage 8: Export STL ===
            t0 = time.time()
            stl_path = self.output_dir / "stl" / f"{prompt_id}.stl"
            stl_ok, stl_error = self.export_stl(str(scad_path), str(stl_path), timeout=300)
            result.stl_time = time.time() - t0

            if stl_ok:
                result.stl_ok = True
                result.stl_path = str(stl_path)
                result.success = True
            else:
                result.error = f"STL export failed: {stl_error}"

        except Exception as e:
            result.error = str(e)
            traceback.print_exc()

        result.recovery_budget = budget.to_dict()
        result.total_time = time.time() - overall_start
        return result

    def _direct_codegen(self, design_brief) -> str:
        """
        JSON-IR ablation path: ask the LLM for SCAD directly, skipping the
        planner+compiler stages. Recovery still runs downstream.
        """
        system_prompt = (
            "You are an expert OpenSCAD programmer. Given a natural-language "
            "description of a 3D model, output VALID, RENDERABLE OpenSCAD code. "
            "Output ONLY the SCAD source — no prose, no fences, no commentary."
        )
        expected = getattr(design_brief, 'expected_parts', None) or []
        user_prompt = (
            f"Description: {design_brief.description}\n\n"
            f"Expected parts: {', '.join(expected) if expected else 'unspecified'}\n\n"
            f"Output complete OpenSCAD code now."
        )
        try:
            response = self.openai_client.chat.completions.create(
                model=MODEL_PIPELINE,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                temperature=0.0,
            )
            raw = response.choices[0].message.content or ""
            return self._strip_to_scad(raw)
        except Exception as e:
            print(f"[run_craft] Direct codegen failed: {e}")
            return f"// direct codegen failed: {e}\n"

    def run_batch(self, prompts: List[dict], resume: bool = False) -> List[BenchmarkResult]:
        """
        Run benchmark for a list of prompts.

        Args:
            prompts: List of dicts with 'id', 'prompt', 'family' keys
            resume: If True, skip prompts that already have STL output
        """
        results = []
        checkpoint_path = self.output_dir / "results.json"

        # Load existing results for resume
        existing = {}
        if resume and checkpoint_path.exists():
            with open(checkpoint_path) as f:
                existing_data = json.load(f)
            for r in existing_data.get("results", []):
                if r.get("success"):
                    existing[r["prompt_id"]] = r

        total = len(prompts)
        success_count = 0
        skip_count = 0

        for i, p in enumerate(prompts):
            pid = p["id"]

            # Resume: skip if already successful
            if resume and pid in existing:
                print(f"[{i+1}/{total}] SKIP (already done): {pid}")
                skip_count += 1
                # Create result from existing data
                r = BenchmarkResult(
                    prompt_id=pid,
                    prompt_text=p["prompt"],
                    family=p["family"],
                )
                for k, v in existing[pid].items():
                    if hasattr(r, k):
                        setattr(r, k, v)
                results.append(r)
                continue

            print(f"\n{'='*60}")
            print(f"[{i+1}/{total}] {pid}")
            print(f"  Prompt: {p['prompt'][:80]}...")
            print(f"{'='*60}")

            result = self.run_single(pid, p["prompt"], p["family"])
            results.append(result)

            if result.success:
                success_count += 1
                print(f"  OK SUCCESS ({result.total_time:.1f}s)")
                if result.kb_component_matched:
                    print(f"  KB matched: {result.kb_component_matched}")
            else:
                print(f"  FAIL: {result.error}")

            # Save checkpoint after each prompt
            self._save_results(results, checkpoint_path)

            # Rate limiting
            time.sleep(1)

        # Final summary
        print(f"\n{'='*60}")
        print(f"CRAFT BENCHMARK COMPLETE")
        print(f"{'='*60}")
        print(f"  Total: {total}")
        print(f"  Skipped (resume): {skip_count}")
        print(f"  Success: {success_count}")
        print(f"  Failed: {total - skip_count - success_count}")

        return results

    def _save_results(self, results: List[BenchmarkResult], path: Path):
        """Save results to JSON checkpoint."""
        data = {
            "timestamp": datetime.now().isoformat(),
            "total": len(results),
            "success": sum(1 for r in results if r.success),
            "failed": sum(1 for r in results if not r.success),
            "results": [r.to_dict() for r in results],
        }
        with open(path, "w") as f:
            json.dump(data, f, indent=2)


def load_prompts(ids: List[str] = None) -> List[dict]:
    """Load all 468 prompts from benchmark_ground_truth.json."""
    gt_path = REPO_ROOT / "ground_truth" / "nopscadlib" / "benchmark_ground_truth.json"
    with open(gt_path) as f:
        data = json.load(f)

    prompts = []
    for comp in data["components"]:
        prompts.append({
            "id": comp["id"],
            "prompt": comp["prompt"],
            "family": comp["component_family"],
            "tier": comp["tier"],
        })

    if ids:
        prompts = [p for p in prompts if p["id"] in ids]

    return prompts


def main():
    parser = argparse.ArgumentParser(description="Run CRAFT benchmark")
    parser.add_argument("--ids", nargs="+", help="Specific prompt IDs to run")
    parser.add_argument("--limit", type=int, help="Run only the first N prompts (smoke test)")
    parser.add_argument("--resume", action="store_true", help="Resume from checkpoint")
    parser.add_argument("--no-vlm", action="store_true", help="Skip VLM correction (ablation: no_multiview)")
    parser.add_argument("--no-verify", action="store_true", help="Skip component verification (ablation: no_verification)")
    parser.add_argument("--no-kb", action="store_true", help="Disable KB / retrieval (ablation: no_retrieval)")
    parser.add_argument("--no-json-ir", action="store_true", help="Bypass planner+compiler, direct codegen (ablation: no_json_ir)")
    parser.add_argument("--no-recovery", action="store_true", help="Disable all recovery layers (ablation: no_recovery — implies --no-vlm --no-verify and skips schema repair)")
    parser.add_argument("--budget", type=int, default=10, help="Shared recovery budget across all five layers (default 10)")
    parser.add_argument("--output-dir", type=str, help="Output directory")
    parser.add_argument("--max-vlm-iter", type=int, default=3, help="Max VLM iterations")
    parser.add_argument("--max-component-iter", type=int, default=3, help="Max component verifier iterations")
    args = parser.parse_args()

    prompts = load_prompts(args.ids)
    if args.limit:
        prompts = prompts[:args.limit]
    print(f"Loaded {len(prompts)} prompts")

    # --no-recovery bundle: disable VLM + verify + downstream recovery
    if args.no_recovery:
        args.no_vlm = True
        args.no_verify = True

    runner = CRAFTBenchmarkRunner(
        output_dir=args.output_dir,
        use_vlm=not args.no_vlm,
        use_verify=not args.no_verify,
        use_kb=not args.no_kb,
        use_json_ir=not args.no_json_ir,
        max_vlm_iterations=args.max_vlm_iter,
        max_component_iterations=args.max_component_iter,
        recovery_budget_size=args.budget,
    )

    results = runner.run_batch(prompts, resume=args.resume)

    # Print summary table
    print(f"\n{'ID':<40} {'Status':<8} {'Time':<8} {'KB Match'}")
    print("-" * 80)
    for r in results:
        status = "OK" if r.success else "FAIL"
        kb = r.kb_component_matched or "-"
        print(f"{r.prompt_id:<40} {status:<8} {r.total_time:>6.1f}s {kb}")


if __name__ == "__main__":
    main()
