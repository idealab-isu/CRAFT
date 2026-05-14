#!/usr/bin/env python3
"""
Build a single-sample HTML viewer for CD alignment stages.

This is a presentation helper: for one sample ID, it generates
method-wise horizontal stage rows and a compact size-comparison table.
"""

from __future__ import annotations

import argparse
import json
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
    load_mesh,
    normalize_unit_sphere,
    pca_canonicalize,
)

METHODS = ("craft", "gpt4o", "gpt52")


def _resolve_paths(repo_root: Path, dataset: str, sample_id: str, method: str) -> Tuple[Path, Path]:
    if dataset == "nopscadlib":
        stl_dir = repo_root / "pipeline" / "evaluation" / "nopscadlib_benchmark" / "20260427_184749" / "stl"
        return stl_dir / f"{sample_id}_gt.stl", stl_dir / f"{sample_id}_{method}.stl"
    eval_root = repo_root / "results" / dataset / "eval"
    return eval_root / "ground_truth" / f"{sample_id}.stl", eval_root / method / "stl" / f"{sample_id}.stl"


def _subsample(points: np.ndarray, n: int, seed: int = 42) -> np.ndarray:
    if points.shape[0] <= n:
        return points
    rng = np.random.default_rng(seed)
    idx = rng.choice(points.shape[0], size=n, replace=False)
    return points[idx]


def _set_axes_equal(ax, points: np.ndarray) -> None:
    mins = points.min(axis=0)
    maxs = points.max(axis=0)
    center = (mins + maxs) * 0.5
    radius = float(np.max(maxs - mins) * 0.6 + 1e-9)
    ax.set_xlim(center[0] - radius, center[0] + radius)
    ax.set_ylim(center[1] - radius, center[1] + radius)
    ax.set_zlim(center[2] - radius, center[2] + radius)


def _plot_overlay(ax, pred: np.ndarray, gt: np.ndarray, title: str, cd_value: float, with_ticks: bool) -> None:
    pred_s = _subsample(pred, 2200, seed=11)
    gt_s = _subsample(gt, 2200, seed=17)
    both = np.vstack([pred_s, gt_s])
    ax.scatter(pred_s[:, 0], pred_s[:, 1], pred_s[:, 2], s=2, alpha=0.45, c="#2E6BE6")
    ax.scatter(gt_s[:, 0], gt_s[:, 1], gt_s[:, 2], s=2, alpha=0.45, c="#F39C12")
    _set_axes_equal(ax, both)
    ax.set_title(f"{title}\nCD={cd_value:.5f}", fontsize=8)
    if not with_ticks:
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_zticks([])
    else:
        ax.tick_params(labelsize=7)
        ax.set_xlabel("X (mm)", fontsize=7)
        ax.set_ylabel("Y (mm)", fontsize=7)
        ax.set_zlabel("Z (mm)", fontsize=7)


def _compute_stage_data(pc_pred: np.ndarray, pc_gt: np.ndarray, use_icp: bool, max_icp_iter: int) -> Dict[str, object]:
    pred_n = normalize_unit_sphere(pc_pred)
    gt_n = normalize_unit_sphere(pc_gt)
    pred_pca, _ = pca_canonicalize(pred_n)
    gt_pca, _ = pca_canonicalize(gt_n)

    best_pre = float("inf")
    best_post = float("inf")
    best_idx = -1
    best_rot = pred_pca
    best_icp = pred_pca

    for i, R in enumerate(cube_rotation_group()):
        pred_rot = pred_pca @ R.T
        cd_pre = chamfer_distance(pred_rot, gt_pca)
        if cd_pre < best_pre:
            best_pre = float(cd_pre)
            best_rot = pred_rot
        if use_icp:
            aligned, _ = icp_refine(pred_rot, gt_pca, initial=np.eye(4), max_iterations=max_icp_iter)
            cd_post = chamfer_distance(aligned, gt_pca)
        else:
            aligned = pred_rot
            cd_post = cd_pre
        if cd_post < best_post:
            best_post = float(cd_post)
            best_idx = i
            best_icp = aligned

    return {
        "raw_pred": pc_pred,
        "raw_gt": pc_gt,
        "norm_pred": pred_n,
        "norm_gt": gt_n,
        "pca_pred": pred_pca,
        "pca_gt": gt_pca,
        "rot_pred": best_rot,
        "icp_pred": best_icp,
        "checks": {
            "raw_cd": float(chamfer_distance(pc_pred, pc_gt)),
            "norm_cd": float(chamfer_distance(pred_n, gt_n)),
            "pca_cd": float(chamfer_distance(pred_pca, gt_pca)),
            "rot24_best_cd": float(best_pre),
            "final_cd": float(best_post),
            "best_rotation_index": int(best_idx),
        },
    }


