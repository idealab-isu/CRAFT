#!/usr/bin/env python3
"""
Run GPT-4o and GPT-5.2 baselines for the 55 benchmark prompts.

Simplest possible pipeline: single API call → OpenSCAD code → STL.
No planning, no validation loop, no repair, no VLM correction.

Output:
  results/gpt4o/scad/<id>.scad
  results/gpt4o/stl/<id>.stl
  results/gpt4o/png/<id>.png
  results/gpt4o/results.json

  results/gpt52/scad/<id>.scad
  results/gpt52/stl/<id>.stl
  results/gpt52/png/<id>.png
  results/gpt52/results.json

Usage:
  python run_gpt_baselines.py                              # Both models, all 55
  python run_gpt_baselines.py --models gpt4o               # Only GPT-4o
  python run_gpt_baselines.py --models gpt52               # Only GPT-5.2
  python run_gpt_baselines.py --models gpt4o gpt52         # Both (default)
  python run_gpt_baselines.py --ids ball_bearing__BB608ZZ   # Specific prompts
  python run_gpt_baselines.py --resume                      # Resume from checkpoint
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

from dotenv import load_dotenv
load_dotenv()


# System prompt — simple, direct OpenSCAD generation
SYSTEM_PROMPT = """You are an expert OpenSCAD code generator. Generate valid, executable OpenSCAD code based on user descriptions.

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


# Model name → OpenAI model ID
MODEL_MAP = {
    "gpt4o": "gpt-4o",
    "gpt52": "gpt-5.2",
}


@dataclass
class BaselineResult:
    """Result from one baseline prompt."""
    prompt_id: str
    prompt_text: str
    model: str

    # Status
    success: bool = False
    syntax_ok: bool = False
    render_ok: bool = False
    stl_ok: bool = False

    # Paths
    scad_path: Optional[str] = None
    stl_path: Optional[str] = None
    png_path: Optional[str] = None

    # Code
    code: Optional[str] = None
    code_length: int = 0

    # Timing
    generation_time: float = 0.0
    render_time: float = 0.0
    stl_time: float = 0.0
    total_time: float = 0.0

    # Error
    error: Optional[str] = None

    def to_dict(self):
        return asdict(self)


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
                "openscad",
                "-o", png_path,
                "--imgsize=800,600",
                "--preview",
                "--autocenter",
                "--viewall",
                scad_path,
            ],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return (
            result.returncode == 0
            and os.path.exists(png_path)
            and os.path.getsize(png_path) > 0
        )
    except Exception:
        return False


