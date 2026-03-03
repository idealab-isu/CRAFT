#!/usr/bin/env python3
"""
Hausdorff Distance Evaluation for Text2CAD SPM 2026

Measures the worst-case geometric error between GT and predicted meshes.
While Chamfer Distance reports the *average* nearest-point distance,
Hausdorff Distance reports the *maximum* — capturing catastrophic failures
that CD averages away.

Lower Hausdorff = no part of the prediction is far from GT (robustness).

Usage:
    # Single model
    python evaluate_hausdorff.py \
        --gt-dir ground_truth/stl \
        --pred-dir results/cadence/stl \
        --model-name cadence

    # Multiple models at once
    python evaluate_hausdorff.py \
        --gt-dir ground_truth/stl \
        --models cadence=results/cadence/stl \
                 gpt4o=results/gpt4o/stl \
                 gpt52=results/gpt52/stl

Requirements:
    pip install numpy trimesh scipy

How Hausdorff Distance works:
    1. Sample N points from GT mesh surface
    2. Sample N points from Pred mesh surface
    3. Normalize both to unit cube (same as CD computation)
    4. For each Pred point, find distance to nearest GT point → d_pred_i
       For each GT point, find distance to nearest Pred point → d_gt_j
    5. HD = max( max(d_pred_i), max(d_gt_j) )

    The "directed" Hausdorff from Pred→GT is max(d_pred_i): the farthest
    any predicted point is from the GT surface. The "directed" from GT→Pred
    is max(d_gt_j): the farthest any GT point is from any prediction.
    The full (symmetric) Hausdorff is the max of both directions.

    We also report percentile variants:
      HD95 = 95th percentile of all distances (robust to single outliers)
      HD90 = 90th percentile (even more robust)

    Score range: 0.0 (identical) to ~1.0+ (normalized, lower is better)

Why HD complements Chamfer Distance:
    CD is an average — 99% perfect + 1% catastrophic = low CD.
    HD catches that 1%. If a model produces shapes with spikes, missing
    sections, or extra geometry, HD exposes it even when CD looks fine.
    Low HD = the model is *robust* — no catastrophic geometric failures.
"""

import os
import sys
import json
import argparse
import time
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field, asdict
from datetime import datetime

import numpy as np

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%H:%M:%S'
)
logger = logging.getLogger(__name__)

SCRIPT_DIR = Path(__file__).parent


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class HDResult:
    """Hausdorff Distance result for a single GT↔Pred pair."""
    prompt_id: str
    model_name: str
    hausdorff: float = float('nan')      # Full HD (max), lower is better
    hausdorff_95: float = float('nan')   # 95th percentile
    hausdorff_90: float = float('nan')   # 90th percentile
    # Directed components (for analysis)
    hd_pred_to_gt: float = float('nan')  # max dist from any Pred point to GT
    hd_gt_to_pred: float = float('nan')  # max dist from any GT point to Pred
    tier: str = ""
    family: str = ""
    gt_stl_exists: bool = False
    pred_stl_exists: bool = False
    error: str = ""
    compute_time_s: float = 0.0


@dataclass
class HDSummary:
    """Aggregated Hausdorff Distances for one model."""
    model_name: str
    n_evaluated: int = 0
    n_skipped: int = 0
    # Overall (all use mean across samples)
    hd_mean: float = float('nan')
    hd_std: float = float('nan')
    hd_median: float = float('nan')
    hd95_mean: float = float('nan')
    hd95_median: float = float('nan')
    hd90_mean: float = float('nan')
    hd90_median: float = float('nan')
    # Per-tier
    hd_by_tier: Dict[str, float] = field(default_factory=dict)
    hd95_by_tier: Dict[str, float] = field(default_factory=dict)
    hd_count_by_tier: Dict[str, int] = field(default_factory=dict)


# =============================================================================
# MESH LOADING + POINT SAMPLING
# =============================================================================

def load_mesh(stl_path: str):
    """
    Load an STL file as a trimesh object.

    Handles both single meshes and scenes (multiple meshes concatenated).
    """
    import trimesh

    try:
        mesh = trimesh.load(stl_path)

        if isinstance(mesh, trimesh.Scene):
            meshes = [
                g for g in mesh.geometry.values()
                if isinstance(g, trimesh.Trimesh)
            ]
            if not meshes:
                return None
            mesh = trimesh.util.concatenate(meshes)

        if not isinstance(mesh, trimesh.Trimesh):
            return None

        if not hasattr(mesh, 'faces') or mesh.faces.size == 0:
            # Point cloud only — use vertices directly
            return mesh

        return mesh

    except Exception as e:
        logger.warning(f"Failed to load STL {stl_path}: {e}")
        return None


