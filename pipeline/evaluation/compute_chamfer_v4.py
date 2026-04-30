#!/usr/bin/env python3
"""
CRAFT v4 — Multi-method Chamfer comparison (delegates to align_and_score).

THIN WRAPPER. The actual alignment + Chamfer maths lives in
``Experimentation/Chamfer_distance/align_and_score.py`` (10k points,
unit bounding-sphere normalisation, PCA canonicalisation, 24 cube
rotations, ICP refinement). This module exists only to:

    - run that scorer over multiple methods at once
    - aggregate per-prompt CDs into a comparison table

so the v4 column lands in the same shape as ``run_eval.py``'s output but
without forcing you to physically stage every method's STLs into
``Experimentation/Chamfer_distance/stls/`` first.

If you already have everything staged into ``Experimentation/Chamfer_distance/stls/<method>/``,
prefer running ``Experimentation/Chamfer_distance/run_eval.py`` directly —
it's the script that produced your existing published numbers.

Inputs:
    --gt-dir          Directory of ground-truth ``<id>.stl`` files.
    --results-root    Root containing ``<method>/stl/<id>.stl`` (or just
                      ``<method>/<id>.stl`` — both layouts handled).
    --methods         Method subdirectory names.

Outputs:
    Console table + JSON (--out) with per-prompt CDs.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path
from typing import Dict, List, Optional

import numpy as np

# ----- locate align_and_score.py and import its scorer -----------------
# The canonical alignment + CD pipeline lives outside `pipeline/`.
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
_ALIGN_DIR = _REPO_ROOT / "Experimentation" / "Chamfer_distance"
if not _ALIGN_DIR.is_dir():
    raise SystemExit(
        f"compute_chamfer_v4 needs Experimentation/Chamfer_distance/align_and_score.py "
        f"but {_ALIGN_DIR} does not exist."
    )
sys.path.insert(0, str(_ALIGN_DIR))

from align_and_score import score_stl_pair, AlignmentResult  # noqa: E402


def _resolve_pred_stl(method_root: Path, prompt_id: str) -> Optional[Path]:
    """Find the predicted STL under either ``<method>/stl/<id>.stl`` or
    ``<method>/<id>.stl``."""
    for candidate in (
        method_root / "stl" / f"{prompt_id}.stl",
        method_root / f"{prompt_id}.stl",
    ):
        if candidate.exists() and candidate.stat().st_size > 0:
            return candidate
    return None


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--gt-dir", required=True,
                    help="Directory of ground-truth STLs (<id>.stl).")
    ap.add_argument("--results-root", required=True,
                    help="Root that contains <method>/stl/<id>.stl per method.")
    ap.add_argument("--methods", nargs="+", required=True,
                    help="Method subdirectory names (e.g. gpt4o gpt52 craft v4).")
    ap.add_argument("--dataset", default="dataset")
    ap.add_argument("--out", default="metrics.json")
    ap.add_argument("--n-points", type=int, default=10_000,
                    help="Surface samples per mesh (matches run_eval.py default).")
    ap.add_argument("--no-icp", action="store_true",
                    help="Disable ICP refinement (faster, slightly less robust).")
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    gt_dir = Path(args.gt_dir).resolve()
    results_root = Path(args.results_root).resolve()
    if not gt_dir.is_dir() or not results_root.is_dir():
        print("Bad paths:", gt_dir, results_root)
        return 2

    ids = sorted(p.stem for p in gt_dir.glob("*.stl"))
    if not ids:
        print(f"No ground-truth STLs in {gt_dir}")
        return 2
    print(
        f"[metrics] {len(ids)} prompts; methods: {args.methods} "
        f"({args.n_points} pts, ICP={'off' if args.no_icp else 'on'})"
    )

    per_method: Dict[str, List[dict]] = {m: [] for m in args.methods}
    for prompt_id in ids:
        gt_stl = gt_dir / f"{prompt_id}.stl"
        for method in args.methods:
            pred_stl = _resolve_pred_stl(results_root / method, prompt_id)
            if pred_stl is None:
                per_method[method].append({"prompt_id": prompt_id, "missing": True})
                continue

            t0 = time.time()
            result: Optional[AlignmentResult] = score_stl_pair(
                pred_stl=pred_stl,
                gt_stl=gt_stl,
                n_points=args.n_points,
                seed=args.seed,
                use_icp=not args.no_icp,
            )
            dt = time.time() - t0

            if result is None:
                per_method[method].append({
                    "prompt_id": prompt_id, "missing": True, "error": "load_failed",
                })
                continue

            per_method[method].append({
                "prompt_id": prompt_id,
                "chamfer": result.chamfer,
                "chamfer_raw": result.chamfer_raw,
                "best_init_index": result.best_init_index,
                "seconds": dt,
            })

    # Aggregate.
    aggregated: Dict[str, Dict[str, float]] = {}
    for method, rows in per_method.items():
        valid = [r for r in rows if "chamfer" in r]
        if not valid:
            aggregated[method] = {"n_valid": 0}
            continue
        vals = np.array([r["chamfer"] for r in valid])
        raw_vals = np.array([r["chamfer_raw"] for r in valid])
        aggregated[method] = {
            "n_valid": len(valid),
            "n_total": len(rows),
            "cd_mean": float(np.mean(vals)),
            "cd_median": float(np.median(vals)),
            "cd_raw_mean": float(np.mean(raw_vals)),
        }

    # Pretty table to stdout.
    print("\n=== Aligned Chamfer Distance (lower is better) ===")
    header = f"{'method':<10} {'N':>5} {'CD↓ aligned':>14} {'CD raw':>12}"
    print(header)
    print("-" * len(header))
    for method in args.methods:
        a = aggregated[method]
        if a.get("n_valid"):
            print(
                f"{method:<10} {a['n_valid']:>5} {a['cd_mean']:>14.5f} "
                f"{a['cd_raw_mean']:>12.5f}"
            )
        else:
            print(f"{method:<10} {0:>5} {'-':>14} {'-':>12}")
    print()

    out = {
        "config": {
            "n_points": args.n_points,
            "use_icp": not args.no_icp,
            "seed": args.seed,
            "methods": args.methods,
            "dataset": args.dataset,
            "ground_truth_dir": str(gt_dir),
            "results_root": str(results_root),
            "scorer": "Experimentation/Chamfer_distance/align_and_score.py",
        },
        "n_prompts": len(ids),
        "aggregated": aggregated,
        "per_method": per_method,
    }
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    with open(args.out, "w") as f:
        json.dump(out, f, indent=2, default=str)
    print(f"[metrics] wrote → {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
