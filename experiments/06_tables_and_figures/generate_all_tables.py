#!/usr/bin/env python3
"""
Emit every LaTeX table reported in the paper, directly from the metric JSONs
in metrics/. Eliminates hand-transcription as a source of error.

Each table is a self-contained function that reads only what it needs. New
tables are added by writing a new function and registering it in TABLES.

Output: paper/ieee_lad_2026/tables/table_<N>.tex (configurable).

Usage:
  python experiments/06_tables_and_figures/generate_all_tables.py --all
  python experiments/06_tables_and_figures/generate_all_tables.py --table 1
  python experiments/06_tables_and_figures/generate_all_tables.py --list
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Callable, Dict, List, Optional, Tuple

SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
METRICS = REPO_ROOT / "metrics"
TABLES_OUT = REPO_ROOT / "paper" / "ieee_lad_2026" / "tables"
TABLES_OUT.mkdir(parents=True, exist_ok=True)


# =============================================================================
# Helpers
# =============================================================================

def load_json(path: Path, *, required: bool = True) -> Optional[dict]:
    if not path.exists():
        if required:
            raise FileNotFoundError(f"missing required metric file: {path}")
        return None
    with path.open() as f:
        return json.load(f)


def fmt(x: Optional[float], digits: int = 4) -> str:
    if x is None:
        return "—"
    return f"{x:.{digits}f}"


def bold_best(values: List[Tuple[str, Optional[float]]], lower_is_better: bool = True) -> Dict[str, bool]:
    """Mark which method's value is the best in a row."""
    numeric = [(m, v) for m, v in values if v is not None]
    if not numeric:
        return {m: False for m, _ in values}
    best = min(numeric, key=lambda t: t[1])[0] if lower_is_better else max(numeric, key=lambda t: t[1])[0]
    return {m: m == best for m, _ in values}


def latex_table(
    *, caption: str, label: str,
    columns: List[str], rows: List[List[str]],
    column_format: Optional[str] = None,
) -> str:
    """Render a tabular as a complete LaTeX table block."""
    if column_format is None:
        column_format = "l" + "r" * (len(columns) - 1)
    head = "\\begin{table}[t]\n\\centering\n\\caption{" + caption + "}\n\\label{" + label + "}\n"
    head += "\\begin{tabular}{" + column_format + "}\n\\toprule\n"
    head += " & ".join(columns) + " \\\\\n\\midrule\n"
    body = "\n".join(" & ".join(r) + " \\\\" for r in rows) + "\n"
    foot = "\\bottomrule\n\\end{tabular}\n\\end{table}\n"
    return head + body + foot


# =============================================================================
# Tables
# =============================================================================

def table_1_perceptual_nopscadlib() -> str:
    """Table I — Perceptual alignment on NopSCADlib (CLIP, FID)."""
    clip = load_json(METRICS / "nopscadlib" / "clip" / "clip_detailed_results.json", required=False)
    fid  = load_json(METRICS / "nopscadlib" / "fid"  / "fid_results.json",          required=False)

    # CLIP per-method means. Schema observed in repo: {method: [ {clip_score, ...}, ... ]}.
    # 5 of CRAFT's 468 entries have NaN clip_score from blank renders — drop them.
    import math
    def _ok(v):
        return v is not None and not (isinstance(v, float) and math.isnan(v))

    clip_means: Dict[str, float] = {}
    if isinstance(clip, dict):
        for method, items in clip.items():
            if method == "gt":
                continue
            scores = [r["clip_score"] for r in items
                      if isinstance(r, dict) and _ok(r.get("clip_score"))]
            if scores:
                clip_means[method] = sum(scores) / len(scores)
    elif isinstance(clip, list):
        from collections import defaultdict
        bucket: Dict[str, List[float]] = defaultdict(list)
        for r in clip:
            if isinstance(r, dict) and _ok(r.get("clip_score")):
                bucket[r.get("method", "unknown")].append(r["clip_score"])
        clip_means = {m: sum(v) / len(v) for m, v in bucket.items()}

    # FID. Schema observed in repo: {method: {fid_score, fid_by_tier, ...}}
    fid_means: Dict[str, float] = {}
    if isinstance(fid, dict):
        # Prefer the "methods" wrapper if present (newer schema), else read top-level keys.
        source = fid.get("methods") if "methods" in fid else fid
        for method, rec in source.items():
            if isinstance(rec, dict) and "fid_score" in rec:
                fid_means[method] = rec["fid_score"]

    methods = sorted(set(list(clip_means) + list(fid_means)))
    rows = []
    clip_pairs = [(m, clip_means.get(m)) for m in methods]
    fid_pairs  = [(m, fid_means.get(m))  for m in methods]
    clip_bold = bold_best(clip_pairs, lower_is_better=False)
    fid_bold  = bold_best(fid_pairs,  lower_is_better=True)
    for m in methods:
        c = clip_means.get(m); f = fid_means.get(m)
        c_str = ("\\textbf{" + fmt(c) + "}") if c is not None and clip_bold[m] else fmt(c)
        f_str = ("\\textbf{" + fmt(f, 2) + "}") if f is not None and fid_bold[m] else fmt(f, 2)
        rows.append([m, c_str, f_str])
    return latex_table(
        caption="Perceptual alignment on NopSCADlib.",
        label="tab:perceptual_nopscadlib",
        columns=["Method", "CLIP $\\uparrow$", "FID $\\downarrow$"],
        rows=rows,
    )