def sample_points(mesh, n_points: int = 10000, seed: int = 42) -> Optional[np.ndarray]:
    """Sample points uniformly from mesh surface."""
    import trimesh

    np.random.seed(seed)

    try:
        if hasattr(mesh, 'faces') and mesh.faces.size > 0:
            points, _ = trimesh.sample.sample_surface(mesh, n_points)
        else:
            verts = np.asarray(mesh.vertices)
            n = min(n_points, verts.shape[0])
            idx = np.random.choice(verts.shape[0], n, replace=False)
            points = verts[idx]
        return np.asarray(points)
    except Exception as e:
        logger.warning(f"Failed to sample points: {e}")
        return None


def normalize_to_unit_cube(points: np.ndarray) -> np.ndarray:
    """Normalize points to [0, 1] unit cube."""
    mins = points.min(axis=0)
    maxs = points.max(axis=0)
    extent = (maxs - mins).max()
    if extent < 1e-10:
        return points - mins
    return (points - mins) / extent


# =============================================================================
# HAUSDORFF DISTANCE COMPUTATION
# =============================================================================

def compute_hausdorff(
    pc_gt: np.ndarray,
    pc_pred: np.ndarray,
    normalize: bool = True
) -> Tuple[float, float, float, float, float]:
    """
    Compute Hausdorff Distance between two point clouds.

    The computation:
      1. For each point in Pred, find distance to nearest GT point
         → d_pred = array of nearest-neighbor distances
      2. For each point in GT, find distance to nearest Pred point
         → d_gt = array of nearest-neighbor distances
      3. Combine all distances and compute:
         HD     = max(max(d_pred), max(d_gt))     — absolute worst case
         HD95   = 95th percentile of all distances — robust worst case
         HD90   = 90th percentile                  — more robust

    We also return the directed components:
      hd_pred_to_gt = max(d_pred)  — "how far does the worst Pred point stray?"
      hd_gt_to_pred = max(d_gt)    — "how much of GT is missing from Pred?"

    Args:
        pc_gt: (N, 3) GT point cloud
        pc_pred: (M, 3) Predicted point cloud
        normalize: Whether to normalize both to unit cube first

    Returns:
        (hausdorff, hd95, hd90, hd_pred_to_gt, hd_gt_to_pred)
    """
    from scipy.spatial import cKDTree

    if normalize:
        # Normalize jointly so both are in the same coordinate frame
        all_pts = np.vstack([pc_gt, pc_pred])
        mins = all_pts.min(axis=0)
        maxs = all_pts.max(axis=0)
        extent = (maxs - mins).max()
        if extent > 1e-10:
            pc_gt = (pc_gt - mins) / extent
            pc_pred = (pc_pred - mins) / extent

    # Build KD-trees for fast nearest-neighbor queries
    tree_gt = cKDTree(pc_gt)
    tree_pred = cKDTree(pc_pred)

    # Pred → GT: for each predicted point, distance to nearest GT point
    d_pred_to_gt, _ = tree_gt.query(pc_pred, k=1)

    # GT → Pred: for each GT point, distance to nearest predicted point
    d_gt_to_pred, _ = tree_pred.query(pc_gt, k=1)

    # Directed Hausdorff distances
    hd_pred_to_gt = float(np.max(d_pred_to_gt))
    hd_gt_to_pred = float(np.max(d_gt_to_pred))

    # Symmetric Hausdorff = max of both directions
    hausdorff = max(hd_pred_to_gt, hd_gt_to_pred)

    # Percentile variants (combine all distances)
    all_distances = np.concatenate([d_pred_to_gt, d_gt_to_pred])
    hd95 = float(np.percentile(all_distances, 95))
    hd90 = float(np.percentile(all_distances, 90))

    return hausdorff, hd95, hd90, hd_pred_to_gt, hd_gt_to_pred


# =============================================================================
# EVALUATION PIPELINE
# =============================================================================

def load_benchmark_metadata(benchmark_json: str) -> List[dict]:
    """Load component metadata from benchmark_ground_truth.json."""
    with open(benchmark_json) as f:
        data = json.load(f)

    components = data.get("components", [])
    logger.info(f"Loaded {len(components)} components from {benchmark_json}")
    return components


