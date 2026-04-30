#!/usr/bin/env python3
"""
CRAFT v4 — Oracle-CD ablation runner.

This is the oracle ablation companion to ``run_v4_benchmark.py``. It is NOT
the deployable system. It exists ONLY to produce an upper-bound figure for
the paper:

    "If our regression gate were perfect, v4 would beat baseline by X%.
     Our actual gate captures Y% of that."

Why this is *not* cheating (when reported as ablation):
- We replace the inference-only gate with a ground-truth-based selector
  that picks whichever of {baseline, patched} has lower Chamfer Distance
  to the dataset's ground-truth STL.
- We DO NOT use this anywhere in the deployable system. The deployable
  number is whatever ``run_v4_benchmark.py`` produces.
- The oracle number is a soft-ceiling reference for reviewers.

Inputs:
- A v4 benchmark output directory (from run_v4_benchmark.py) — needs
  per-prompt ``runs/<id>/baseline.stl`` and ``runs/<id>/patched.stl``.
- A ground-truth STL directory (matching ``<id>.stl`` filenames).

Outputs:
- ``<out_dir>/<dataset>/v4_oracle/{scad,stl,png}/<id>.{...}`` — the chosen
  oracle pick per prompt (baseline OR patched).
- ``<out_dir>/<dataset>/v4_oracle/oracle_log.json`` — per-prompt CD scores
  + which one won + agreement with the deployable gate.
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path
from typing import Dict, List, Optional

# Use the canonical aligned-CD scorer (10k pts, PCA + 24 rotations + ICP)
# from Experimentation/Chamfer_distance/align_and_score.py — same code path
# that produced the published craft / gpt52 / gpt4o numbers.
_REPO_ROOT = Path(__file__).resolve().parent.parent.parent
_ALIGN_DIR = _REPO_ROOT / "Experimentation" / "Chamfer_distance"
if not _ALIGN_DIR.is_dir():
    raise SystemExit(
        f"oracle ablation needs {_ALIGN_DIR}/align_and_score.py "
        f"but the directory was not found."
    )
sys.path.insert(0, str(_ALIGN_DIR))

from align_and_score import score_stl_pair  # noqa: E402

_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(_PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PIPELINE_ROOT))


def cd_safe(
    pred_stl: Optional[Path],
    gt_stl: Optional[Path],
    n_points: int,
    use_icp: bool,
    seed: int,
) -> Optional[float]:
    """Run the aligned Chamfer scorer on a pair of STLs."""
    if pred_stl is None or gt_stl is None:
        return None
    if not Path(pred_stl).exists() or not Path(gt_stl).exists():
        return None
    if Path(pred_stl).stat().st_size == 0:
        return None
    result = score_stl_pair(
        pred_stl=Path(pred_stl),
        gt_stl=Path(gt_stl),
        n_points=n_points,
        seed=seed,
        use_icp=use_icp,
    )
    return float(result.chamfer) if result is not None else None


def main() -> int:
    ap = argparse.ArgumentParser(description="CRAFT v4 oracle-CD ablation.")
    ap.add_argument("--v4-dir", required=True,
                    help="Path to results/v4/<dataset>/v4 produced by run_v4_benchmark.py.")
    ap.add_argument("--gt-dir", required=True,
                    help="Directory containing <id>.stl ground-truth meshes.")
    ap.add_argument("--out-dir", default=None,
                    help="Output directory (defaults to sibling 'v4_oracle' next to --v4-dir).")
    ap.add_argument("--n-points", type=int, default=10_000,
                    help="Surface samples (matches run_eval.py default).")
    ap.add_argument("--no-icp", action="store_true",
                    help="Disable ICP refinement (faster).")
    ap.add_argument("--seed", type=int, default=42)
    args = ap.parse_args()

    v4_dir = Path(args.v4_dir).resolve()
    gt_dir = Path(args.gt_dir).resolve()
    if not v4_dir.is_dir():
        print(f"v4 dir not found: {v4_dir}")
        return 2
    if not gt_dir.is_dir():
        print(f"gt dir not found: {gt_dir}")
        return 2

    out_dir = Path(args.out_dir) if args.out_dir else v4_dir.parent / "v4_oracle"
    (out_dir / "scad").mkdir(parents=True, exist_ok=True)
    (out_dir / "stl").mkdir(parents=True, exist_ok=True)
    (out_dir / "png").mkdir(parents=True, exist_ok=True)

    runs_dir = v4_dir / "runs"
    if not runs_dir.is_dir():
        print(f"No runs/ subdirectory at {runs_dir}; did run_v4_benchmark.py finish?")
        return 2

    log: List[dict] = []
    agreed = 0
    n_with_choice = 0

    for run_dir in sorted(runs_dir.iterdir()):
        if not run_dir.is_dir():
            continue
        prompt_id = run_dir.name
        baseline_stl = run_dir / "baseline.stl"
        patched_stl = run_dir / "patched.stl"
        gt_stl = gt_dir / f"{prompt_id}.stl"
        if not gt_stl.exists():
            print(f"[{prompt_id}] no ground-truth STL ({gt_stl}); skip")
            continue

        cd_baseline = cd_safe(
            baseline_stl, gt_stl,
            n_points=args.n_points, use_icp=not args.no_icp, seed=args.seed,
        )
        cd_patched = (
            cd_safe(
                patched_stl, gt_stl,
                n_points=args.n_points, use_icp=not args.no_icp, seed=args.seed,
            )
            if patched_stl.exists() else None
        )

        # Oracle pick
        if cd_baseline is None and cd_patched is None:
            oracle_pick = "none"
        elif cd_patched is None:
            oracle_pick = "baseline"
        elif cd_baseline is None:
            oracle_pick = "patched"
        else:
            oracle_pick = "patched" if cd_patched < cd_baseline else "baseline"

        # Read what the deployable gate chose
        audit_path = run_dir / "audit.json"
        deployable_pick = "unknown"
        if audit_path.exists():
            try:
                deployable_pick = json.loads(audit_path.read_text()).get("chosen", "unknown")
            except Exception:
                pass

        if oracle_pick != "none" and deployable_pick != "unknown":
            n_with_choice += 1
            if oracle_pick == deployable_pick:
                agreed += 1

        # Materialise oracle pick into the standard layout
        if oracle_pick == "patched":
            src_scad = run_dir / "patched.scad"
            src_stl = patched_stl
        elif oracle_pick == "baseline":
            src_scad = run_dir / "baseline.scad"
            src_stl = baseline_stl
        else:
            src_scad = None
            src_stl = None

        if src_scad and src_scad.exists():
            shutil.copyfile(src_scad, out_dir / "scad" / f"{prompt_id}.scad")
        if src_stl and Path(src_stl).exists() and Path(src_stl).stat().st_size > 0:
            shutil.copyfile(src_stl, out_dir / "stl" / f"{prompt_id}.stl")

        log.append({
            "prompt_id": prompt_id,
            "cd_baseline": cd_baseline,
            "cd_patched": cd_patched,
            "oracle_pick": oracle_pick,
            "deployable_pick": deployable_pick,
            "agreement": oracle_pick == deployable_pick if oracle_pick != "none" else None,
        })
        print(
            f"[{prompt_id}] cd_baseline={cd_baseline} cd_patched={cd_patched} "
            f"oracle={oracle_pick} deployable={deployable_pick}"
        )

    out_log = out_dir / "oracle_log.json"
    with open(out_log, "w") as f:
        json.dump({
            "n_prompts": len(log),
            "n_with_both_picks": n_with_choice,
            "n_agree": agreed,
            "agreement_rate": (agreed / n_with_choice) if n_with_choice else None,
            "per_prompt": log,
        }, f, indent=2, default=str)

    print(f"\n[oracle] log → {out_log}")
    if n_with_choice:
        print(
            f"[oracle] gate agreement: {agreed}/{n_with_choice} = "
            f"{agreed/n_with_choice:.1%}"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