def _bbox_dims_mm(stl_path: Path) -> Dict[str, float]:
    mesh = load_mesh(stl_path)
    if mesh is None:
        return {"x": float("nan"), "y": float("nan"), "z": float("nan"), "diag": float("nan")}
    ext = mesh.bounding_box.extents
    diag = float(np.linalg.norm(ext))
    return {"x": float(ext[0]), "y": float(ext[1]), "z": float(ext[2]), "diag": diag}


def _save_method_row(method: str, stages: Dict[str, object], out_png: Path) -> None:
    checks = stages["checks"]
    fig = plt.figure(figsize=(20, 3.8))
    ax1 = fig.add_subplot(1, 5, 1, projection="3d")
    _plot_overlay(ax1, stages["raw_pred"], stages["raw_gt"], "Raw (true scale)", checks["raw_cd"], with_ticks=True)
    ax2 = fig.add_subplot(1, 5, 2, projection="3d")
    _plot_overlay(ax2, stages["norm_pred"], stages["norm_gt"], "Unit-sphere", checks["norm_cd"], with_ticks=False)
    ax3 = fig.add_subplot(1, 5, 3, projection="3d")
    _plot_overlay(ax3, stages["pca_pred"], stages["pca_gt"], "PCA", checks["pca_cd"], with_ticks=False)
    ax4 = fig.add_subplot(1, 5, 4, projection="3d")
    _plot_overlay(ax4, stages["rot_pred"], stages["pca_gt"], "Best of 24 rotations", checks["rot24_best_cd"], with_ticks=False)
    ax5 = fig.add_subplot(1, 5, 5, projection="3d")
    _plot_overlay(ax5, stages["icp_pred"], stages["pca_gt"], "After ICP", checks["final_cd"], with_ticks=False)
    fig.suptitle(f"{method.upper()} stage row", fontsize=11)
    fig.tight_layout(rect=[0, 0, 1, 0.9])
    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png, dpi=170)
    plt.close(fig)


