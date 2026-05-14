#!/usr/bin/env python3
"""
Visual audit for aligned Chamfer Distance stages.

This script is intentionally tied to `align_and_score.py` so the same
normalization/alignment math used in reporting is what gets visualized.

For each (dataset, sample_id, method) pair it exports:
  - Stage overlays (raw -> normalized -> PCA -> best rotation -> best ICP)
  - Rotation sweep chart across the 24 cube rotations
  - Per-stage numeric checks in JSON

Default datasets:
  - nopscadlib (from pipeline/evaluation/nopscadlib_benchmark/20260427_184749)
  - abc       (from results/abc/eval)
  - slice100k (from results/slice100k/eval)
"""

from __future__ import annotations

import argparse
import json
import random
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Tuple

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt

from align_and_score import (
    chamfer_distance,
    cube_rotation_group,
    icp_refine,
    load_and_sample,
    normalize_unit_sphere,
    pca_canonicalize,
)

METHODS = ("craft", "gpt4o", "gpt52")


@dataclass(frozen=True)
class PairPaths:
    gt_stl: Path
    pred_stl: Path


def _list_common_ids_ext(eval_root: Path, methods: Tuple[str, ...]) -> List[str]:
    gt_dir = eval_root / "ground_truth"
    if not gt_dir.is_dir():
        return []
    ids = {p.stem for p in gt_dir.glob("*.stl")}
    for method in methods:
        stl_dir = eval_root / method / "stl"
        ids &= {p.stem for p in stl_dir.glob("*.stl")} if stl_dir.is_dir() else set()
    return sorted(ids)


def _list_common_ids_nop(root: Path, methods: Tuple[str, ...]) -> List[str]:
    stl_dir = root / "stl"
    if not stl_dir.is_dir():
        return []
    gt_ids = {
        p.name[: -len("_gt.stl")]
        for p in stl_dir.glob("*_gt.stl")
        if p.name.endswith("_gt.stl")
    }
    for method in methods:
        method_ids = {
            p.name[: -len(f"_{method}.stl")]
            for p in stl_dir.glob(f"*_{method}.stl")
            if p.name.endswith(f"_{method}.stl")
        }
        gt_ids &= method_ids
    return sorted(gt_ids)


def _build_paths(dataset: str, sample_id: str, method: str, roots: Dict[str, Path]) -> PairPaths:
    if dataset == "nopscadlib":
        stl_dir = roots["nopscadlib"] / "stl"
        return PairPaths(
            gt_stl=stl_dir / f"{sample_id}_gt.stl",
            pred_stl=stl_dir / f"{sample_id}_{method}.stl",
        )
    eval_root = roots[dataset]
    return PairPaths(
        gt_stl=eval_root / "ground_truth" / f"{sample_id}.stl",
        pred_stl=eval_root / method / "stl" / f"{sample_id}.stl",
    )


def _subsample(points: np.ndarray, n: int, seed: int = 42) -> np.ndarray:
    if points.shape[0] <= n:
        return points
    rng = np.random.default_rng(seed)
    idx = rng.choice(points.shape[0], size=n, replace=False)
    return points[idx]


def _set_axes_equal(ax, points_a: np.ndarray, points_b: np.ndarray) -> None:
    pts = np.vstack([points_a, points_b])
    mins = pts.min(axis=0)
    maxs = pts.max(axis=0)
    center = (mins + maxs) * 0.5
    radius = float(np.max(maxs - mins) * 0.6 + 1e-9)
    ax.set_xlim(center[0] - radius, center[0] + radius)
    ax.set_ylim(center[1] - radius, center[1] + radius)
    ax.set_zlim(center[2] - radius, center[2] + radius)


def _plot_overlay(ax, pred: np.ndarray, gt: np.ndarray, title: str, cd_value: float | None) -> None:
    pred_s = _subsample(pred, 2000, seed=11)
    gt_s = _subsample(gt, 2000, seed=17)
    ax.scatter(pred_s[:, 0], pred_s[:, 1], pred_s[:, 2], s=2, alpha=0.45, c="#2E6BE6", label="pred")
    ax.scatter(gt_s[:, 0], gt_s[:, 1], gt_s[:, 2], s=2, alpha=0.45, c="#F39C12", label="gt")
    if cd_value is None:
        ax.set_title(title, fontsize=9)
    else:
        ax.set_title(f"{title}\nCD={cd_value:.5f}", fontsize=9)
    _set_axes_equal(ax, pred_s, gt_s)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_zticks([])