def evaluate_single(
    prompt_id: str,
    gt_stl_path: str,
    pred_stl_path: str,
    model_name: str,
    tier: str = "",
    family: str = "",
    n_points: int = 10000
) -> HDResult:
    """Evaluate Hausdorff Distance for a single GT↔Pred pair."""
    result = HDResult(
        prompt_id=prompt_id,
        model_name=model_name,
        tier=tier,
        family=family,
    )

    t0 = time.time()

    result.gt_stl_exists = os.path.exists(gt_stl_path)
    result.pred_stl_exists = os.path.exists(pred_stl_path)

    if not result.gt_stl_exists:
        result.error = "gt stl not found"
        return result
    if not result.pred_stl_exists:
        result.error = "pred stl not found"
        return result

    # Load meshes
    mesh_gt = load_mesh(gt_stl_path)
    mesh_pred = load_mesh(pred_stl_path)

    if mesh_gt is None:
        result.error = "failed to load gt mesh"
        return result
    if mesh_pred is None:
        result.error = "failed to load pred mesh"
        return result

    # Sample points
    pc_gt = sample_points(mesh_gt, n_points, seed=42)
    pc_pred = sample_points(mesh_pred, n_points, seed=43)

    if pc_gt is None or pc_pred is None:
        result.error = "failed to sample points"
        return result

    # Compute Hausdorff
    hd, hd95, hd90, hd_p2g, hd_g2p = compute_hausdorff(
        pc_gt, pc_pred, normalize=True
    )

    result.hausdorff = hd
    result.hausdorff_95 = hd95
    result.hausdorff_90 = hd90
    result.hd_pred_to_gt = hd_p2g
    result.hd_gt_to_pred = hd_g2p
    result.compute_time_s = time.time() - t0

    return result


def evaluate_model(
    components: List[dict],
    gt_dir: str,
    pred_dir: str,
    model_name: str,
    prompt_ids: Optional[List[str]] = None,
    n_points: int = 10000
) -> Tuple[List[HDResult], HDSummary]:
    """
    Evaluate Hausdorff Distance for one model against GT.

    Args:
        components: List of component metadata dicts
        gt_dir: Directory containing GT STL files
        pred_dir: Directory containing predicted STL files
        model_name: Name of the model
        prompt_ids: Optional subset of IDs to evaluate
        n_points: Points to sample per mesh
    """
    logger.info(f"Evaluating Hausdorff Distance for: {model_name}")
    logger.info(f"  GT:   {gt_dir}")
    logger.info(f"  Pred: {pred_dir}")

    if prompt_ids:
        id_set = set(prompt_ids)
        components = [c for c in components if c["id"] in id_set]

    comp_lookup = {c["id"]: c for c in components}

    # Find GT STL files
    gt_stls = sorted(Path(gt_dir).glob("*.stl"))
    pids = [p.stem for p in gt_stls]

    if prompt_ids:
        pids = [p for p in pids if p in set(prompt_ids)]

    logger.info(f"  Found {len(pids)} GT STL files")

    results = []
    for i, pid in enumerate(pids):
        gt_path = os.path.join(gt_dir, f"{pid}.stl")
        pred_path = os.path.join(pred_dir, f"{pid}.stl")
        comp = comp_lookup.get(pid, {})

        result = evaluate_single(
            prompt_id=pid,
            gt_stl_path=gt_path,
            pred_stl_path=pred_path,
            model_name=model_name,
            tier=comp.get("tier", ""),
            family=comp.get("component_family", ""),
            n_points=n_points,
        )
        results.append(result)

        if (i + 1) % 50 == 0 or (i + 1) == len(pids):
            n_done = sum(1 for r in results if not r.error)
            logger.info(
                f"  [{i+1}/{len(pids)}] "
                f"evaluated={n_done}  "
                f"HD={result.hausdorff:.4f}  "
                f"HD95={result.hausdorff_95:.4f}"
            )

    summary = _compute_summary(results, model_name)
    return results, summary


