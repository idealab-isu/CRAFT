#!/usr/bin/env python3
"""
Run CRAFT v1 on the canonical 30 v2 prompts (or any v2 subset).

Reuses the existing CRAFTPipeline from run_nopscadlib_benchmark.py — full
v1 pipeline (reasoner → planner → compiler → render → VLM correction →
component verification), with KB/RAG enabled by default.

Output layout matches the rest of CRAFT so downstream metric scripts pick
it up automatically:

    <out_dir>/<dataset>/craft_v1/scad/<id>.scad
    <out_dir>/<dataset>/craft_v1/stl/<id>.stl
    <out_dir>/<dataset>/craft_v1/png/<id>.png
    <out_dir>/<dataset>/craft_v1/runs/<id>/{craft.scad,craft.stl,craft.png,audit.json}
    <out_dir>/<dataset>/craft_v1/results.json

After this completes, stage into the canonical CD eval directory:

    cd /Users/mohd7/Local/CRAFT/Experimentation/Chamfer_distance
    rm -rf stls/craft && mkdir -p stls/craft
    cp /Users/mohd7/Local/CRAFT/results/v4/v2/craft_v1/stl/*.stl stls/craft/

Resume support: rerunning skips prompts whose audit.json exists.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import time
from pathlib import Path

_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
_REPO_ROOT = _PIPELINE_ROOT.parent
for p in (_REPO_ROOT, _PIPELINE_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from openai import OpenAI
from dotenv import load_dotenv
load_dotenv()

# Reuse the existing CRAFTPipeline + helpers from the in-pipeline benchmark.
from evaluation.run_nopscadlib_benchmark import (  # noqa: E402
    CRAFTPipeline,
    BenchmarkPrompt,
    save_scad,
    render_image,
    render_stl,
)

# Reuse the v2 prompt loader.
from evaluation.run_v4_benchmark import load_v2_prompts  # noqa: E402


def _make_minimal_prompt(p: dict) -> BenchmarkPrompt:
    """Convert a v2 prompt dict to the BenchmarkPrompt dataclass that
    CRAFTPipeline expects. Parts lists are empty — CRAFT v1 detects its
    own components in the reasoner."""
    return BenchmarkPrompt(
        id=p["id"],
        text=p["text"],
        category=p.get("tier", "Unknown").lower(),
        ground_truth_scad="",
        expected_parts=[],
        essential_parts=[],
        secondary_parts=[],
        optional_parts=[],
        nopscadlib_keywords=[],
    )


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--benchmark-json", default=None,
                    help="Path to benchmark_ground_truth_v2.json (default auto).")
    ap.add_argument("--ids", nargs="*", default=None,
                    help="Restrict to these prompt IDs.")
    ap.add_argument("--all", action="store_true",
                    help="Skip canonical-30 default and use every component.")
    ap.add_argument("--tier", default=None,
                    help="Restrict to one or more tiers (e.g. 'Simple,Medium').")
    ap.add_argument("--n-prompts", type=int, default=None,
                    help="Random-sample N prompts after tier filter.")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--out-dir", default="./results/v4")
    ap.add_argument("--dataset-name", default="v2")
    ap.add_argument("--use-rag", action="store_true", default=True,
                    help="Enable NopSCADlib KB retrieval (matches your "
                         "previously-published craft column).")
    ap.add_argument("--no-rag", dest="use_rag", action="store_false")
    ap.add_argument("--pipeline-model", default="gpt-4o",
                    help="Model for reasoner/compiler/repair (CRAFT v1 default).")
    ap.add_argument("--vlm-model", default="gpt-5.2",
                    help="Vision model for correction + verification.")
    ap.add_argument("--no-vlm", action="store_true",
                    help="Disable VLM correction loop.")
    ap.add_argument("--no-verify", action="store_true",
                    help="Disable component verification loop.")
    ap.add_argument("--force", action="store_true",
                    help="Re-run prompts even if audit.json exists.")
    args = ap.parse_args()

    prompts = load_v2_prompts(
        benchmark_json=args.benchmark_json,
        ids=args.ids,
        use_canonical_30=not args.all,
        tier=args.tier,
        n_prompts=args.n_prompts,
        seed=args.seed,
    )
    if not prompts:
        print("No prompts loaded.")
        return 2

    out_dir = Path(args.out_dir) / args.dataset_name / "craft_v1"
    for sub in ["scad", "stl", "png", "runs"]:
        (out_dir / sub).mkdir(parents=True, exist_ok=True)

    print(f"[craft_v1] {len(prompts)} prompts → {out_dir}")
    print(f"[craft_v1] config: pipeline={args.pipeline_model} vlm={args.vlm_model} "
          f"rag={args.use_rag} vlm_correction={not args.no_vlm} "
          f"verify={not args.no_verify}")

    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    pipeline = CRAFTPipeline(
        client,
        pipeline_model=args.pipeline_model,
        vlm_model=args.vlm_model,
        use_rag=args.use_rag,
        use_vlm=not args.no_vlm,
        use_verification=not args.no_verify,
    )

    summary: list = []
    for idx, p in enumerate(prompts, 1):
        prompt_id = p["id"]
        run_dir = out_dir / "runs" / prompt_id
        audit_path = run_dir / "audit.json"

        if audit_path.exists() and not args.force:
            print(f"[{idx}/{len(prompts)}] {prompt_id}: skip (audit exists)")
            try:
                summary.append(json.loads(audit_path.read_text()))
            except Exception:
                pass
            continue

        run_dir.mkdir(parents=True, exist_ok=True)
        scad_path = run_dir / "craft.scad"
        png_path = run_dir / "craft.png"
        stl_path = run_dir / "craft.stl"

        bp = _make_minimal_prompt(p)

        print(f"[{idx}/{len(prompts)}] {prompt_id}: {p['text'][:60]}...")
        t0 = time.time()
        code = ""
        info: dict = {}
        try:
            code, gen_time, info = pipeline.generate(
                p["text"], bp, str(scad_path), str(png_path)
            )
        except Exception as e:
            print(f"  ERROR generating: {e}")
        elapsed = time.time() - t0

        # Export STL from final SCAD
        stl_ok = False
        if code and scad_path.exists():
            try:
                stl_ok = render_stl(str(scad_path), str(stl_path))
            except Exception as e:
                print(f"  ERROR exporting STL: {e}")

        # Materialise into the standard layout
        if code and scad_path.exists():
            shutil.copyfile(scad_path, out_dir / "scad" / f"{prompt_id}.scad")
        if stl_ok and stl_path.exists() and stl_path.stat().st_size > 0:
            shutil.copyfile(stl_path, out_dir / "stl" / f"{prompt_id}.stl")
        if png_path.exists() and png_path.stat().st_size > 0:
            shutil.copyfile(png_path, out_dir / "png" / f"{prompt_id}.png")

        audit = {
            "prompt_id": prompt_id,
            "prompt_text": p["text"],
            "tier": p.get("tier", "?"),
            "code_length": len(code) if code else 0,
            "stl_ok": stl_ok,
            "elapsed_s": elapsed,
            "info": info,
        }
        with open(audit_path, "w") as f:
            json.dump(audit, f, indent=2, default=str)
        summary.append(audit)

        print(f"  → stl_ok={stl_ok}  {elapsed:.1f}s")

    with open(out_dir / "results.json", "w") as f:
        json.dump(summary, f, indent=2, default=str)

    n_ok = sum(1 for r in summary if r.get("stl_ok"))
    print(f"\n[craft_v1] {n_ok}/{len(summary)} STLs produced")
    print(f"[craft_v1] outputs at {out_dir}")
    print(f"[craft_v1] next:")
    print(f"    cd /Users/mohd7/Local/CRAFT/Experimentation/Chamfer_distance")
    print(f"    rm -rf stls/craft && mkdir -p stls/craft")
    print(f"    cp {out_dir}/stl/*.stl stls/craft/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