def export_stl(scad_path: str, stl_path: str, timeout: int = 300) -> tuple:
    """Export SCAD to STL via OpenSCAD CLI."""
    try:
        result = subprocess.run(
            ["openscad", "-o", stl_path, scad_path],
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if result.returncode == 0 and os.path.exists(stl_path) and os.path.getsize(stl_path) > 0:
            return True, ""
        return False, result.stderr[:500] if result.stderr else "Unknown error"
    except subprocess.TimeoutExpired:
        return False, "STL export timed out"
    except Exception as e:
        return False, str(e)


class GPTBaselineRunner:
    """Runs GPT baseline for benchmark prompts."""

    def __init__(self, model_key: str, output_dir: str = None):
        """
        Args:
            model_key: "gpt4o" or "gpt52"
        """
        from openai import OpenAI

        self.model_key = model_key
        self.model_id = MODEL_MAP[model_key]
        self.client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        self.output_dir = Path(output_dir or SCRIPT_DIR / "results" / model_key)

        # Create directories
        for sub in ["scad", "stl", "png"]:
            (self.output_dir / sub).mkdir(parents=True, exist_ok=True)

    def run_single(self, prompt_id: str, prompt_text: str) -> BaselineResult:
        """Generate OpenSCAD code for a single prompt and export to STL."""
        result = BaselineResult(
            prompt_id=prompt_id,
            prompt_text=prompt_text,
            model=self.model_id,
        )

        overall_start = time.time()

        try:
            # === Step 1: Generate code via single API call ===
            t0 = time.time()
            response = self.client.chat.completions.create(
                model=self.model_id,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
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

            # === Step 2: Save SCAD ===
            scad_path = self.output_dir / "scad" / f"{prompt_id}.scad"
            with open(scad_path, "w") as f:
                f.write(code)
            result.scad_path = str(scad_path)
            result.syntax_ok = True  # If API returned code, assume syntax is plausible

            # === Step 3: Render PNG ===
            t0 = time.time()
            png_path = self.output_dir / "png" / f"{prompt_id}.png"
            result.render_ok = render_png(str(scad_path), str(png_path))
            result.render_time = time.time() - t0
            if result.render_ok:
                result.png_path = str(png_path)

            # === Step 4: Export STL ===
            t0 = time.time()
            stl_path = self.output_dir / "stl" / f"{prompt_id}.stl"
            stl_ok, stl_err = export_stl(str(scad_path), str(stl_path))
            result.stl_time = time.time() - t0

            if stl_ok:
                result.stl_ok = True
                result.stl_path = str(stl_path)
                result.success = True
            else:
                result.error = f"STL export failed: {stl_err}"

        except Exception as e:
            result.error = str(e)
            traceback.print_exc()

        result.total_time = time.time() - overall_start
        return result

    def run_batch(self, prompts: List[dict], resume: bool = False) -> List[BaselineResult]:
        """Run baseline for a list of prompts."""
        results = []
        checkpoint_path = self.output_dir / "results.json"

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
                print(f"  [{i+1}/{total}] SKIP: {pid}")
                skip_count += 1
                r = BaselineResult(
                    prompt_id=pid,
                    prompt_text=p["prompt"],
                    model=self.model_id,
                )
                for k, v in existing[pid].items():
                    if hasattr(r, k):
                        setattr(r, k, v)
                results.append(r)
                continue

            print(f"  [{i+1}/{total}] {pid} ...", end=" ", flush=True)

            result = self.run_single(pid, p["prompt"])
            results.append(result)

            if result.success:
                success_count += 1
                print(f"OK ({result.total_time:.1f}s)")
            else:
                print(f"FAIL: {result.error}")

            # Checkpoint
            self._save_results(results, checkpoint_path)

            # Rate limit (0.5s between calls)
            time.sleep(0.5)

        print(f"\n  {self.model_id}: {success_count}/{total} success, {skip_count} skipped")
        return results

    def _save_results(self, results: List[BaselineResult], path: Path):
        """Save results to JSON."""
        data = {
            "model": self.model_id,
            "timestamp": datetime.now().isoformat(),
            "total": len(results),
            "success": sum(1 for r in results if r.success),
            "results": [r.to_dict() for r in results],
        }
        with open(path, "w") as f:
            json.dump(data, f, indent=2)


def load_prompts(ids: List[str] = None) -> List[dict]:
    """Load all 468 prompts from benchmark_ground_truth.json."""
    gt_path = SCRIPT_DIR / "benchmark_ground_truth.json"
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
    parser = argparse.ArgumentParser(description="Run GPT baselines")
    parser.add_argument(
        "--models",
        nargs="+",
        default=["gpt4o", "gpt52"],
        choices=["gpt4o", "gpt52"],
        help="Models to run",
    )
    parser.add_argument("--ids", nargs="+", help="Specific prompt IDs")
    parser.add_argument("--resume", action="store_true", help="Resume from checkpoint")
    parser.add_argument("--output-dir", type=str, help="Base output directory")
    args = parser.parse_args()

    prompts = load_prompts(args.ids)
    print(f"Loaded {len(prompts)} prompts")

    all_results = {}

    for model_key in args.models:
        print(f"\n{'='*60}")
        print(f"Running {MODEL_MAP[model_key]} baseline")
        print(f"{'='*60}")

        output_dir = args.output_dir or None
        if output_dir:
            output_dir = str(Path(output_dir) / model_key)

        runner = GPTBaselineRunner(model_key, output_dir=output_dir)
        results = runner.run_batch(prompts, resume=args.resume)
        all_results[model_key] = results

    # Print comparison table
    print(f"\n{'='*60}")
    print("SUMMARY")
    print(f"{'='*60}")

    header = f"{'ID':<40}"
    for mk in args.models:
        header += f" {mk:<8}"
    print(header)
    print("-" * (40 + 9 * len(args.models)))

    for p in prompts:
        pid = p["id"]
        line = f"{pid:<40}"
        for mk in args.models:
            results = all_results.get(mk, [])
            r = next((r for r in results if r.prompt_id == pid), None)
            status = "OK" if r and r.success else "FAIL"
            line += f" {status:<8}"
        print(line)

    for mk in args.models:
        results = all_results.get(mk, [])
        ok = sum(1 for r in results if r.success)
        print(f"\n{MODEL_MAP[mk]}: {ok}/{len(results)} successful")


if __name__ == "__main__":
    main()
