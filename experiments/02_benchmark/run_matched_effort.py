#!/usr/bin/env python3
"""
Matched-effort baseline runners.

Three variants of "direct LLM generation + extra effort," designed to isolate
the architectural contribution of CRAFT's pipeline from the effect of just
spending more LLM calls. Each variant writes to
  results/<dataset>/matched_effort/<variant>/
in the same shape as results/<dataset>/craft/, so the metric scripts in
experiments/03_metrics/ work without changes.

Variants:
  direct_repair         — GPT-5.2 one-shot SCAD → if render fails, run SCAD auto-fix
                          (Layer 2) and re-render. No planner, no VLM, no verifier.
  direct_vlm            — GPT-5.2 one-shot SCAD → up to N rounds of VLM correction
                          (Layer 3). No planner, no verifier.
  direct_matched_calls  — GPT-5.2 one-shot SCAD invoked N times with temperature
                          jitter; keep the candidate with the highest deterministic
                          validator score. N is matched to CRAFT's mean LLM-call
                          count on this dataset (default: 8).

Usage:
  python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib
  python experiments/02_benchmark/run_matched_effort.py --dataset abc --variants direct_vlm
  python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --limit 5 --variants direct_repair
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
import traceback
from dataclasses import asdict, dataclass, field
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List, Optional

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
CRAFT_DIR = REPO_ROOT / "pipeline"
sys.path.insert(0, str(CRAFT_DIR))

from dotenv import load_dotenv
load_dotenv()

from openai import OpenAI

from core.scad_autofix import SCADAutoFixer
from core.recovery_budget import RecoveryBudget
from core.compiler import strip_to_scad
from core.validator import Validator
from utils.openscad_runner import OpenScadRunner, RenderMode, export_stl

MODEL_DIRECT = os.getenv("MATCHED_EFFORT_MODEL", "gpt-5.2")
DEFAULT_MATCHED_CALLS = int(os.getenv("MATCHED_EFFORT_CALLS", "8"))


SYSTEM_PROMPT = (
    "You are an expert OpenSCAD programmer. Given a natural-language "
    "description of a 3D model, output VALID, RENDERABLE OpenSCAD code "
    "that implements it. Output ONLY the SCAD source — no prose, no "
    "fences, no commentary."
)


@dataclass
class MEResult:
    prompt_id: str
    prompt_text: str
    family: str
    variant: str
    success: bool = False
    render_ok: bool = False
    stl_ok: bool = False
    code: str = ""
    code_length: int = 0
    scad_path: Optional[str] = None
    stl_path: Optional[str] = None
    png_path: Optional[str] = None
    llm_calls: int = 0
    total_time: float = 0.0
    error: Optional[str] = None
    recovery_budget: Optional[Dict[str, Any]] = None
    notes: List[str] = field(default_factory=list)

    def to_dict(self):
        return asdict(self)


def direct_codegen(client: OpenAI, prompt: str, *, temperature: float = 0.0) -> str:
    """Single direct LLM call → SCAD string."""
    resp = client.chat.completions.create(
        model=MODEL_DIRECT,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user",   "content": f"Description: {prompt}\n\nOutput complete OpenSCAD code now."},
        ],
        temperature=temperature,
    )
    return strip_to_scad(resp.choices[0].message.content or "")


def render_to_png(scad_path: Path, png_path: Path, timeout: int = 90) -> bool:
    """Render SCAD to PNG; return True on success."""
    runner = OpenScadRunner(
        str(scad_path), str(png_path),
        render_mode=RenderMode.preview, timeout=timeout,
    )
    return runner.run()


# =============================================================================
# VARIANTS
# =============================================================================

def variant_direct_repair(
    client: OpenAI, autofixer: SCADAutoFixer, budget: RecoveryBudget,
    prompt: str, scad_path: Path, png_path: Path,
) -> tuple[str, bool, list[str]]:
    """Direct codegen + SCAD auto-fix on render failure."""
    notes: list[str] = []
    llm_calls = 1
    code = direct_codegen(client, prompt)
    scad_path.write_text(code, encoding="utf-8")

    if render_to_png(scad_path, png_path):
        return code, True, notes + ["direct render succeeded"]

    # Render failed — apply autofix
    for attempt in range(1, 3):
        if not budget.can_retry("scad_autofix"):
            notes.append("budget exhausted")
            break
        budget.charge("scad_autofix", note=f"direct_repair attempt {attempt}")
        notes.append(f"autofix attempt {attempt}")
        fix_result = autofixer.fix(code, original_prompt=prompt)
        if not fix_result.success or fix_result.code == code:
            notes.append(f"autofix attempt {attempt}: no change")
            continue
        code = fix_result.code
        scad_path.write_text(code, encoding="utf-8")
        if render_to_png(scad_path, png_path, timeout=180):
            budget.mark_succeeded("scad_autofix")
            return code, True, notes + [f"render succeeded after autofix {attempt}"]

    return code, False, notes


def variant_direct_vlm(
    client: OpenAI, vlm_corrector, budget: RecoveryBudget,
    prompt: str, scad_path: Path, png_path: Path, expected_parts: list[str],
    prompt_id: str,
) -> tuple[str, bool, list[str]]:
    """Direct codegen + VLM self-correction loop."""
    notes: list[str] = []
    code = direct_codegen(client, prompt)
    scad_path.write_text(code, encoding="utf-8")

    if not render_to_png(scad_path, png_path):
        notes.append("initial render failed; skipping VLM loop")
        return code, False, notes

    # Hook the VLM corrector up to this budget
    vlm_corrector.budget = budget
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    result = vlm_corrector.run_correction_loop(
        scad_code=code,
        original_prompt=prompt,
        expected_parts=expected_parts,
        scad_path=str(scad_path),
        timestamp=f"{timestamp}_{prompt_id}",
        kb_components=None,
    )
    notes.append(f"VLM iterations: {result.iterations}, approved: {result.success}")
    if result.final_code and result.final_code != code:
        code = result.final_code
        scad_path.write_text(code, encoding="utf-8")
        render_to_png(scad_path, png_path, timeout=180)
    return code, bool(result.success or result.final_passed), notes


def variant_direct_matched_calls(
    client: OpenAI, validator: Validator, budget: RecoveryBudget,
    prompt: str, scad_path: Path, png_path: Path, expected_parts: list[str],
    n_calls: int,
) -> tuple[str, bool, list[str]]:
    """N direct codegen calls with temperature jitter; keep highest-validator-score."""
    notes: list[str] = []
    best_code = ""
    best_score = -1.0
    for i in range(n_calls):
        # Slight temperature jitter so candidates aren't identical
        temp = 0.0 + (0.1 * (i % 4))
        try:
            code = direct_codegen(client, prompt, temperature=temp)
        except Exception as e:
            notes.append(f"call {i+1}: API error {e}")
            continue
        # Try to render this candidate
        cand_scad = scad_path.with_suffix(f".cand{i}.scad")
        cand_scad.write_text(code, encoding="utf-8")
        rendered = render_to_png(cand_scad, png_path)
        if rendered:
            v = validator.validate(code, expected_parts, prompt, str(cand_scad), str(png_path))
            score = v.score
        else:
            score = 0.0
        notes.append(f"call {i+1} (T={temp:.1f}): score={score:.2f} render={rendered}")
        if score > best_score:
            best_code = code
            best_score = score
        # Cleanup candidate file
        try:
            cand_scad.unlink()
        except OSError:
            pass

    if best_code:
        scad_path.write_text(best_code, encoding="utf-8")
        render_to_png(scad_path, png_path, timeout=180)
        notes.append(f"best score: {best_score:.2f} from {n_calls} calls")
        return best_code, best_score > 0, notes
    return "", False, notes + ["no candidate rendered"]


VARIANT_HANDLERS = {
    "direct_repair":        variant_direct_repair,
    "direct_vlm":           variant_direct_vlm,
    "direct_matched_calls": variant_direct_matched_calls,
}


# =============================================================================
# RUNNER
# =============================================================================

def load_prompts(dataset: str, ids: Optional[list[str]] = None) -> list[dict]:
    """Load prompts for the given dataset."""
    if dataset == "nopscadlib":
        gt = REPO_ROOT / "ground_truth" / "nopscadlib" / "benchmark_ground_truth.json"
        with gt.open() as f:
            data = json.load(f)
        prompts = [
            {"id": c["id"], "prompt": c["prompt"], "family": c["component_family"], "tier": c.get("tier", "")}
            for c in data["components"]
        ]
    elif dataset in ("abc", "slice100k"):
        gt = REPO_ROOT / "ground_truth" / dataset / f"{dataset}_ground_truth.json"
        with gt.open() as f:
            data = json.load(f)
        # external GT uses a slightly different field set; adapt loosely
        prompts = [
            {"id": k, "prompt": v.get("prompt", ""), "family": v.get("family", dataset), "tier": v.get("tier", "")}
            for k, v in data.items()
        ]
    else:
        raise SystemExit(f"Unknown dataset {dataset!r}")
    if ids:
        prompts = [p for p in prompts if p["id"] in ids]
    return prompts


def run_one(
    variant: str, p: dict, out_dir: Path,
    client: OpenAI, autofixer: SCADAutoFixer, vlm, validator: Validator,
    budget_size: int, matched_calls: int,
) -> MEResult:
    result = MEResult(
        prompt_id=p["id"], prompt_text=p["prompt"], family=p["family"], variant=variant,
    )
    start = time.time()
    budget = RecoveryBudget(total_attempts=budget_size)

    scad_path = out_dir / "scad" / f"{p['id']}.scad"
    png_path  = out_dir / "png"  / f"{p['id']}.png"
    stl_path  = out_dir / "stl"  / f"{p['id']}.stl"
    for d in (scad_path.parent, png_path.parent, stl_path.parent):
        d.mkdir(parents=True, exist_ok=True)

    try:
        if variant == "direct_repair":
            code, ok, notes = variant_direct_repair(
                client, autofixer, budget, p["prompt"], scad_path, png_path,
            )
        elif variant == "direct_vlm":
            code, ok, notes = variant_direct_vlm(
                client, vlm, budget, p["prompt"], scad_path, png_path,
                [p["family"].replace("_", " ")], p["id"],
            )
        elif variant == "direct_matched_calls":
            code, ok, notes = variant_direct_matched_calls(
                client, validator, budget, p["prompt"], scad_path, png_path,
                [p["family"].replace("_", " ")], matched_calls,
            )
        else:
            raise ValueError(f"Unknown variant {variant!r}")

        result.code = code
        result.code_length = len(code)
        result.scad_path = str(scad_path)
        result.render_ok = ok
        result.png_path = str(png_path) if png_path.exists() else None
        result.notes = notes

        # STL export
        if ok:
            stl_ok, _ = export_stl(str(scad_path), str(stl_path), timeout=300)
            if stl_ok:
                result.stl_ok = True
                result.stl_path = str(stl_path)
                result.success = True

    except Exception as e:
        result.error = str(e)
        traceback.print_exc()

    result.recovery_budget = budget.to_dict()
    result.total_time = time.time() - start
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Matched-effort baselines for CRAFT comparison")
    parser.add_argument("--dataset", choices=["nopscadlib", "abc", "slice100k"], default="nopscadlib")
    parser.add_argument(
        "--variants", nargs="+",
        choices=list(VARIANT_HANDLERS) + ["all"], default=["all"],
    )
    parser.add_argument("--ids", nargs="+", help="Specific prompt IDs only")
    parser.add_argument("--limit", type=int, help="Smoke test on first N prompts")
    parser.add_argument("--resume", action="store_true")
    parser.add_argument("--budget", type=int, default=10)
    parser.add_argument(
        "--matched-calls", type=int, default=DEFAULT_MATCHED_CALLS,
        help="N for direct_matched_calls (default 8, set to CRAFT's mean LLM-call count)",
    )
    parser.add_argument("--output-base", type=str, help="Override base output dir")
    args = parser.parse_args()

    variants = list(VARIANT_HANDLERS) if "all" in args.variants else args.variants
    prompts = load_prompts(args.dataset, args.ids)
    if args.limit:
        prompts = prompts[:args.limit]
    print(f"Loaded {len(prompts)} prompts for dataset={args.dataset}, variants={variants}")

    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    autofixer = SCADAutoFixer(client=None, model=MODEL_DIRECT)  # autofixer uses its own client internally
    validator = Validator(pass_threshold=0.80)

    # Optional VLM corrector — only needed for direct_vlm variant
    vlm = None
    if "direct_vlm" in variants:
        from core.llm_client import create_unified_client
        from core.visual_corrector import VisualSelfCorrector
        unified = create_unified_client(openai_client=client)
        vlm = VisualSelfCorrector(client=unified, model=MODEL_DIRECT, max_iterations=3)

    base = Path(args.output_base) if args.output_base else (REPO_ROOT / "results" / args.dataset / "matched_effort")

    failures = 0
    for variant in variants:
        out_dir = base / variant
        out_dir.mkdir(parents=True, exist_ok=True)
        results: list[MEResult] = []
        checkpoint = out_dir / "results.json"

        existing = {}
        if args.resume and checkpoint.exists():
            with checkpoint.open() as f:
                existing = {r["prompt_id"]: r for r in json.load(f).get("results", []) if r.get("success")}

        for i, p in enumerate(prompts):
            pid = p["id"]
            if args.resume and pid in existing:
                print(f"[{variant} {i+1}/{len(prompts)}] SKIP {pid}")
                # rehydrate
                r = MEResult(prompt_id=pid, prompt_text=p["prompt"], family=p["family"], variant=variant)
                for k, v in existing[pid].items():
                    if hasattr(r, k):
                        setattr(r, k, v)
                results.append(r)
                continue

            print(f"\n[{variant} {i+1}/{len(prompts)}] {pid}")
            r = run_one(
                variant, p, out_dir, client, autofixer, vlm, validator,
                args.budget, args.matched_calls,
            )
            results.append(r)
            print(f"  {'OK' if r.success else 'FAIL'}  {r.total_time:.1f}s  notes={r.notes[:2]}")

            # checkpoint
            with checkpoint.open("w") as f:
                json.dump({
                    "variant": variant,
                    "dataset": args.dataset,
                    "timestamp": datetime.now().isoformat(),
                    "total": len(results),
                    "success": sum(1 for x in results if x.success),
                    "results": [x.to_dict() for x in results],
                }, f, indent=2)

            time.sleep(0.5)  # gentle rate limit

        succ = sum(1 for x in results if x.success)
        print(f"\n[{variant}] {succ}/{len(results)} success")
        if succ < len(results) // 2:
            failures += 1

    return 0 if failures == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
