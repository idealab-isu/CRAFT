"""Score every sample under a single (benchmark, method) directory.

This is a STANDALONE CLI — designed to be invoked as its own subprocess so
that memory is fully reclaimed when the script exits. The orchestrator's
in-process scoring can OOM-kill on machines with constrained RAM (especially
x86_64-under-Rosetta on Apple Silicon, where trimesh + voxelization
allocations accumulate across the 50-sample loop). Running per-method as a
fresh process sidesteps that entirely.

Output: a single per-method JSON at
    results/zerotocad_eval/metrics/{benchmark}/{method_tag}.json
containing aggregate statistics (n, mean/median/p90 IoU, success, CD,
editability) plus the per-sample IoU and success arrays (for downstream
aggregation by aggregate_summary.py).

Each sample also gets `metrics.json` written into its method folder.
"""

from __future__ import annotations

import argparse
import gc
import json
import statistics
import sys
from pathlib import Path
from typing import Optional


_HERE = Path(__file__).resolve()
_REPO_ROOT = _HERE.parents[2]
if str(_REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(_REPO_ROOT))


def _stat(xs):
    if not xs:
        return {"n": 0, "mean": None, "median": None, "p90": None, "min": None, "max": None}
    sxs = sorted(xs)
    return {
        "n": len(xs),
        "mean": statistics.fmean(xs),
        "median": statistics.median(xs),
        "p90": sxs[max(0, int(round(0.9 * len(sxs))) - 1)],
        "min": sxs[0],
        "max": sxs[-1],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data-root", required=True,
                        help="Per-sample input root, e.g. Experimentation/.../data/ztc_test")
    parser.add_argument("--method-root", required=True,
                        help="Method output root, e.g. results/.../ztc_test/craft_v3")
    parser.add_argument("--method-tag", required=True,
                        help="Method tag for the output JSON filename.")
    parser.add_argument("--out-dir", required=True,
                        help="Where to write {method_tag}.json")
    parser.add_argument("--skip-cd", action="store_true",
                        help="Skip aligned-CD (much faster + lower memory).")
    parser.add_argument("--resume", action="store_true", default=True,
                        help="Skip samples that already have metrics.json (default: on).")
    args = parser.parse_args()

    from Experimentation.zerotocad_eval.score_sample import score_one

    data_root = Path(args.data_root).resolve()
    method_root = Path(args.method_root).resolve()
    out_dir = Path(args.out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    if not method_root.exists():
        print(f"[score_method] no outputs at {method_root}, writing empty summary.")
        (out_dir / f"{args.method_tag}.json").write_text(json.dumps({
            "method": args.method_tag, "n": 0, "samples": [],
        }, indent=2))
        return 0

    sample_records = []
    iou_xs, success_xs, cd_xs, edit_xs = [], [], [], []

    uuid_dirs = sorted([d for d in method_root.iterdir() if d.is_dir()])
    for i, udir in enumerate(uuid_dirs, 1):
        gt = data_root / udir.name / "gt.stl"
        if not gt.exists():
            continue

        metrics_path = udir / "metrics.json"
        if args.resume and metrics_path.exists():
            try:
                res = json.loads(metrics_path.read_text())
            except Exception:
                res = None
        else:
            res = None

        if res is None:
            res = score_one(gt, udir, include_cd=not args.skip_cd)
            metrics_path.write_text(json.dumps(res, indent=2))
            gc.collect()  # release trimesh / numpy temporaries between samples

        # Aggregate
        iou_xs.append(res["voxel_iou"]["iou"])
        success_xs.append(1 if res["success_rate"]["success"] else 0)
        if res.get("cd") and res["cd"].get("cd") is not None:
            cd_xs.append(res["cd"]["cd"])
        if res.get("editability") and res["editability"].get("editability") is not None:
            edit_xs.append(res["editability"]["editability"])

        sample_records.append({
            "uuid": udir.name,
            "iou": res["voxel_iou"]["iou"],
            "success": bool(res["success_rate"]["success"]),
            "cd": (res.get("cd") or {}).get("cd"),
            "editability": (res.get("editability") or {}).get("editability"),
            "n_faces": res["success_rate"].get("n_faces"),
        })

        if i % 10 == 0 or i == len(uuid_dirs):
            print(f"[score_method] {args.method_tag}: {i}/{len(uuid_dirs)}", flush=True)

    n = len(iou_xs)
    summary = {
        "method": args.method_tag,
        "benchmark": method_root.parent.name,
        "n": n,
        "success_rate": (sum(success_xs) / n) if n else 0.0,
        "voxel_iou": _stat(iou_xs),
        "cd": _stat(cd_xs),
        "editability": _stat(edit_xs),
        "samples": sample_records,
    }

    out_path = out_dir / f"{args.method_tag}.json"
    out_path.write_text(json.dumps(summary, indent=2))
    print(f"[score_method] wrote {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
