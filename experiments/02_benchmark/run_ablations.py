#!/usr/bin/env python3
"""
Ablation runner — launches CRAFT with one component disabled per variant.

Five variants, each writing to its own results/<dataset>/ablations/<variant>/
directory. Internally delegates to run_craft.py (NopSCADlib) or run_external.py
(ABC, Slice-100K) by setting the appropriate CLI flags.

Variants:
  no_json_ir       — bypass planner+compiler with direct text→SCAD codegen
  no_retrieval     — disable KB retrieval (and dimensional matcher leak)
  no_multiview     — disable VLM self-correction (Stage 5)
  no_verification  — disable component verification (Stage 6)
  no_recovery      — disable all recovery layers (no VLM + no verify + auto_repair off)

Usage:
  # Run every variant on NopSCADlib
  python experiments/02_benchmark/run_ablations.py --dataset nopscadlib

  # Run a single variant on ABC
  python experiments/02_benchmark/run_ablations.py --dataset abc --variants no_json_ir

  # Smoke test with a subset
  python experiments/02_benchmark/run_ablations.py --dataset nopscadlib --variants no_json_ir --limit 5
"""
from __future__ import annotations

import argparse
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent


# variant → (description, list of run_craft.py CLI flags)
VARIANTS = {
    "no_json_ir": (
        "Bypass planner+compiler with single LLM call → SCAD",
        ["--no-json-ir"],
    ),
    "no_retrieval": (
        "Disable KB retrieval and dimensional matcher",
        ["--no-kb"],
    ),
    "no_multiview": (
        "Disable VLM self-correction (Stage 5)",
        ["--no-vlm"],
    ),
    "no_verification": (
        "Disable component verification (Stage 6)",
        ["--no-verify"],
    ),
    "no_recovery": (
        "Disable all recovery layers (no VLM, no verify, no auto-repair)",
        ["--no-recovery"],
    ),
}


def run_variant(dataset: str, variant: str, common_flags: list[str]) -> int:
    """Launch a single ablation variant; return its exit code."""
    description, variant_flags = VARIANTS[variant]
    out_dir = REPO_ROOT / "results" / dataset / "ablations" / variant
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n{'='*72}")
    print(f"ABLATION: {variant}")
    print(f"  Description: {description}")
    print(f"  Dataset:     {dataset}")
    print(f"  Output:      {out_dir.relative_to(REPO_ROOT)}")
    print(f"{'='*72}")

    if dataset == "nopscadlib":
        runner = SCRIPT_DIR / "run_craft.py"
        cmd = [
            sys.executable, str(runner),
            "--output-dir", str(out_dir),
            *variant_flags,
            *common_flags,
        ]
    elif dataset in ("abc", "slice100k"):
        runner = SCRIPT_DIR / "run_external.py"
        cmd = [
            sys.executable, str(runner),
            "--dataset-name", dataset,
            "--models", "craft",
            "--output-base", str(out_dir.parent),  # writes under <base>/<dataset>/craft/
            "--variant-name", variant,
            *variant_flags,
            *common_flags,
        ]
    else:
        raise SystemExit(f"Unknown dataset {dataset!r}")

    print(f"  Cmd: {' '.join(cmd)}")
    print()
    return subprocess.call(cmd)


def main() -> int:
    parser = argparse.ArgumentParser(description="CRAFT ablation runner")
    parser.add_argument(
        "--dataset", choices=["nopscadlib", "abc", "slice100k"], default="nopscadlib",
        help="Which dataset to ablate on (default: nopscadlib)",
    )
    parser.add_argument(
        "--variants", nargs="+", choices=list(VARIANTS) + ["all"], default=["all"],
        help="Which ablation variants to run (default: all)",
    )
    parser.add_argument("--limit", type=int, help="Smoke test on first N prompts")
    parser.add_argument("--resume", action="store_true", help="Resume from checkpoint in each variant dir")
    parser.add_argument("--budget", type=int, default=10, help="Shared recovery budget (default 10)")
    args = parser.parse_args()

    variants = list(VARIANTS) if "all" in args.variants else args.variants

    # Flags that propagate to every variant
    common = ["--budget", str(args.budget)]
    if args.limit:
        common += ["--limit", str(args.limit)]
    if args.resume:
        common += ["--resume"]

    failures = []
    for v in variants:
        rc = run_variant(args.dataset, v, common)
        if rc != 0:
            failures.append((v, rc))

    print(f"\n{'='*72}")
    print(f"ABLATION SWEEP COMPLETE")
    print(f"  Ran: {variants}")
    if failures:
        print(f"  Failures:")
        for v, rc in failures:
            print(f"    {v}: exit code {rc}")
        return 1
    print(f"  All variants exited cleanly.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