def _compute_summary(results: List[HDResult], model_name: str) -> HDSummary:
    """Compute aggregated summary from individual results."""
    summary = HDSummary(model_name=model_name)

    valid = [r for r in results if not r.error and np.isfinite(r.hausdorff)]
    summary.n_evaluated = len(valid)
    summary.n_skipped = len(results) - len(valid)

    if not valid:
        return summary

    hds = [r.hausdorff for r in valid]
    hd95s = [r.hausdorff_95 for r in valid]
    hd90s = [r.hausdorff_90 for r in valid]

    summary.hd_mean = float(np.mean(hds))
    summary.hd_std = float(np.std(hds))
    summary.hd_median = float(np.median(hds))
    summary.hd95_mean = float(np.mean(hd95s))
    summary.hd95_median = float(np.median(hd95s))
    summary.hd90_mean = float(np.mean(hd90s))
    summary.hd90_median = float(np.median(hd90s))

    for tier in ["Simple", "Medium", "Complex"]:
        tier_results = [r for r in valid if r.tier == tier]
        if tier_results:
            tier_hds = [r.hausdorff for r in tier_results]
            tier_hd95s = [r.hausdorff_95 for r in tier_results]
            summary.hd_by_tier[tier] = float(np.mean(tier_hds))
            summary.hd95_by_tier[tier] = float(np.mean(tier_hd95s))
            summary.hd_count_by_tier[tier] = len(tier_results)

    return summary


# =============================================================================
# OUTPUT FORMATTERS
# =============================================================================

def save_results(
    all_results: Dict[str, List[HDResult]],
    all_summaries: Dict[str, HDSummary],
    output_dir: str
):
    """Save results to JSON, CSV, and markdown."""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Detailed JSON
    detailed = {}
    for model_name, results in all_results.items():
        detailed[model_name] = [asdict(r) for r in results]

    with open(out_path / "hd_detailed_results.json", 'w') as f:
        json.dump(detailed, f, indent=2, default=str)

    # Summaries JSON
    summaries_data = {name: asdict(s) for name, s in all_summaries.items()}
    with open(out_path / "hd_summaries.json", 'w') as f:
        json.dump(summaries_data, f, indent=2, default=str)

    _generate_markdown_table(all_summaries, all_results, out_path)
    _generate_csv(all_results, out_path)

    logger.info(f"Results saved to {out_path}")


def _generate_csv(all_results: Dict[str, List[HDResult]], out_path: Path):
    """Generate CSV with per-sample Hausdorff scores."""
    all_ids = set()
    for results in all_results.values():
        for r in results:
            all_ids.add(r.prompt_id)

    lookups_hd = {}
    lookups_hd95 = {}
    tiers = {}
    families = {}
    for model_name, results in all_results.items():
        lookups_hd[model_name] = {}
        lookups_hd95[model_name] = {}
        for r in results:
            lookups_hd[model_name][r.prompt_id] = r.hausdorff
            lookups_hd95[model_name][r.prompt_id] = r.hausdorff_95
            tiers[r.prompt_id] = r.tier
            families[r.prompt_id] = r.family

    models = sorted(all_results.keys())
    sorted_ids = sorted(all_ids)

    cols = []
    for m in models:
        cols.extend([f"hd_{m}", f"hd95_{m}"])
    lines = ["prompt_id,tier,family," + ",".join(cols)]

    for pid in sorted_ids:
        tier = tiers.get(pid, "")
        family = families.get(pid, "")
        scores = []
        for m in models:
            hd_val = lookups_hd[m].get(pid, float('nan'))
            hd95_val = lookups_hd95[m].get(pid, float('nan'))
            scores.append(f"{hd_val:.6f}" if np.isfinite(hd_val) else "")
            scores.append(f"{hd95_val:.6f}" if np.isfinite(hd95_val) else "")
        lines.append(f"{pid},{tier},{family},{','.join(scores)}")

    with open(out_path / "hd_scores.csv", 'w') as f:
        f.write("\n".join(lines))


