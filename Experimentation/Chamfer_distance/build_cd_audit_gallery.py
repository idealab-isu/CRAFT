#!/usr/bin/env python3
"""
Build a static web gallery from cd_pipeline_audit outputs.

Input expected:
  results/cd_pipeline_audit_10x3/
    audit_summary.json
    <dataset>/<sample_id>/<method>/{stages.png,stage_metrics.json}

Output:
  results/cd_web_view/audit_10x3/
    index.html
    <dataset>/<sample_id>/index.html
    assets/<dataset>/<sample_id>/<method>/{stages.png,stage_metrics.json}
"""

from __future__ import annotations

import argparse
import html as html_lib
import json
import shutil
from pathlib import Path
from typing import Dict, List

import matplotlib
import numpy as np

matplotlib.use("Agg")
import matplotlib.pyplot as plt

from align_and_score import load_mesh


def _read_json(path: Path) -> dict:
    return json.loads(path.read_text())


def _copy_pair_assets(src_pair_dir: Path, dst_pair_dir: Path) -> None:
    dst_pair_dir.mkdir(parents=True, exist_ok=True)
    for name in ("stages.png", "stage_metrics.json"):
        src = src_pair_dir / name
        if src.exists():
            shutil.copy2(src, dst_pair_dir / name)


def _load_prompt_maps(repo_root: Path) -> Dict[str, Dict[str, str]]:
    """Load prompt/caption text by dataset and sample id."""
    out: Dict[str, Dict[str, str]] = {"nopscadlib": {}, "abc": {}, "slice100k": {}}

    nop_path = repo_root / "pipeline" / "evaluation" / "nopscadlib_benchmark" / "20260427_184749" / "benchmark_summary.json"
    if nop_path.exists():
        data = _read_json(nop_path)
        out["nopscadlib"] = {
            row.get("id", ""): row.get("text", "")
            for row in data.get("detailed_results", [])
            if row.get("id")
        }

    abc_path = repo_root / "results" / "abc" / "eval" / "prompts.json"
    if abc_path.exists():
        rows = _read_json(abc_path)
        out["abc"] = {
            row.get("id", ""): row.get("text", "")
            for row in rows
            if row.get("id")
        }

    slice_path = repo_root / "results" / "slice100k" / "eval" / "prompts.json"
    if slice_path.exists():
        rows = _read_json(slice_path)
        out["slice100k"] = {
            row.get("id", ""): row.get("text", "")
            for row in rows
            if row.get("id")
        }
    return out


def _resolve_stl_paths(repo_root: Path, dataset: str, sample_id: str, method: str) -> tuple[Path, Path]:
    """Return (gt_stl, pred_stl) for one sample + method."""
    if dataset == "nopscadlib":
        stl_dir = (
            repo_root
            / "pipeline"
            / "evaluation"
            / "nopscadlib_benchmark"
            / "20260427_184749"
            / "stl"
        )
        return stl_dir / f"{sample_id}_gt.stl", stl_dir / f"{sample_id}_{method}.stl"
    eval_root = repo_root / "results" / dataset / "eval"
    return eval_root / "ground_truth" / f"{sample_id}.stl", eval_root / method / "stl" / f"{sample_id}.stl"


def _set_axes_equal(ax, points: np.ndarray) -> None:
    mins = points.min(axis=0)
    maxs = points.max(axis=0)
    center = (mins + maxs) * 0.5
    radius = float(np.max(maxs - mins) * 0.6 + 1e-9)
    ax.set_xlim(center[0] - radius, center[0] + radius)
    ax.set_ylim(center[1] - radius, center[1] + radius)
    ax.set_zlim(center[2] - radius, center[2] + radius)


def _render_stl_preview(stl_path: Path, out_png: Path, title: str, max_faces: int = 25000) -> bool:
    """Create a deterministic STL surface render (filled mesh)."""
    if not stl_path.exists():
        return False
    mesh = load_mesh(stl_path)
    if mesh is None:
        return False

    verts = np.asarray(mesh.vertices, dtype=np.float64)
    faces = np.asarray(mesh.faces, dtype=np.int32)
    if verts.size == 0 or faces.size == 0:
        return False

    # Keep rendering bounded on very dense meshes.
    if faces.shape[0] > max_faces:
        rng = np.random.default_rng(42)
        keep = rng.choice(faces.shape[0], size=max_faces, replace=False)
        faces = faces[keep]

    fig = plt.figure(figsize=(4.0, 3.0))
    ax = fig.add_subplot(1, 1, 1, projection="3d")
    ax.plot_trisurf(
        verts[:, 0],
        verts[:, 1],
        verts[:, 2],
        triangles=faces,
        color="#9CA3AF",
        edgecolor="none",
        linewidth=0.0,
        antialiased=True,
        shade=True,
        alpha=1.0,
    )
    _set_axes_equal(ax, verts)
    ax.view_init(elev=22, azim=38)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_zticks([])
    ax.set_box_aspect([1, 1, 1])
    ax.set_title(title, fontsize=10)
    fig.tight_layout()
    out_png.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(out_png, dpi=170)
    plt.close(fig)
    return True


