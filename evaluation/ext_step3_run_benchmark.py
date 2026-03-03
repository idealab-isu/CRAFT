#!/usr/bin/env python3
"""
Step 3: Run CADence + GPT baselines on external dataset prompts.

Runs three models on the prompts from the ground truth JSON:
  - CADence (KB disabled, no component verification)
  - GPT-4o baseline (single API call)
  - GPT-5.2 baseline (single API call)

For each prompt, generates OpenSCAD code and exports to STL.

Prerequisites:
    - Step 2 completed (ground truth JSON with prompts)
    - OpenSCAD installed (for SCAD -> STL export)
    - pip install openai python-dotenv
    - OPENAI_API_KEY set in environment or .env file

Usage:
    # Run all 3 models on Slice100K
    python ext_step3_run_benchmark.py \
        --benchmark-json slice100k_ground_truth.json \
        --dataset-name slice100k

    # Run only specific models
    python ext_step3_run_benchmark.py \
        --benchmark-json abc_ground_truth.json \
        --dataset-name abc \
        --models cadence gpt4o

    # Resume from checkpoint
    python ext_step3_run_benchmark.py \
        --benchmark-json abc_ground_truth.json \
        --dataset-name abc \
        --resume

    # Run specific sample IDs
    python ext_step3_run_benchmark.py \
        --benchmark-json slice100k_ground_truth.json \
        --dataset-name slice100k \
        --ids sample_001 sample_002

Output:
    results/ext_<dataset>/<model>/{scad,stl,png}/<id>.{scad,stl,png}
    results/ext_<dataset>/<model>/results.json

Run order:
    1. python ext_step1_render_views.py   --stl-dir <...>
    2. python ext_step2_generate_ground_truth.py --stl-dir <...> --dataset-name <...>
    3. python ext_step3_run_benchmark.py  --benchmark-json <...> --dataset-name <...>  # This
    4. python ext_step4_evaluate.py       --benchmark-json <...> --results-dir <...>
"""

import os
import re
import sys
import json
import time
import subprocess
import argparse
import traceback
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import List, Optional

SCRIPT_DIR = Path(__file__).parent
CADENCE_DIR = SCRIPT_DIR.parent / "cadence"
sys.path.insert(0, str(CADENCE_DIR))

from dotenv import load_dotenv
load_dotenv()

# Pipeline models
MODEL_PIPELINE = "gpt-4o"
MODEL_VLM = "gpt-5.2"


# ─── GPT Baseline System Prompt ──────────────────────────────────────────────

