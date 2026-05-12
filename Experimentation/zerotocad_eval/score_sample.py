"""Score a single (method, sample) pair: voxel-IoU, Success Rate, CD, editability.

Layout assumed (matches CRAFT_zerotocad_eval_plan.md §14):

    data/zerotocad_eval/{benchmark}/{uuid}/gt.stl
    results/zerotocad_eval/{benchmark}/{method}/{uuid}/output.{scad|py}
    results/zerotocad_eval/{benchmark}/{method}/{uuid}/output.stl

This script reads from the layout, computes all four metrics, and writes
`metrics.json` into the method/uuid folder. The Phase 4/5 batch runner
just iterates over UUIDs and calls into this module.
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from dataclasses import asdict
from pathlib import Path
from typing import Optional

# Allow running as `python -m Experimentation.zerotocad_eval.score_sample`
# OR as `python score_sample.py` from inside the package dir.
_HERE = Path(__file__).resolve().parent
if str(_HERE.parent.parent) not in sys.path:
    sys.path.insert(0, str(_HERE.parent.parent))


def _find_code_file(method_dir: Path) -> Optional[Path]:
    """Pick the generated source file: prefer .scad, then .py, then .cadquery.py."""
    for name in ("output.scad", "output.py", "output.cadquery.py", "model.scad", "model.py"):
        p = method_dir / name
        if p.exists() and p.stat().st_size > 0:
            return p
    return None


def score_one(
    gt_stl: Path,
    method_dir: Path,
    include_cd: bool = True,
    voxel_resolution: int = 64,
) -> dict:
    """Score a single (method, sample) directory. Returns a flat dict for JSON."""
    from Experimentation.zerotocad_eval.metrics.success_rate import success_rate_for_sample
    from Experimentation.zerotocad_eval.metrics.editability import editability_for_code
    from Experimentation.zerotocad_eval.voxel_iou.score import score_stl_pair_safe

    code_path = _find_code_file(method_dir)
    stl_path = method_dir / "output.stl"

    t0 = time.time()
    sr = success_rate_for_sample(code_path, stl_path)
    t_sr = time.time() - t0

    t0 = time.time()
    if stl_path.exists() and gt_stl.exists():
        iou_res = score_stl_pair_safe(stl_path, gt_stl, resolution=voxel_resolution)
        iou = float(iou_res.iou)
    else:
        iou = 0.0
    t_iou = time.time() - t0

    edit = None
    if code_path is not None:
        # auto-detect language from extension
        hint = "openscad" if code_path.suffix == ".scad" else "cadquery"
        try:
            er = editability_for_code(code_path, language_hint=hint)
            edit = {
                "editability": er.editability,
                "parameter_refs": er.parameter_refs,
                "numeric_literals": er.numeric_literals,
                "language": er.language,
            }
        except Exception as e:
            edit = {"error": f"{type(e).__name__}: {e}"}

    cd_block = None
    if include_cd and stl_path.exists() and gt_stl.exists():
        t0 = time.time()
        try:
            from Experimentation.zerotocad_eval.cd.score import score_cd_pair
            cd_res = score_cd_pair(stl_path, gt_stl)
            cd_block = (
                {"cd": cd_res.cd, "n_points": cd_res.n_points, "used_icp": cd_res.used_icp}
                if cd_res is not None
                else {"cd": None, "error": "load_or_align_failed"}
            )
        except Exception as e:
            cd_block = {"cd": None, "error": f"{type(e).__name__}: {e}"}
        t_cd = time.time() - t0
    else:
        t_cd = 0.0

    return {
        "uuid": method_dir.name,
        "method": method_dir.parent.name,
        "benchmark": method_dir.parent.parent.name,
        "success_rate": {**asdict(sr)},
        "voxel_iou": {"iou": iou, "resolution": voxel_resolution, "rotations": 24},
        "cd": cd_block,
        "editability": edit,
        "timing_seconds": {"success_rate": t_sr, "voxel_iou": t_iou, "cd": t_cd},
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Score one (method, sample) directory.")
    parser.add_argument("--gt-stl", required=True, help="Path to ground-truth STL.")
    parser.add_argument(
        "--method-dir",
        required=True,
        help="Method output directory (must contain output.{scad,py} and output.stl).",
    )
    parser.add_argument("--no-cd", action="store_true", help="Skip aligned-CD (slower).")
    parser.add_argument("--resolution", type=int, default=64, help="Voxel resolution (default 64).")
    parser.add_argument("--out", default=None, help="Where to write metrics.json (default: method_dir/metrics.json).")
    args = parser.parse_args()

    gt = Path(args.gt_stl).resolve()
    method_dir = Path(args.method_dir).resolve()
    out_path = Path(args.out) if args.out else method_dir / "metrics.json"

    result = score_one(gt, method_dir, include_cd=not args.no_cd, voxel_resolution=args.resolution)
    out_path.write_text(json.dumps(result, indent=2))
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