def _build_sample_page(
    out_path: Path,
    dataset: str,
    sample_id: str,
    methods: List[str],
    method_checks: Dict[str, dict],
    prompt_text: str,
    render_map: Dict[str, str],
) -> None:
    rows = []
    for m in methods:
        checks = method_checks.get(m, {})
        cd_raw = checks.get("raw_cd")
        cd_final = checks.get("best_post_icp_cd")
        rows.append(
            f"""
            <div class="method-card">
              <div class="method-title">{m.upper()}</div>
              <div class="metrics">raw CD: {cd_raw:.5f} | final CD: {cd_final:.5f}</div>
              <img src="../../assets/{dataset}/{sample_id}/{m}/stages.png" alt="{m} stages" />
            </div>
            """
        )

    render_cells = []
    for label in ("ground_truth", "craft", "gpt4o", "gpt52"):
        rel = render_map.get(label)
        pretty = "Ground Truth" if label == "ground_truth" else label.upper()
        if rel:
            render_cells.append(
                f"""
                <div class="render-cell">
                  <div class="render-label">{pretty}</div>
                  <img src="{rel}" alt="{pretty} render" />
                </div>
                """
            )
        else:
            render_cells.append(
                f"""
                <div class="render-cell">
                  <div class="render-label">{pretty}</div>
                  <div class="render-missing">render unavailable</div>
                </div>
                """
            )

    page_html = f"""<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <title>CD Audit - {dataset}/{sample_id}</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif; margin: 16px; background: #f7f8fb; color: #111827; }}
    a {{ color: #2563eb; text-decoration: none; }}
    .top {{ margin-bottom: 12px; }}
    .panel {{ background: white; border: 1px solid #e5e7eb; border-radius: 10px; padding: 12px; margin-bottom: 12px; }}
    .method-title {{ font-weight: 700; margin-bottom: 4px; }}
    .metrics {{ color: #4b5563; font-size: 12px; margin-bottom: 8px; }}
    img {{ width: 100%; border: 1px solid #e5e7eb; border-radius: 8px; }}
    .render-grid {{ display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; }}
    .render-cell {{ background:#fcfdff; border:1px solid #e5e7eb; border-radius:8px; padding:8px; }}
    .render-label {{ font-weight:600; font-size:12px; margin-bottom:6px; text-align:center; }}
    .render-missing {{ height:160px; display:flex; align-items:center; justify-content:center; color:#6b7280; font-size:12px; border:1px dashed #d1d5db; border-radius:6px; background:#f9fafb; }}
  </style>
</head>
<body>
  <div class="top"><a href="../../index.html">← Back to all samples</a></div>
  <div class="panel">
    <h2 style="margin:0 0 8px 0;">{dataset} / {sample_id}</h2>
    <div style="font-size:14px;line-height:1.5;margin:8px 0 10px 0;"><b>Prompt:</b> {html_lib.escape(prompt_text) if prompt_text else '(prompt not found)'}</div>
    <h3 style="margin:0 0 8px 0;">Final Render Comparison</h3>
    <div class="render-grid">
      {''.join(render_cells)}
    </div>
  </div>
  <div class="panel">
    <div style="font-size:13px;color:#4b5563;">Each row already contains 5 horizontal stage blocks: raw, normalized, PCA, best-of-24 rotation, post-ICP.</div>
  </div>
  {''.join(rows)}
</body>
</html>
"""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(page_html)