def _write_html(out_dir: Path, sample_id: str, dataset: str, methods: List[str], size_rows: List[dict]) -> None:
    rows_html = []
    for m in methods:
        rows_html.append(
            f"""
            <div class="method-row">
              <div class="method-title">{m.upper()}</div>
              <img src="./{m}_stages_row.png" alt="{m} stages" />
            </div>
            """
        )

    size_table_rows = []
    for r in size_rows:
        size_table_rows.append(
            "<tr>"
            f"<td>{r['method']}</td>"
            f"<td>{r['gt_diag_mm']:.3f}</td>"
            f"<td>{r['pred_diag_mm']:.3f}</td>"
            f"<td>{r['ratio_pred_over_gt']:.3f}x</td>"
            f"<td>{r['gt_dims']}</td>"
            f"<td>{r['pred_dims']}</td>"
            "</tr>"
        )

    html = f"""<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <title>CD Stage Viewer - {sample_id}</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif; margin: 18px; background: #f7f8fb; color: #1f2937; }}
    h1 {{ margin: 0 0 4px 0; font-size: 22px; }}
    .sub {{ color: #4b5563; margin-bottom: 14px; }}
    .panel {{ background: white; border: 1px solid #e5e7eb; border-radius: 10px; padding: 12px; margin-bottom: 12px; }}
    .method-row img {{ width: 100%; border-radius: 8px; border: 1px solid #e5e7eb; }}
    .method-title {{ font-weight: 700; margin-bottom: 8px; }}
    table {{ border-collapse: collapse; width: 100%; font-size: 13px; }}
    th, td {{ border: 1px solid #e5e7eb; padding: 8px; text-align: left; }}
    th {{ background: #f3f4f6; }}
    .note {{ font-size: 12px; color: #6b7280; margin-top: 8px; }}
  </style>
</head>
<body>
  <h1>CD Stage Viewer</h1>
  <div class="sub">sample: <b>{sample_id}</b> | dataset: <b>{dataset}</b></div>

  <div class="panel">
    <h3>True Size Check (before normalization)</h3>
    <table>
      <thead>
        <tr>
          <th>Method</th><th>GT diag (mm)</th><th>Pred diag (mm)</th><th>Scale ratio</th><th>GT bbox (X,Y,Z mm)</th><th>Pred bbox (X,Y,Z mm)</th>
        </tr>
      </thead>
      <tbody>
        {"".join(size_table_rows)}
      </tbody>
    </table>
    <div class="note">If one model outputs 50mm while GT is 5mm, this ratio will be near 10x. The first block in each row shows raw true-scale point clouds with mm axes.</div>
  </div>

  <div class="panel">
    <h3>Horizontal Stage Blocks</h3>
    {"".join(rows_html)}
  </div>
</body>
</html>
"""
    (out_dir / "index.html").write_text(html)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo-root", default=str(Path(__file__).resolve().parents[2]))
    ap.add_argument("--dataset", required=True, choices=["nopscadlib", "abc", "slice100k"])
    ap.add_argument("--sample-id", required=True)
    ap.add_argument("--methods", nargs="+", default=list(METHODS), choices=list(METHODS))
    ap.add_argument("--n-points", type=int, default=10_000)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--no-icp", action="store_true")
    ap.add_argument("--max-icp-iter", type=int, default=30)
    ap.add_argument("--out-dir", default=None)
    args = ap.parse_args()

    repo_root = Path(args.repo_root).resolve()
    out_dir = Path(args.out_dir).resolve() if args.out_dir else (
        repo_root / "results" / "cd_web_view" / args.dataset / args.sample_id
    )
    out_dir.mkdir(parents=True, exist_ok=True)

    methods = list(args.methods)
    summary = {"dataset": args.dataset, "sample_id": args.sample_id, "methods": {}}
    size_rows: List[dict] = []

    for method in methods:
        gt_stl, pred_stl = _resolve_paths(repo_root, args.dataset, args.sample_id, method)
        if not gt_stl.exists():
            raise FileNotFoundError(f"GT STL not found: {gt_stl}")
        if not pred_stl.exists():
            raise FileNotFoundError(f"Pred STL not found: {pred_stl}")

        pc_pred = load_and_sample(pred_stl, n_points=args.n_points, seed=args.seed)
        pc_gt = load_and_sample(gt_stl, n_points=args.n_points, seed=args.seed)
        if pc_pred is None or pc_gt is None:
            raise RuntimeError(f"Failed to load/sample STL pair for {method}")

        stages = _compute_stage_data(
            pc_pred=pc_pred,
            pc_gt=pc_gt,
            use_icp=not args.no_icp,
            max_icp_iter=args.max_icp_iter,
        )
        _save_method_row(method, stages, out_dir / f"{method}_stages_row.png")

        gt_dims = _bbox_dims_mm(gt_stl)
        pred_dims = _bbox_dims_mm(pred_stl)
        ratio = pred_dims["diag"] / gt_dims["diag"] if gt_dims["diag"] > 0 else float("nan")
        size_rows.append(
            {
                "method": method,
                "gt_diag_mm": gt_dims["diag"],
                "pred_diag_mm": pred_dims["diag"],
                "ratio_pred_over_gt": ratio,
                "gt_dims": f"{gt_dims['x']:.3f}, {gt_dims['y']:.3f}, {gt_dims['z']:.3f}",
                "pred_dims": f"{pred_dims['x']:.3f}, {pred_dims['y']:.3f}, {pred_dims['z']:.3f}",
            }
        )

        summary["methods"][method] = {
            "gt_stl": str(gt_stl),
            "pred_stl": str(pred_stl),
            "checks": stages["checks"],
            "gt_bbox_mm": gt_dims,
            "pred_bbox_mm": pred_dims,
            "pred_over_gt_diag_ratio": ratio,
            "stage_row_png": str((out_dir / f"{method}_stages_row.png").name),
        }

    _write_html(out_dir, args.sample_id, args.dataset, methods, size_rows)
    (out_dir / "summary.json").write_text(json.dumps(summary, indent=2))
    print(f"[web] wrote {out_dir / 'index.html'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