def _generate_markdown_table(
    summaries: Dict[str, HDSummary],
    all_results: Dict[str, List[HDResult]],
    out_path: Path
):
    """Generate markdown comparison table."""
    lines = []
    models = sorted(summaries.keys())

    lines.append("# Hausdorff Distance Evaluation Results")
    lines.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Lower Hausdorff = no catastrophic geometric errors.\n")

    def fmt(val):
        return f"{val:.4f}" if np.isfinite(val) else "N/A"

    # Main table
    lines.append("## Overall Comparison\n")
    header = "| Metric |"
    sep = "|--------|"
    for m in models:
        header += f" {m} |"
        sep += "------|"
    lines.append(header)
    lines.append(sep)

    rows = [
        ("HD (mean) ↓", lambda s: s.hd_mean, True),
        ("HD (median)", lambda s: s.hd_median, True),
        ("HD (std)", lambda s: s.hd_std, False),
        ("HD95 (mean) ↓", lambda s: s.hd95_mean, True),
        ("HD95 (median)", lambda s: s.hd95_median, True),
        ("HD90 (mean) ↓", lambda s: s.hd90_mean, True),
        ("HD90 (median)", lambda s: s.hd90_median, True),
        ("Evaluated", lambda s: float(s.n_evaluated), False),
        ("Skipped", lambda s: float(s.n_skipped), False),
    ]

    for label, getter, bold_best in rows:
        row = f"| {label} |"
        values = {}
        for m in models:
            values[m] = getter(summaries[m])
        if bold_best and len(models) > 1:
            finite_vals = [v for v in values.values() if np.isfinite(v)]
            best = min(finite_vals) if finite_vals else None
        else:
            best = None
        for m in models:
            val = values[m]
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            row += f" {formatted} |"
        lines.append(row)

    # Per-tier
    lines.append("\n## Per-Tier Comparison\n")
    for tier in ["Simple", "Medium", "Complex"]:
        lines.append(f"\n### {tier}\n")
        header = "| Metric |"
        sep = "|--------|"
        for m in models:
            header += f" {m} |"
            sep += "------|"
        lines.append(header)
        lines.append(sep)

        # HD
        row = "| HD ↓ |"
        values = {}
        for m in models:
            values[m] = summaries[m].hd_by_tier.get(tier, float('nan'))
        finite_vals = [v for v in values.values() if np.isfinite(v)]
        best = min(finite_vals) if finite_vals and len(models) > 1 else None
        for m in models:
            val = values[m]
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            row += f" {formatted} |"
        lines.append(row)

        # HD95
        row = "| HD95 ↓ |"
        values = {}
        for m in models:
            values[m] = summaries[m].hd95_by_tier.get(tier, float('nan'))
        finite_vals = [v for v in values.values() if np.isfinite(v)]
        best = min(finite_vals) if finite_vals and len(models) > 1 else None
        for m in models:
            val = values[m]
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            row += f" {formatted} |"
        lines.append(row)

        row = "| Count |"
        for m in models:
            count = summaries[m].hd_count_by_tier.get(tier, 0)
            row += f" {count} |"
        lines.append(row)

    # Worst samples (highest HD — most problematic predictions)
    if models:
        first_model = models[0]
        first_results = [r for r in all_results[first_model]
                         if not r.error and np.isfinite(r.hausdorff)]
        if first_results:
            sorted_results = sorted(first_results, key=lambda r: r.hausdorff)

            lines.append(f"\n## Top 10 Best (Lowest HD) — {first_model}\n")
            lines.append("| Rank | Prompt ID | Tier | HD | HD95 |")
            lines.append("|------|-----------|------|----|------|")
            for i, r in enumerate(sorted_results[:10], 1):
                lines.append(
                    f"| {i} | {r.prompt_id} | {r.tier} "
                    f"| {fmt(r.hausdorff)} | {fmt(r.hausdorff_95)} |"
                )

            lines.append(f"\n## Top 10 Worst (Highest HD) — {first_model}\n")
            lines.append("| Rank | Prompt ID | Tier | HD | HD95 | Pred→GT | GT→Pred |")
            lines.append("|------|-----------|------|----|------|---------|---------|")
            for i, r in enumerate(reversed(sorted_results[-10:]), 1):
                lines.append(
                    f"| {i} | {r.prompt_id} | {r.tier} "
                    f"| {fmt(r.hausdorff)} | {fmt(r.hausdorff_95)} "
                    f"| {fmt(r.hd_pred_to_gt)} | {fmt(r.hd_gt_to_pred)} |"
                )
            lines.append("")
            lines.append("Pred→GT = extra geometry (prediction has parts GT doesn't)")
            lines.append("GT→Pred = missing geometry (prediction is missing parts GT has)")

    md_path = out_path / "hd_comparison_table.md"
    with open(md_path, 'w') as f:
        f.write("\n".join(lines))

    logger.info(f"HD comparison table saved to {md_path}")