def _build_index_page(out_path: Path, entries: Dict[str, List[str]], prompt_maps: Dict[str, Dict[str, str]]) -> None:
    sections = []
    for dataset, sample_ids in entries.items():
        cards = []
        for sid in sample_ids:
            prompt = prompt_maps.get(dataset, {}).get(sid, "")
            snippet = (prompt[:120] + "...") if len(prompt) > 120 else prompt
            cards.append(
                f"""
                <a class="card" href="./{dataset}/{sid}/index.html">
                  <div class="sid">{sid}</div>
                  <div class="sub2">{html_lib.escape(snippet) if snippet else "Open sample page"}</div>
                </a>
                """
            )
        sections.append(
            f"""
            <div class="dataset-block">
              <h2>{dataset} ({len(sample_ids)} samples)</h2>
              <div class="grid">{''.join(cards)}</div>
            </div>
            """
        )

    html = f"""<!doctype html>
<html>
<head>
  <meta charset="utf-8" />
  <title>CD Audit Gallery (30 Samples)</title>
  <style>
    body {{ font-family: -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif; margin: 18px; background: #f7f8fb; color: #111827; }}
    h1 {{ margin: 0 0 6px 0; }}
    .sub {{ color: #4b5563; margin-bottom: 14px; }}
    .dataset-block {{ background: white; border: 1px solid #e5e7eb; border-radius: 10px; padding: 12px; margin-bottom: 12px; }}
    .grid {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 10px; }}
    .card {{ display: block; padding: 10px; border: 1px solid #e5e7eb; border-radius: 8px; background: #fcfdff; text-decoration: none; color: inherit; }}
    .card:hover {{ border-color: #93c5fd; background: #f8fbff; }}
    .sid {{ font-size: 13px; font-weight: 600; word-break: break-all; }}
    .sub2 {{ font-size: 12px; color: #6b7280; }}
  </style>
</head>
<body>
  <h1>CD Pipeline Audit Gallery</h1>
  <div class="sub">30 samples total: 10 each from nopscadlib, abc, slice100k.</div>
  {''.join(sections)}
</body>
</html>
"""
    out_path.write_text(html)


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--repo-root", default=str(Path(__file__).resolve().parents[2]))
    ap.add_argument(
        "--audit-root",
        default=None,
        help="Defaults to <repo-root>/results/cd_pipeline_audit_10x3",
    )
    ap.add_argument(
        "--out-root",
        default=None,
        help="Defaults to <repo-root>/results/cd_web_view/audit_10x3",
    )
    return ap.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = Path(args.repo_root).resolve()
    audit_root = Path(args.audit_root).resolve() if args.audit_root else repo_root / "results" / "cd_pipeline_audit_10x3"
    out_root = Path(args.out_root).resolve() if args.out_root else repo_root / "results" / "cd_web_view" / "audit_10x3"

    summary_path = audit_root / "audit_summary.json"
    if not summary_path.exists():
        raise FileNotFoundError(f"Missing summary: {summary_path}")

    summary = _read_json(summary_path)
    datasets: Dict[str, dict] = summary.get("datasets", {})
    methods: List[str] = summary.get("config", {}).get("methods", ["craft", "gpt4o", "gpt52"])
    prompt_maps = _load_prompt_maps(repo_root)

    if out_root.exists():
        shutil.rmtree(out_root)
    (out_root / "assets").mkdir(parents=True, exist_ok=True)

    index_entries: Dict[str, List[str]] = {}

    for dataset, d in datasets.items():
        chosen_ids: List[str] = d.get("chosen_ids", [])
        index_entries[dataset] = chosen_ids

        checks_by_id_method: Dict[str, Dict[str, dict]] = {}
        for p in d.get("pairs", []):
            sid = p["sample_id"]
            m = p["method"]
            checks_by_id_method.setdefault(sid, {})[m] = p.get("checks", {})

            src_pair = audit_root / dataset / sid / m
            dst_pair = out_root / "assets" / dataset / sid / m
            _copy_pair_assets(src_pair, dst_pair)

        for sid in chosen_ids:
            renders_root = out_root / "assets" / dataset / sid / "renders"
            render_map: Dict[str, str] = {}

            gt_any, _ = _resolve_stl_paths(repo_root, dataset, sid, methods[0])
            gt_png = renders_root / "ground_truth.png"
            if _render_stl_preview(gt_any, gt_png, "Ground Truth"):
                render_map["ground_truth"] = f"../../assets/{dataset}/{sid}/renders/ground_truth.png"

            for m in methods:
                _, pred_stl = _resolve_stl_paths(repo_root, dataset, sid, m)
                pred_png = renders_root / f"{m}.png"
                if _render_stl_preview(pred_stl, pred_png, m.upper()):
                    render_map[m] = f"../../assets/{dataset}/{sid}/renders/{m}.png"

            _build_sample_page(
                out_path=out_root / dataset / sid / "index.html",
                dataset=dataset,
                sample_id=sid,
                methods=methods,
                method_checks=checks_by_id_method.get(sid, {}),
                prompt_text=prompt_maps.get(dataset, {}).get(sid, ""),
                render_map=render_map,
            )

    _build_index_page(out_root / "index.html", index_entries, prompt_maps)
    print(f"[gallery] wrote {out_root / 'index.html'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