def _geo_mean(row: dict, which: str):
    """geometric.py writes FLAT summary keys (cd_mean / f1_1pct_mean / voxel_iou_mean).
    Map the logical metric name to the actual key."""
    return row.get({"cd": "cd_mean", "f1": "f1_1pct_mean", "iou": "voxel_iou_mean"}[which])


def _geometric_table(dataset: str, *, caption: str, label: str, only: Optional[List[str]] = None) -> str:
    """Reusable: Tables II/IV/V — geometric accuracy from chamfer summaries."""
    summary = load_json(METRICS / dataset / "chamfer" / "summaries.json", required=False)
    if not summary:
        return f"% no chamfer summary for {dataset} yet\n"
    rows = []
    # `only` keeps this table to its intended methods even when the shared
    # summaries.json also holds ablation / matched-effort rows (Tables III/VII).
    methods = [m for m in only if m in summary] if only else sorted(summary.keys())

    def per_method(which: str) -> List[Tuple[str, Optional[float]]]:
        return [(m, _geo_mean(summary[m], which)) for m in methods]

    cd_bold  = bold_best(per_method("cd"),  lower_is_better=True)
    f1_bold  = bold_best(per_method("f1"),  lower_is_better=False)
    iou_bold = bold_best(per_method("iou"), lower_is_better=False)

    for m in methods:
        cd  = _geo_mean(summary[m], "cd")
        f1  = _geo_mean(summary[m], "f1")
        iou = _geo_mean(summary[m], "iou")
        cd_s  = ("\\textbf{" + fmt(cd) + "}")  if cd is not None and cd_bold[m]  else fmt(cd)
        f1_s  = ("\\textbf{" + fmt(f1) + "}")  if f1 is not None and f1_bold[m]  else fmt(f1)
        iou_s = ("\\textbf{" + fmt(iou) + "}") if iou is not None and iou_bold[m] else fmt(iou)
        rows.append([m, cd_s, f1_s, iou_s])

    return latex_table(
        caption=caption, label=label,
        columns=["Method", "CD $\\downarrow$", "F1 $\\uparrow$", "Voxel IoU $\\uparrow$"],
        rows=rows,
    )


def table_2_geometric_nopscadlib() -> str:
    return _geometric_table(
        "nopscadlib",
        caption="Geometric accuracy on NopSCADlib (CD, F1@1\\%, Voxel IoU).",
        label="tab:geometric_nopscadlib",
        only=["craft", "gpt4o", "gpt52"],
    )


def table_4_geometric_abc() -> str:
    return _geometric_table(
        "abc",
        caption="Geometric accuracy on ABC.",
        label="tab:geometric_abc",
    )


def table_5_geometric_slice100k() -> str:
    return _geometric_table(
        "slice100k",
        caption="Geometric accuracy on Slice-100K.",
        label="tab:geometric_slice100k",
    )


def table_3_ablation() -> str:
    """Table III — Ablation: full CRAFT vs. each component-disabled variant."""
    # Look for chamfer summaries under results/<dataset>/ablations/<variant>/...
    # but the metric scripts write into metrics/<dataset>/<metric>/. We read
    # the latter; user is expected to have run the metric scripts pointing at
    # the ablation result dirs with method names like "no_json_ir".
    summary = load_json(METRICS / "nopscadlib" / "chamfer" / "summaries.json", required=False)
    if not summary:
        return "% Run experiments/03_metrics/_shared/geometric.py against ablation outputs first.\n"
    expected = ["craft", "no_json_ir", "no_retrieval", "no_multiview", "no_verification", "no_recovery"]
    methods = [m for m in expected if m in summary]
    if not methods:
        return "% No ablation variants found in metrics/nopscadlib/chamfer/summaries.json yet.\n"
    rows = []
    for m in methods:
        cd  = _geo_mean(summary[m], "cd")
        f1  = _geo_mean(summary[m], "f1")
        iou = _geo_mean(summary[m], "iou")
        rows.append([m.replace("_", "\\_"), fmt(cd), fmt(f1), fmt(iou)])
    return latex_table(
        caption="Ablation study on NopSCADlib (rows: full pipeline and component-disabled variants).",
        label="tab:ablation",
        columns=["Variant", "CD $\\downarrow$", "F1 $\\uparrow$", "Voxel IoU $\\uparrow$"],
        rows=rows,
    )