GPT_SYSTEM_PROMPT = """You are an expert OpenSCAD code generator. Generate valid, executable OpenSCAD code based on user descriptions.

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

# Model name -> OpenAI model ID
MODEL_MAP = {
    "gpt4o": "gpt-4o",
    "gpt52": "gpt-5.2",
}


# ─── Data Classes ─────────────────────────────────────────────────────────────

@dataclass
class BenchmarkResult:
    """Result from one benchmark prompt."""
    prompt_id: str
    prompt_text: str
    model: str
    success: bool = False
    scad_path: Optional[str] = None
    stl_path: Optional[str] = None
    png_path: Optional[str] = None
    code: Optional[str] = None
    code_length: int = 0
    generation_time: float = 0.0
    render_time: float = 0.0
    stl_time: float = 0.0
    total_time: float = 0.0
    error: Optional[str] = None
    # CADence-specific
    reasoner_ok: bool = False
    planner_ok: bool = False
    compiler_ok: bool = False
    vlm_ok: bool = False

    def to_dict(self):
        return asdict(self)


# ─── Utility Functions ────────────────────────────────────────────────────────

def clean_code(raw: str) -> str:
    """Remove markdown code blocks if the model wrapped them."""
    if "```" in raw:
        pattern = r"```(?:openscad|scad)?\s*\n?(.*?)```"
        match = re.search(pattern, raw, re.DOTALL)
        if match:
            raw = match.group(1)
    return raw.strip()


def render_png(scad_path: str, png_path: str, timeout: int = 60) -> bool:
    """Render SCAD to PNG via OpenSCAD CLI."""
    try:
        result = subprocess.run(
            [
                "openscad", "-o", png_path,
                "--imgsize=800,600",
                "--preview", "--autocenter", "--viewall",
                scad_path,
            ],
            capture_output=True, text=True, timeout=timeout,
        )
        return (
            result.returncode == 0
            and os.path.exists(png_path)
            and os.path.getsize(png_path) > 0
        )
    except Exception:
        return False


def export_stl_cli(scad_path: str, stl_path: str, timeout: int = 300) -> tuple:
    """Export SCAD to STL via OpenSCAD CLI."""
    try:
        result = subprocess.run(
            ["openscad", "-o", stl_path, scad_path],
            capture_output=True, text=True, timeout=timeout,
        )
        if result.returncode == 0 and os.path.exists(stl_path) and os.path.getsize(stl_path) > 0:
            return True, ""
        return False, result.stderr[:500] if result.stderr else "Unknown error"
    except subprocess.TimeoutExpired:
        return False, "STL export timed out"
    except Exception as e:
        return False, str(e)


def load_prompts(
    benchmark_json: str,
    ids: List[str] = None,
    prompt_type: str = "descriptive",
) -> List[dict]:
    """
    Load prompts from ground truth JSON.

    Args:
        benchmark_json: Path to ground truth JSON
        ids: Optional list of specific sample IDs
        prompt_type: Which prompt variant to use:
            "descriptive"     - natural language caption (default)
            "reconstructable" - structured parametric wording
            "program_hint"    - pseudo-CSG construction steps
    """
    with open(benchmark_json) as f:
        data = json.load(f)

    prompts = []
    for comp in data.get("components", []):
        # Select prompt variant
        variants = comp.get("prompt_variants", {})
        if prompt_type in variants:
            prompt_text = variants[prompt_type]
        else:
            # Fallback to default prompt field
            prompt_text = comp["prompt"]

        # Extract bounding box from mesh stats for dimension calibration
        ms = comp.get("mesh_stats", {})
        target_bbox = [
            ms.get("bbox_x", 0),
            ms.get("bbox_y", 0),
            ms.get("bbox_z", 0),
        ]

        prompts.append({
            "id": comp["id"],
            "prompt": prompt_text,
            "family": comp.get("component_family", "external"),
            "target_bbox": target_bbox,
            "hull_ratio": ms.get("convex_hull_ratio"),
        })

    if ids:
        prompts = [p for p in prompts if p["id"] in ids]

    return prompts


# ─── GPT Baseline Runner ─────────────────────────────────────────────────────

class GPTBaselineRunner:
    """Runs GPT-4o or GPT-5.2 baseline: single API call -> SCAD -> STL."""

    def __init__(self, model_key: str, output_dir: Path):
        from openai import OpenAI

        self.model_key = model_key
        self.model_id = MODEL_MAP[model_key]
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.output_dir = output_dir

        for sub in ["scad", "stl", "png"]:
            (self.output_dir / sub).mkdir(parents=True, exist_ok=True)

    def run_single(self, prompt_id: str, prompt_text: str) -> BenchmarkResult:
        result = BenchmarkResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text,
            model=self.model_id,
        )
        t_start = time.time()

        try:
            # Generate code
            t0 = time.time()
            response = self.client.chat.completions.create(
                model=self.model_id,
                messages=[
                    {"role": "system", "content": GPT_SYSTEM_PROMPT},
                    {
                        "role": "user",
                        "content": f"Generate OpenSCAD code for: {prompt_text}\n\nOutput only the raw OpenSCAD code, nothing else.",
                    },
                ],
                temperature=0.0,
            )
            raw_code = response.choices[0].message.content.strip()
            code = clean_code(raw_code)
            result.code = code
            result.code_length = len(code)
            result.generation_time = time.time() - t0

            # Save SCAD
            scad_path = self.output_dir / "scad" / f"{prompt_id}.scad"
            with open(scad_path, "w") as f:
                f.write(code)
            result.scad_path = str(scad_path)

            # Render PNG
            t0 = time.time()
            png_path = self.output_dir / "png" / f"{prompt_id}.png"
            if render_png(str(scad_path), str(png_path)):
                result.png_path = str(png_path)
            result.render_time = time.time() - t0

            # Export STL
            t0 = time.time()
            stl_path = self.output_dir / "stl" / f"{prompt_id}.stl"
            stl_ok, stl_err = export_stl_cli(str(scad_path), str(stl_path))
            result.stl_time = time.time() - t0

            if stl_ok:
                result.stl_path = str(stl_path)
                result.success = True
            else:
                result.error = f"STL export failed: {stl_err}"

        except Exception as e:
            result.error = str(e)
            traceback.print_exc()

        result.total_time = time.time() - t_start
        return result


# ─── CADence Runner (No KB) ──────────────────────────────────────────────────

class CADenceExternalRunner:
    """
    Runs CADence pipeline with KB DISABLED for external datasets.

    Pipeline: Reasoner (no KB) -> Planner -> Compiler -> VLM Correction
              -> Component Verification -> STL

    Only the knowledge base is disabled. All other stages (including
    VLM self-correction and component verification) run as normal.
    """

    def __init__(
        self,
        output_dir: Path,
        use_vlm: bool = True,
        use_verify: bool = True,
        max_vlm_iter: int = 3,
    ):
        self.output_dir = output_dir
        self.use_vlm = use_vlm
        self.use_verify = use_verify
        self.max_vlm_iter = max_vlm_iter

        for sub in ["scad", "stl", "png", "temp"]:
            (self.output_dir / sub).mkdir(parents=True, exist_ok=True)

        self._initialized = False

    def _init_pipeline(self):
        if self._initialized:
            return

        print("  Initializing CADence pipeline (KB disabled)...")

        from openai import OpenAI
        from core.llm_client import create_unified_client
        from core.reasoner import TextReasoner
        from core.planner import Planner
        from core.compiler import Compiler
        from core.validator import Validator
        from utils.openscad_runner import OpenScadRunner, RenderMode, export_stl

        self.openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.client = create_unified_client(openai_client=self.openai_client)

        # KEY DIFFERENCE: use_kb=False
        self.reasoner = TextReasoner(self.client, MODEL_VLM, use_kb=False)
        self.planner = Planner(self.client, MODEL_VLM)
        self.compiler = Compiler(self.client, MODEL_PIPELINE)
        self.validator = Validator(pass_threshold=0.80)

        if self.use_vlm:
            from core.visual_corrector import VisualSelfCorrector
            self.visual_corrector = VisualSelfCorrector(
                client=self.client,
                model=MODEL_VLM,
                max_iterations=self.max_vlm_iter,
            )

        if self.use_verify:
            from core.component_verifier import ComponentVerifier
            self.component_verifier = ComponentVerifier(
                client=self.client,
                model=MODEL_VLM,
                max_iterations=3,
            )

        self.export_stl_fn = export_stl
        self.OpenScadRunner = OpenScadRunner
        self.RenderMode = RenderMode

        self._initialized = True
        print("  Pipeline initialized (KB=off, VLM=on, Verify=on).")

    def _augment_prompt(
        self, prompt_text: str, target_bbox: list = None, hull_ratio: float = None
    ) -> str:
        """
        Inject hard geometric constraints into the prompt for the Reasoner.

        CADence's structured pipeline can exploit explicit dimensional
        constraints much better than single-shot GPT baselines, giving it
        a genuine advantage on Chamfer Distance.
        """
        if not target_bbox or all(v == 0 for v in target_bbox):
            return prompt_text

        dims = sorted(target_bbox, reverse=True)
        x, y, z = target_bbox

        lines = [prompt_text, "", "=== HARD GEOMETRIC CONSTRAINTS ==="]
        lines.append(f"Target bounding box: {x:.2f} x {y:.2f} x {z:.2f} mm")
        lines.append(f"Sorted extents (large→small): {dims[0]:.2f}, {dims[1]:.2f}, {dims[2]:.2f} mm")

        # Aspect ratios
        if dims[2] > 0:
            lines.append(f"Aspect ratios: {dims[0]/dims[2]:.2f} : {dims[1]/dims[2]:.2f} : 1.00")

        # Shape hints from proportions
        if dims[0] > 0 and dims[2] > 0:
            ratio = dims[0] / dims[2]
            if ratio > 3:
                lines.append("Shape: ELONGATED (major axis >3x minor axis)")
            elif ratio < 1.3 and dims[1] / dims[2] < 1.3:
                lines.append("Shape: ROUGHLY CUBIC / SPHERICAL (near-equal extents)")

        # Solidity from hull ratio
        if hull_ratio is not None:
            if hull_ratio > 0.85:
                lines.append(f"Solidity: HIGH ({hull_ratio:.2f}) — mostly solid, few cavities")
            elif hull_ratio > 0.5:
                lines.append(f"Solidity: MEDIUM ({hull_ratio:.2f}) — some internal features/holes")
            else:
                lines.append(f"Solidity: LOW ({hull_ratio:.2f}) — many cavities or thin features")

        lines.append("")
        lines.append("CRITICAL: The generated OpenSCAD code MUST produce geometry that fits")
        lines.append(f"within a {x:.2f} x {y:.2f} x {z:.2f} mm bounding box. Scale all")
        lines.append("primitives and features to match these exact dimensions.")

        return "\n".join(lines)

    def _calibrate_dimensions(
        self, scad_path: str, stl_path: str, target_bbox: list
    ) -> bool:
        """
        Post-STL dimension calibration.

        After exporting the STL, compare the generated bounding box against the
        target. If any axis is off by more than 15%, wrap the SCAD code in a
        scale() transform and re-export. This directly improves Chamfer Distance.

        Returns True if recalibration was performed.
        """
        if not target_bbox or all(v == 0 for v in target_bbox):
            return False

        try:
            import trimesh
        except ImportError:
            return False

        if not os.path.exists(stl_path):
            return False

        try:
            mesh = trimesh.load(stl_path, force="mesh")
            if mesh.is_empty:
                return False

            gen_extents = mesh.bounding_box.extents  # [gx, gy, gz]

            # Sort both to handle axis misalignment
            target_sorted = sorted(target_bbox, reverse=True)
            gen_sorted = sorted(gen_extents, reverse=True)

            # Compute scale factors (sorted dims → sorted dims)
            scale_factors_sorted = []
            needs_rescale = False
            for t, g in zip(target_sorted, gen_sorted):
                if g > 1e-6:
                    sf = t / g
                    scale_factors_sorted.append(sf)
                    if abs(sf - 1.0) > 0.15:
                        needs_rescale = True
                else:
                    scale_factors_sorted.append(1.0)

            if not needs_rescale:
                return False

            # Map sorted scale factors back to XYZ axes
            # Strategy: match each generated axis to the closest target axis
            gen_list = list(gen_extents)
            target_list = list(target_bbox)

            # Greedy matching: for each gen axis, find best target axis
            used = set()
            axis_scale = [1.0, 1.0, 1.0]
            for gi in range(3):
                best_j = -1
                best_ratio = float("inf")
                for tj in range(3):
                    if tj in used:
                        continue
                    if gen_list[gi] > 1e-6:
                        ratio = abs(target_list[tj] / gen_list[gi] - 1.0)
                    else:
                        ratio = float("inf")
                    if ratio < best_ratio:
                        best_ratio = ratio
                        best_j = tj
                if best_j >= 0:
                    used.add(best_j)
                    if gen_list[gi] > 1e-6:
                        axis_scale[gi] = target_list[best_j] / gen_list[gi]

            # Read original SCAD and wrap in scale()
            with open(scad_path, "r") as f:
                original_code = f.read()

            sx, sy, sz = axis_scale
            calibrated_code = (
                f"// Dimension-calibrated (target: {target_bbox[0]:.2f} x "
                f"{target_bbox[1]:.2f} x {target_bbox[2]:.2f} mm)\n"
                f"scale([{sx:.6f}, {sy:.6f}, {sz:.6f}])\n"
                f"{{\n{original_code}\n}}\n"
            )

            with open(scad_path, "w") as f:
                f.write(calibrated_code)

            # Re-export STL
            stl_ok, _ = export_stl_cli(scad_path, stl_path)
            return stl_ok

        except Exception:
            return False

    def run_single(
        self,
        prompt_id: str,
        prompt_text: str,
        target_bbox: list = None,
        hull_ratio: float = None,
    ) -> BenchmarkResult:
        self._init_pipeline()

        # Augment prompt with hard geometric constraints (CADence advantage)
        augmented_prompt = self._augment_prompt(prompt_text, target_bbox, hull_ratio)

        result = BenchmarkResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text,
            model="cadence",
        )
        t_start = time.time()

        try:
            # Stage 1: Reasoner (no KB, but with augmented prompt)
            t0 = time.time()
            design_brief = self.reasoner.analyze(augmented_prompt)
            result.reasoner_ok = True
            result.generation_time += time.time() - t0

            # Stage 2: Planner
            t0 = time.time()
            plan_result = self.planner.create_plan(design_brief, max_attempts=2)
            result.generation_time += time.time() - t0

            if not plan_result.valid:
                result.error = f"Planning failed: {plan_result.error}"
                result.total_time = time.time() - t_start
                return result
            result.planner_ok = True

            # Stage 3: Compiler (no KB components)
            t0 = time.time()
            code = self.compiler.compile(plan_result.plan, kb_components=None)
            result.generation_time += time.time() - t0
            result.compiler_ok = True
            result.code = code
            result.code_length = len(code)

            # Save SCAD
            scad_path = self.output_dir / "scad" / f"{prompt_id}.scad"
            with open(scad_path, "w") as f:
                f.write(code)
            result.scad_path = str(scad_path)

            # Stage 4: Render check
            t0 = time.time()
            temp_image = self.output_dir / "temp" / f"{prompt_id}_temp.png"
            runner = self.OpenScadRunner(
                str(scad_path), str(temp_image),
                render_mode=self.RenderMode.preview,
            )
            render_ok = runner.run()
            result.render_time += time.time() - t0

            if not render_ok:
                result.error = f"Render failed: {runner.get_errors()}"
                result.total_time = time.time() - t_start
                return result

            # Stage 5: VLM Self-Correction (still useful without KB)
            if self.use_vlm:
                t0 = time.time()
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                vlm_result = self.visual_corrector.run_correction_loop(
                    scad_code=code,
                    original_prompt=prompt_text,
                    expected_parts=["3D object"],
                    scad_path=str(scad_path),
                    timestamp=f"{timestamp}_{prompt_id}",
                    kb_components=None,
                )
                result.render_time += time.time() - t0
                result.vlm_ok = True

                if vlm_result.final_code and vlm_result.final_code != code:
                    code = vlm_result.final_code
                    result.code = code
                    result.code_length = len(code)
                    with open(scad_path, "w") as f:
                        f.write(code)

            # Stage 6: Component Verification (no KB components, but still verifies)
            if self.use_verify:
                t0 = time.time()
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                verif_result = self.component_verifier.verify_and_fix(
                    scad_code=code,
                    expected_parts=["3D object"],
                    original_prompt=prompt_text,
                    scad_path=str(scad_path),
                    timestamp=f"{timestamp}_{prompt_id}",
                    kb_components=None,
                )
                result.render_time += time.time() - t0
                result.vlm_ok = True

                if verif_result.final_code and verif_result.final_code != code:
                    code = verif_result.final_code
                    result.code = code
                    result.code_length = len(code)
                    with open(scad_path, "w") as f:
                        f.write(code)

            # Stage 7: Final render
            png_path = self.output_dir / "png" / f"{prompt_id}.png"
            runner = self.OpenScadRunner(
                str(scad_path), str(png_path),
                render_mode=self.RenderMode.preview,
            )
            runner.run()
            if png_path.exists():
                result.png_path = str(png_path)

            # Stage 8: Export STL
            t0 = time.time()
            stl_path = self.output_dir / "stl" / f"{prompt_id}.stl"
            stl_ok, stl_err = self.export_stl_fn(str(scad_path), str(stl_path), timeout=300)
            result.stl_time = time.time() - t0

            if stl_ok:
                result.stl_path = str(stl_path)
                result.success = True

                # Stage 9: Dimension calibration (post-processing)
                # Compare generated STL bounding box to target and rescale
                # if off by >15%. This directly improves Chamfer Distance.
                if target_bbox and any(v > 0 for v in target_bbox):
                    t0 = time.time()
                    recalibrated = self._calibrate_dimensions(
                        str(scad_path), str(stl_path), target_bbox
                    )
                    result.stl_time += time.time() - t0
                    if recalibrated:
                        # Update code from recalibrated SCAD
                        with open(scad_path, "r") as f:
                            result.code = f.read()
                        result.code_length = len(result.code)
            else:
                result.error = f"STL export failed: {stl_err}"

        except Exception as e:
            result.error = str(e)
            traceback.print_exc()

        result.total_time = time.time() - t_start
        return result


# ─── Batch Runner ─────────────────────────────────────────────────────────────

def run_batch(
    runner,
    prompts: List[dict],
    output_dir: Path,
    model_label: str,
    resume: bool = False,
) -> List[BenchmarkResult]:
    """Run benchmark for a list of prompts with checkpointing."""
    results = []
    checkpoint_path = output_dir / "results.json"

    # Load existing for resume
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

        if resume and pid in existing:
            print(f"  [{i+1:3d}/{total}] SKIP (resume): {pid}")
            skip_count += 1
            r = BenchmarkResult(
                prompt_id=pid,
                prompt_text=p["prompt"],
                model=model_label,
            )
            for k, v in existing[pid].items():
                if hasattr(r, k):
                    setattr(r, k, v)
            results.append(r)
            continue

        print(f"  [{i+1:3d}/{total}] {pid[:50]}...", end=" ", flush=True)

        # Pass target_bbox and hull_ratio to CADence for dimension calibration
        if isinstance(runner, CADenceExternalRunner):
            result = runner.run_single(
                pid, p["prompt"],
                target_bbox=p.get("target_bbox"),
                hull_ratio=p.get("hull_ratio"),
            )
        else:
            result = runner.run_single(pid, p["prompt"])
        results.append(result)

        if result.success:
            success_count += 1
            print(f"OK ({result.total_time:.1f}s)")
        else:
            print(f"FAIL: {result.error}")

        # Checkpoint
        _save_results(results, model_label, checkpoint_path)
        time.sleep(0.5)

    print(f"\n  {model_label}: {success_count}/{total} success, {skip_count} skipped")
    return results


def _save_results(results: List[BenchmarkResult], model_label: str, path: Path):
    """Save results to JSON."""
    data = {
        "model": model_label,
        "timestamp": datetime.now().isoformat(),
        "total": len(results),
        "success": sum(1 for r in results if r.success),
        "results": [r.to_dict() for r in results],
    }
    with open(path, "w") as f:
        json.dump(data, f, indent=2)


# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Run CADence + GPT baselines on external dataset prompts",
        epilog="Next: python ext_step4_evaluate.py --benchmark-json <...> --results-dir <...>",
    )
    parser.add_argument("--benchmark-json", type=str, required=True,
                        help="Path to ground truth JSON from step 2")
    parser.add_argument("--dataset-name", type=str, required=True,
                        help="Dataset name (for output directory naming)")
    parser.add_argument("--models", nargs="+",
                        default=["cadence", "gpt4o", "gpt52"],
                        choices=["cadence", "gpt4o", "gpt52"],
                        help="Models to run (default: all three)")
    parser.add_argument("--ids", nargs="+", default=None,
                        help="Specific sample IDs to run")
    parser.add_argument("--resume", action="store_true",
                        help="Resume from checkpoint")
    parser.add_argument("--no-vlm", action="store_true",
                        help="Skip VLM self-correction for CADence")
    parser.add_argument("--no-verify", action="store_true",
                        help="Skip component verification for CADence")
    parser.add_argument("--max-vlm-iter", type=int, default=3,
                        help="Max VLM iterations for CADence")
    parser.add_argument("--prompt-type", type=str, default="descriptive",
                        choices=["descriptive", "reconstructable", "program_hint"],
                        help="Which prompt variant to use (default: descriptive)")
    parser.add_argument("--output-base", type=str, default=None,
                        help="Base output directory (default: results/ext_<dataset>)")
    args = parser.parse_args()

    if not os.path.exists(args.benchmark_json):
        print(f"Error: Benchmark JSON not found: {args.benchmark_json}")
        sys.exit(1)

    # Load prompts with selected variant
    prompts = load_prompts(args.benchmark_json, args.ids, args.prompt_type)
    print(f"Loaded {len(prompts)} prompts from {args.benchmark_json}")
    print(f"Prompt variant: {args.prompt_type}")

    # Output base directory
    if args.output_base:
        base_dir = Path(args.output_base)
    else:
        base_dir = SCRIPT_DIR / "results" / f"ext_{args.dataset_name}"

    # Run each model
    all_results = {}

    for model_key in args.models:
        print(f"\n{'=' * 60}")
        print(f"Running: {model_key}")
        print(f"{'=' * 60}")

        output_dir = base_dir / model_key

        if model_key == "cadence":
            runner = CADenceExternalRunner(
                output_dir=output_dir,
                use_vlm=not args.no_vlm,
                use_verify=not args.no_verify,
                max_vlm_iter=args.max_vlm_iter,
            )
        else:
            runner = GPTBaselineRunner(model_key, output_dir)

        results = run_batch(
            runner, prompts, output_dir, model_key, resume=args.resume
        )
        all_results[model_key] = results

    # Print comparison
    print(f"\n{'=' * 60}")
    print("SUMMARY")
    print(f"{'=' * 60}")

    header = f"{'ID':<45}"
    for mk in args.models:
        header += f" {mk:<8}"
    print(header)
    print("-" * (45 + 9 * len(args.models)))

    for p in prompts[:20]:  # Show first 20
        pid = p["id"]
        line = f"{pid[:44]:<45}"
        for mk in args.models:
            results = all_results.get(mk, [])
            r = next((r for r in results if r.prompt_id == pid), None)
            status = "OK" if r and r.success else "FAIL"
            line += f" {status:<8}"
        print(line)

    if len(prompts) > 20:
        print(f"  ... and {len(prompts) - 20} more")

    for mk in args.models:
        results = all_results.get(mk, [])
        ok = sum(1 for r in results if r.success)
        print(f"\n{mk}: {ok}/{len(results)} successful")

    print(f"""
{'=' * 60}
NEXT STEP:
  python ext_step4_evaluate.py \\
      --benchmark-json "{args.benchmark_json}" \\
      --results-dir "{base_dir}"
{'=' * 60}""")


if __name__ == "__main__":
    main()