def _evaluate_stages(
    pc_pred: np.ndarray,
    pc_gt: np.ndarray,
    use_icp: bool,
    max_icp_iterations: int,
) -> Dict[str, object]:
    pred_n = normalize_unit_sphere(pc_pred)
    gt_n = normalize_unit_sphere(pc_gt)

    pred_pca, pred_R = pca_canonicalize(pred_n)
    gt_pca, gt_R = pca_canonicalize(gt_n)

    rotations = cube_rotation_group()
    sweep = []
    best_cd = float("inf")
    best_idx = -1
    best_pred_rot = pred_pca
    best_pred_icp = pred_pca

    for i, R in enumerate(rotations):
        pred_rot = pred_pca @ R.T
        cd_pre = chamfer_distance(pred_rot, gt_pca)
        if use_icp:
            aligned, icp_cost = icp_refine(
                pred_rot,
                gt_pca,
                initial=np.eye(4),
                max_iterations=max_icp_iterations,
            )
            cd_post = chamfer_distance(aligned, gt_pca)
        else:
            aligned = pred_rot
            icp_cost = None
            cd_post = cd_pre

        sweep.append(
            {
                "rotation_index": i,
                "cd_pre_icp": float(cd_pre),
                "cd_post_icp": float(cd_post),
                "icp_cost": float(icp_cost) if icp_cost is not None else None,
            }
        )
        if cd_post < best_cd:
            best_cd = float(cd_post)
            best_idx = i
            best_pred_rot = pred_rot
            best_pred_icp = aligned

    checks = {
        "raw_cd": float(chamfer_distance(pc_pred, pc_gt)),
        "normalized_cd": float(chamfer_distance(pred_n, gt_n)),
        "pca_cd": float(chamfer_distance(pred_pca, gt_pca)),
        "best_pre_icp_cd": float(chamfer_distance(best_pred_rot, gt_pca)),
        "best_post_icp_cd": float(best_cd),
        "best_rotation_index": int(best_idx),
        "pred_centroid_after_norm": pred_n.mean(axis=0).tolist(),
        "gt_centroid_after_norm": gt_n.mean(axis=0).tolist(),
        "pred_max_radius_after_norm": float(np.linalg.norm(pred_n, axis=1).max()),
        "gt_max_radius_after_norm": float(np.linalg.norm(gt_n, axis=1).max()),
        "pred_pca_det": float(np.linalg.det(pred_R)),
        "gt_pca_det": float(np.linalg.det(gt_R)),
        "icp_used": bool(use_icp),
    }

    return {
        "stages": {
            "raw_pred": pc_pred,
            "raw_gt": pc_gt,
            "norm_pred": pred_n,
            "norm_gt": gt_n,
            "pca_pred": pred_pca,
            "pca_gt": gt_pca,
            "best_rot_pred": best_pred_rot,
            "best_icp_pred": best_pred_icp,
            "target_pca_gt": gt_pca,
        },
        "sweep": sweep,
        "checks": checks,
    }


def _save_visual(
    dataset: str,
    sample_id: str,
    method: str,
    stage_data: Dict[str, object],
    out_png: Path,
) -> None:
    stages = stage_data["stages"]
    checks = stage_data["checks"]
    sweep = stage_data["sweep"]

    fig = plt.figure(figsize=(17, 10))
    fig.suptitle(f"{dataset} / {sample_id} / {method}", fontsize=14)

    ax1 = fig.add_subplot(2, 3, 1, projection="3d")
    _plot_overlay(ax1, stages["raw_pred"], stages["raw_gt"], "Raw point clouds", checks["raw_cd"])
    ax1.legend(loc="upper right", fontsize=7)

    ax2 = fig.add_subplot(2, 3, 2, projection="3d")
    _plot_overlay(ax2, stages["norm_pred"], stages["norm_gt"], "Unit-sphere normalized", checks["normalized_cd"])

    ax3 = fig.add_subplot(2, 3, 3, projection="3d")
    _plot_overlay(ax3, stages["pca_pred"], stages["pca_gt"], "PCA canonicalized", checks["pca_cd"])

    ax4 = fig.add_subplot(2, 3, 4, projection="3d")
    _plot_overlay(
        ax4,
        stages["best_rot_pred"],
        stages["target_pca_gt"],
        f"Best of 24 rotations (idx={checks['best_rotation_index']})",
        checks["best_pre_icp_cd"],
    )

    ax5 = fig.add_subplot(2, 3, 5, projection="3d")
    _plot_overlay(ax5, stages["best_icp_pred"], stages["target_pca_gt"], "After ICP refine", checks["best_post_icp_cd"])

    ax6 = fig.add_subplot(2, 3, 6)
    x = [row["rotation_index"] for row in sweep]
    pre = [row["cd_pre_icp"] for row in sweep]
    post = [row["cd_post_icp"] for row in sweep]
    ax6.plot(x, pre, label="pre-ICP CD", marker="o", ms=3)
    ax6.plot(x, post, label="post-ICP CD", marker="o", ms=3)
    ax6.set_xlabel("rotation index (0-23)")
    ax6.set_ylabel("Chamfer distance")
    ax6.set_title("24-rotation sweep")
    ax6.grid(alpha=0.3)
    ax6.legend(fontsize=8)

    fig.tight_layout(rect=[0, 0, 1, 0.95])
    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png, dpi=170)
    plt.close(fig)