def print_summary(summaries: Dict[str, HDSummary]):
    """Print a compact summary to console."""
    models = sorted(summaries.keys())

    print(f"\n{'='*70}")
    print(f"HAUSDORFF DISTANCE EVALUATION SUMMARY")
    print(f"{'='*70}")

    header = f"{'Metric':<25}"
    for m in models:
        header += f" {m:>12}"
    print(header)
    print("-" * len(header))

    def row(label, getter, fmt_str="{:>12.4f}"):
        line = f"{label:<25}"
        for m in models:
            val = getter(summaries[m])
            if np.isnan(val):
                line += f" {'N/A':>12}"
            else:
                line += fmt_str.format(val)
        print(line)

    row("HD (mean) ↓", lambda s: s.hd_mean)
    row("HD (median)", lambda s: s.hd_median)
    row("HD (std)", lambda s: s.hd_std)
    row("HD95 (mean) ↓", lambda s: s.hd95_mean)
    row("HD90 (mean) ↓", lambda s: s.hd90_mean)
    row("Evaluated", lambda s: float(s.n_evaluated), "{:>12.0f}")
    row("Skipped", lambda s: float(s.n_skipped), "{:>12.0f}")

    for tier in ["Simple", "Medium", "Complex"]:
        print(f"\n  {tier}:")
        row(f"  HD ↓", lambda s, t=tier: s.hd_by_tier.get(t, float('nan')))
        row(f"  HD95 ↓", lambda s, t=tier: s.hd95_by_tier.get(t, float('nan')))
        row(f"  Count", lambda s, t=tier: float(s.hd_count_by_tier.get(t, 0)), "{:>12.0f}")

    print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Hausdorff Distance Evaluation — Worst-Case Geometric Error",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single model
  python evaluate_hausdorff.py --gt-dir ground_truth/stl \\
    --pred-dir results/cadence/stl --model-name cadence

  # Multiple models
  python evaluate_hausdorff.py --gt-dir ground_truth/stl \\
    --models cadence=results/cadence/stl gpt4o=results/gpt4o/stl gpt52=results/gpt52/stl
        """
    )

    parser.add_argument("--gt-dir", type=str, required=True,
                        help="Directory containing ground truth STL files")
    parser.add_argument("--pred-dir", type=str, default=None,
                        help="Directory containing predicted STL files (single model)")
    parser.add_argument("--model-name", type=str, default="model",
                        help="Name of the model (for single model mode)")
    parser.add_argument("--models", nargs="+", default=None,
                        help="Multiple models as name=dir pairs "
                             "(e.g., cadence=results/cadence/stl)")
    parser.add_argument("--benchmark-json", type=str,
                        default=str(SCRIPT_DIR / "benchmark_ground_truth.json"),
                        help="Path to benchmark_ground_truth.json")
    parser.add_argument("--prompt-ids", nargs="+", default=None,
                        help="Specific prompt IDs to evaluate")
    parser.add_argument("--output-dir", type=str,
                        default=str(SCRIPT_DIR / "evaluation_results" / "hausdorff"),
                        help="Output directory for results")
    parser.add_argument("--n-points", type=int, default=10000,
                        help="Number of points to sample per mesh")

    args = parser.parse_args()

    if not args.pred_dir and not args.models:
        parser.error(
            "Hausdorff Distance requires predicted STLs to compare against GT.\n"
            "Use --pred-dir or --models to specify model outputs."
        )

    # Load benchmark metadata
    components = load_benchmark_metadata(args.benchmark_json)

    # Build model configurations
    model_configs = {}
    if args.models:
        for model_spec in args.models:
            name, pred_dir = model_spec.split("=", 1)
            model_configs[name] = pred_dir
    else:
        model_configs[args.model_name] = args.pred_dir

    # Run evaluation
    all_results = {}
    all_summaries = {}

    for model_name, pred_dir in model_configs.items():
        print(f"\n{'='*60}")
        print(f"Evaluating: {model_name}")
        print(f"{'='*60}")

        results, summary = evaluate_model(
            components=components,
            gt_dir=args.gt_dir,
            pred_dir=pred_dir,
            model_name=model_name,
            prompt_ids=args.prompt_ids,
            n_points=args.n_points,
        )

        all_results[model_name] = results
        all_summaries[model_name] = summary

    # Print summary
    print_summary(all_summaries)

    # Save results
    save_results(all_results, all_summaries, args.output_dir)


if __name__ == "__main__":
    main()