def table_6_recovery_stats() -> str:
    """Table VI — Per-stage recovery statistics."""
    rec = load_json(METRICS / "nopscadlib" / "recovery" / "per_layer_stats.json", required=False)
    if not rec:
        return "% Run experiments/05_recovery_stats/aggregate_recovery.py first.\n"
    layers = ["schema_repair", "scad_autofix", "vlm_correction", "component_verification", "manual_repair"]
    rows = []
    for layer in layers:
        s = rec.get(layer, {})
        rows.append([
            layer.replace("_", "\\_"),
            fmt(s.get("trigger_rate"), 3),
            fmt(s.get("mean_retries"), 2),
            fmt(s.get("post_recovery_success_rate"), 3),
        ])
    return latex_table(
        caption="Per-stage recovery statistics on NopSCADlib (5 layers, 10-attempt shared budget).",
        label="tab:recovery_stats",
        columns=["Layer", "Trigger rate", "Mean retries", "Post-recovery success"],
        rows=rows,
    )


def table_7_matched_effort() -> str:
    """Table VII — Matched-effort baselines."""
    summary = load_json(METRICS / "nopscadlib" / "chamfer" / "summaries.json", required=False)
    if not summary:
        return "% No metrics available for matched-effort baselines yet.\n"
    expected = ["craft", "direct_repair", "direct_vlm", "direct_matched_calls", "gpt52"]
    methods = [m for m in expected if m in summary]
    if not methods:
        return "% Matched-effort variants not found in metrics summary yet.\n"
    rows = []
    for m in methods:
        cd  = _geo_mean(summary[m], "cd")
        f1  = _geo_mean(summary[m], "f1")
        iou = _geo_mean(summary[m], "iou")
        rows.append([m.replace("_", "\\_"), fmt(cd), fmt(f1), fmt(iou)])
    return latex_table(
        caption="Matched-effort baselines on NopSCADlib (direct generation augmented to match CRAFT's compute).",
        label="tab:matched_effort",
        columns=["Method", "CD $\\downarrow$", "F1 $\\uparrow$", "Voxel IoU $\\uparrow$"],
        rows=rows,
    )


def table_8_editability() -> str:
    """Table VIII — Editability metrics."""
    summary = load_json(METRICS / "nopscadlib" / "editability" / "editability_summaries.json", required=False)
    if not summary:
        return "% Run experiments/03_metrics/editability/compute_editability.py first.\n"
    methods = sorted(summary.get("methods", {}).keys())
    rows = []
    for m in methods:
        s = summary["methods"][m]
        rows.append([
            m.replace("_", "\\_"),
            fmt(s.get("mean_exposed_parameters"), 1),
            fmt(s.get("symbolic_preservation_rate"), 3),
            fmt(s.get("edit_success_rate"), 3),
            fmt(s.get("post_edit_render_validity"), 3),
        ])
    return latex_table(
        caption="Editability of generated parametric CAD models on NopSCADlib.",
        label="tab:editability",
        columns=["Method", "\\# Params", "Symbolic ↑", "Edit success ↑", "Post-edit valid ↑"],
        rows=rows,
    )


# Registry --------------------------------------------------------------------

TABLES: Dict[int, Tuple[str, Callable[[], str]]] = {
    1: ("perceptual_nopscadlib", table_1_perceptual_nopscadlib),
    2: ("geometric_nopscadlib",  table_2_geometric_nopscadlib),
    3: ("ablation",              table_3_ablation),
    4: ("geometric_abc",         table_4_geometric_abc),
    5: ("geometric_slice100k",   table_5_geometric_slice100k),
    6: ("recovery_stats",        table_6_recovery_stats),
    7: ("matched_effort",        table_7_matched_effort),
    8: ("editability",           table_8_editability),
}


def write_table(n: int) -> Path:
    name, fn = TABLES[n]
    body = fn()
    out = TABLES_OUT / f"table_{n}_{name}.tex"
    out.write_text(body)
    print(f"wrote {out.relative_to(REPO_ROOT)}")
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description="Emit paper LaTeX tables from metric JSONs")
    parser.add_argument("--table", type=int, help="Single table number to emit")
    parser.add_argument("--all", action="store_true", help="Emit every registered table")
    parser.add_argument("--list", action="store_true", help="List registered tables and exit")
    args = parser.parse_args()

    if args.list:
        print("Registered tables:")
        for n, (name, _) in TABLES.items():
            print(f"  {n}: {name}")
        return 0

    if args.all:
        for n in sorted(TABLES):
            try:
                write_table(n)
            except Exception as e:
                print(f"table {n}: FAILED ({e})")
        return 0

    if args.table is None:
        parser.error("specify --all, --table N, or --list")
    if args.table not in TABLES:
        parser.error(f"unknown table {args.table}; see --list")

    write_table(args.table)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