def _pick_ids(all_ids: List[str], n_per_dataset: int, seed: int) -> List[str]:
    if len(all_ids) <= n_per_dataset:
        return list(all_ids)
    rng = random.Random(seed)
    chosen = rng.sample(all_ids, k=n_per_dataset)
    return sorted(chosen)


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--repo-root",
        default=str(Path(__file__).resolve().parents[2]),
        help="CRAFT repo root.",
    )
    ap.add_argument(
        "--datasets",
        nargs="+",
        default=["nopscadlib", "abc", "slice100k"],
        choices=["nopscadlib", "abc", "slice100k"],
    )
    ap.add_argument("--methods", nargs="+", default=list(METHODS), choices=list(METHODS))
    ap.add_argument("--n-per-dataset", type=int, default=10)
    ap.add_argument("--n-points", type=int, default=10_000)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--max-icp-iterations", type=int, default=30)
    ap.add_argument("--no-icp", action="store_true")
    ap.add_argument(
        "--out-dir",
        default=None,
        help="Output directory. Default: results/cd_pipeline_audit",
    )
    return ap.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve() if args.out_dir else repo_root / "results" / "cd_pipeline_audit"
    methods = tuple(args.methods)

    roots = {
        "nopscadlib": repo_root / "pipeline" / "evaluation" / "nopscadlib_benchmark" / "20260427_184749",
        "abc": repo_root / "results" / "abc" / "eval",
        "slice100k": repo_root / "results" / "slice100k" / "eval",
    }

    run_summary: Dict[str, object] = {
        "config": {
            "datasets": args.datasets,
            "methods": list(methods),
            "n_per_dataset": args.n_per_dataset,
            "n_points": args.n_points,
            "seed": args.seed,
            "use_icp": not args.no_icp,
            "max_icp_iterations": args.max_icp_iterations,
        },
        "datasets": {},
    }

    for dataset in args.datasets:
        if dataset == "nopscadlib":
            all_ids = _list_common_ids_nop(roots[dataset], methods)
        else:
            all_ids = _list_common_ids_ext(roots[dataset], methods)
        chosen_ids = _pick_ids(all_ids, args.n_per_dataset, args.seed)
        print(f"[{dataset}] available={len(all_ids)} chosen={len(chosen_ids)}")
        run_summary["datasets"][dataset] = {
            "available_ids": all_ids,
            "chosen_ids": chosen_ids,
            "pairs": [],
        }

        for sample_id in chosen_ids:
            for method in methods:
                pair_paths = _build_paths(dataset, sample_id, method, roots)
                if not pair_paths.gt_stl.exists() or not pair_paths.pred_stl.exists():
                    print(f"  [skip] {dataset}/{sample_id}/{method} missing STL")
                    continue

                print(f"  [run] {dataset}/{sample_id}/{method}")
                pc_pred = load_and_sample(pair_paths.pred_stl, n_points=args.n_points, seed=args.seed)
                pc_gt = load_and_sample(pair_paths.gt_stl, n_points=args.n_points, seed=args.seed)
                if pc_pred is None or pc_gt is None:
                    print(f"  [skip] {dataset}/{sample_id}/{method} load/sample failed")
                    continue

                stage_data = _evaluate_stages(
                    pc_pred=pc_pred,
                    pc_gt=pc_gt,
                    use_icp=not args.no_icp,
                    max_icp_iterations=args.max_icp_iterations,
                )

                pair_out = out_dir / dataset / sample_id / method
                pair_out.mkdir(parents=True, exist_ok=True)
                _save_visual(
                    dataset=dataset,
                    sample_id=sample_id,
                    method=method,
                    stage_data=stage_data,
                    out_png=pair_out / "stages.png",
                )
                with open(pair_out / "stage_metrics.json", "w") as f:
                    json.dump(
                        {
                            "dataset": dataset,
                            "sample_id": sample_id,
                            "method": method,
                            "gt_stl": str(pair_paths.gt_stl),
                            "pred_stl": str(pair_paths.pred_stl),
                            "checks": stage_data["checks"],
                            "rotation_sweep": stage_data["sweep"],
                        },
                        f,
                        indent=2,
                    )

                run_summary["datasets"][dataset]["pairs"].append(
                    {
                        "sample_id": sample_id,
                        "method": method,
                        "out_dir": str(pair_out),
                        "checks": stage_data["checks"],
                    }
                )

    out_dir.mkdir(parents=True, exist_ok=True)
    with open(out_dir / "audit_summary.json", "w") as f:
        json.dump(run_summary, f, indent=2)
    print(f"\n[audit] wrote {out_dir / 'audit_summary.json'}")
    print(f"[audit] visuals root: {out_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
