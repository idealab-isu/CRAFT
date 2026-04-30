"""
CRAFT v4 — Single-prompt CLI entry point.

Usage:

    python -m pipeline.v4.cli --prompt "a 608 skateboard bearing" \
        --out ./v4_out/test01

    python -m pipeline.v4.cli --prompt-id bench_simple_01 \
        --prompt "a 608 skateboard bearing" \
        --out ./v4_out --no-kb
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

# Pipeline-root import shim.
_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(_PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PIPELINE_ROOT))

from v4.runner import V4Config, V4Runner  # noqa: E402


def main() -> int:
    p = argparse.ArgumentParser(description="Run CRAFT v4 on a single prompt.")
    p.add_argument("--prompt", required=True, help="Natural-language prompt.")
    p.add_argument("--prompt-id", default="adhoc", help="Identifier for the run subdirectory.")
    p.add_argument("--out", default="./v4_out", help="Output directory.")
    p.add_argument(
        "--baseline-models", nargs="+", default=["gpt-5.2", "gpt-4o"],
        help=(
            "List of Stage-0 generators to race in parallel. The first "
            "is the tie-break preference. Default: gpt-5.2 gpt-4o (oracle "
            "data shows gpt-4o wins on simple primitive geometry; gpt-5.2 "
            "wins on complex assemblies)."
        ),
    )
    p.add_argument("--baseline-model", default=None,
                   help="(legacy) single baseline model; overrides --baseline-models.")
    p.add_argument("--assessor-model", default="gpt-5.2")
    p.add_argument("--patcher-model", default="gpt-5.2")
    p.add_argument("--no-kb", action="store_true", help="Disable KB reference lookup.")
    p.add_argument("--no-patch", action="store_true", help="Run baseline + assess only.")
    p.add_argument("--sketch", default=None, help="Optional reference sketch image.")
    p.add_argument("--min-patch-gain", type=int, default=2,
                   help="Patch must add this many passing criteria to be kept "
                        "(default 2; canonical-30 data shows margin=1 is too "
                        "noisy).")
    p.add_argument("--external-baseline", action="append", default=[],
                   metavar="NAME=DIR",
                   help="Add a pre-generated SCAD baseline directory as a "
                        "candidate (e.g. craft-v1=../results/v4/v2/craft_v1). "
                        "Repeatable.")
    args = p.parse_args()

    external_baselines = {}
    for spec in args.external_baseline:
        if "=" not in spec:
            print(f"--external-baseline expects NAME=DIR (got {spec!r})")
            return 2
        name, path = spec.split("=", 1)
        external_baselines[name.strip()] = path.strip()

    cfg = V4Config(
        baseline_models=list(args.baseline_models),
        baseline_model=args.baseline_model,
        external_baselines=external_baselines,
        assessor_model=args.assessor_model,
        patcher_model=args.patcher_model,
        use_kb=not args.no_kb,
        enable_patch=not args.no_patch,
        min_patch_gain=args.min_patch_gain,
        sketch_path=args.sketch,
    )
    runner = V4Runner(config=cfg)

    out_dir = os.path.join(args.out, args.prompt_id)
    result = runner.run(prompt_id=args.prompt_id, prompt_text=args.prompt, out_dir=out_dir)

    print("=" * 70)
    print(f"prompt_id          : {result.prompt_id}")
    print(f"chose final        : {result.chosen}")
    print(f"chosen baseline    : {result.chosen_baseline_model}  ({result.chosen_baseline_reason})")
    if result.baselines:
        print(f"baseline candidates:")
        for b in result.baselines:
            if b.get("ok"):
                print(
                    f"  {b['model']:<10}  pass={b['criteria_pass']}/{b['criteria_total']}  "
                    f"failed_views={b['num_failed_views']}  stl_ok={b['stl_success']}"
                )
            else:
                print(f"  {b['model']:<10}  FAIL  ({b.get('error')})")
    print(f"baseline pass: {result.baseline_criteria_pass}/{result.baseline_criteria_total}")
    print(f"patched  pass: {result.patched_criteria_pass}/{result.patched_criteria_total}")
    print(f"gate reason  : {result.gate_reason}")
    print(f"final scad   : {os.path.join(out_dir, 'final.scad')}")
    print(f"final stl    : {os.path.join(out_dir, 'final.stl')}")
    print(f"audit        : {os.path.join(out_dir, 'audit.json')}")
    if result.errors:
        print("errors       :")
        for e in result.errors:
            print(f"  - {e}")
    print("=" * 70)
    return 0 if not result.errors else 1


if __name__ == "__main__":
    sys.exit(main())
