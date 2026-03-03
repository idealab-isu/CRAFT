#!/usr/bin/env python3
"""
Normal Consistency Evaluation for Text2CAD SPM 2026

Measures surface quality by comparing surface normal directions between
GT and predicted meshes. Unlike geometric metrics (CD, F1) that only check
*where* points are, Normal Consistency checks *which direction the surface
is facing* — capturing smoothness and correctness of surface orientation.

Higher Normal Consistency = predicted surfaces face the same directions as GT.

Usage:
    # Single model
    python evaluate_normal_consistency.py \
        --gt-dir ground_truth/stl \
        --pred-dir results/cadence/stl \
        --model-name cadence

    # Multiple models at once
    python evaluate_normal_consistency.py \
        --gt-dir ground_truth/stl \
        --models cadence=results/cadence/stl \
                 gpt4o=results/gpt4o/stl \
                 gpt52=results/gpt52/stl

Requirements:
    pip install numpy trimesh scipy

How Normal Consistency works:
    1. Load GT and Pred STL meshes
    2. Sample N points + their face normals from each mesh surface
    3. For each predicted point, find the nearest GT point (KD-tree)
    4. Compare normals:  NC_i = |n_pred · n_gt_nearest|  (absolute dot product)
    5. Average across all points:  NC = mean(NC_i)

    |cos(0°)| = 1.0   → normals aligned (perfect)
    |cos(90°)| = 0.0  → normals perpendicular (bad)

    We use absolute value because mesh winding order can flip normals
    without affecting actual surface quality.

    Score range: 0.0 (all normals wrong) to 1.0 (all normals match)
    Higher is better.

Why NC complements Chamfer Distance:
    CD only measures point positions — a faceted/rough mesh can have low CD
    if points are in the right locations but faces are tilted wrong.
    NC catches this: correct positions + wrong orientations → low NC.
    For CAD parts (which should have clean, precise surfaces), NC is
    especially informative.
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
class NCResult:
    """Normal Consistency result for a single GT↔Pred pair."""
    prompt_id: str
    model_name: str
    normal_consistency: float = float('nan')  # Higher is better [0, 1]
    tier: str = ""
    family: str = ""
    gt_stl_exists: bool = False
    pred_stl_exists: bool = False
    n_gt_points: int = 0
    n_pred_points: int = 0
    error: str = ""
    compute_time_s: float = 0.0


@dataclass
class NCSummary:
    """Aggregated Normal Consistency for one model."""
    model_name: str
    n_evaluated: int = 0
    n_skipped: int = 0
    # Overall
    nc_mean: float = float('nan')
    nc_std: float = float('nan')
    nc_median: float = float('nan')
    nc_min: float = float('nan')
    nc_max: float = float('nan')
    # Per-tier
    nc_by_tier: Dict[str, float] = field(default_factory=dict)
    nc_std_by_tier: Dict[str, float] = field(default_factory=dict)
    nc_count_by_tier: Dict[str, int] = field(default_factory=dict)


# =============================================================================
# MESH LOADING
# =============================================================================

def load_mesh(stl_path: str):
    """
    Load an STL file as a trimesh object.

    Handles both single meshes and scenes (multiple meshes concatenated).

    Returns:
        trimesh.Trimesh or None on failure
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
            return None

        return mesh

    except Exception as e:
        logger.warning(f"Failed to load STL {stl_path}: {e}")
        return None


def sample_points_and_normals(
    mesh,
    n_points: int = 10000,
    seed: int = 42
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """
    Sample points uniformly from a mesh surface along with their face normals.

    trimesh.sample.sample_surface returns (points, face_indices).
    We use face_indices to look up the corresponding face normals from
    mesh.face_normals, giving us the surface normal at each sampled point.

    Args:
        mesh: trimesh.Trimesh object
        n_points: Number of points to sample
        seed: Random seed for reproducibility

    Returns:
        (points, normals) — both (N, 3) arrays, or None on failure
    """
    import trimesh

    np.random.seed(seed)

    try:
        # sample_surface returns (points, face_indices)
        # face_indices tells us which triangle each point was sampled from
        points, face_indices = trimesh.sample.sample_surface(mesh, n_points)
        points = np.asarray(points)

        # Look up the face normal for each sampled point
        # mesh.face_normals is (F, 3) where F is the number of faces
        normals = np.asarray(mesh.face_normals[face_indices])

        return points, normals

    except Exception as e:
        logger.warning(f"Failed to sample points+normals: {e}")
        return None


# =============================================================================
# NORMAL CONSISTENCY COMPUTATION
# =============================================================================

def compute_normal_consistency(
    points_gt: np.ndarray,
    normals_gt: np.ndarray,
    points_pred: np.ndarray,
    normals_pred: np.ndarray,
    normalize_points: bool = True
) -> float:
    """
    Compute Normal Consistency between GT and predicted meshes.

    For each predicted point:
      1. Find its nearest neighbor in the GT point cloud (using KD-tree)
      2. Get the GT normal at that nearest point
      3. Compute |dot(n_pred, n_gt_nearest)| — absolute cosine similarity

    We take the absolute value because mesh winding order (which determines
    whether normals point inward or outward) can be inconsistent, and a
    flipped normal doesn't mean the surface orientation is actually wrong.

    The final NC score is the average across all predicted points.

    Args:
        points_gt: (N, 3) GT point positions
        normals_gt: (N, 3) GT surface normals
        points_pred: (M, 3) predicted point positions
        normals_pred: (M, 3) predicted surface normals
        normalize_points: Whether to normalize positions to unit cube
                         (doesn't affect normals, only the NN search)

    Returns:
        Normal Consistency score in [0, 1], higher is better
    """
    from scipy.spatial import cKDTree

    if normalize_points:
        # Normalize to unit cube for consistent NN search
        all_pts = np.vstack([points_gt, points_pred])
        center = (all_pts.max(axis=0) + all_pts.min(axis=0)) / 2
        extent = (all_pts.max(axis=0) - all_pts.min(axis=0)).max()
        if extent > 0:
            points_gt = (points_gt - center) / extent
            points_pred = (points_pred - center) / extent

    # Ensure normals are unit length
    gt_norms = np.linalg.norm(normals_gt, axis=1, keepdims=True)
    gt_norms = np.clip(gt_norms, 1e-10, None)
    normals_gt = normals_gt / gt_norms

    pred_norms = np.linalg.norm(normals_pred, axis=1, keepdims=True)
    pred_norms = np.clip(pred_norms, 1e-10, None)
    normals_pred = normals_pred / pred_norms

    # Build KD-tree on GT points for nearest neighbor lookup
    tree_gt = cKDTree(points_gt)

    # For each predicted point, find nearest GT point
    _, nn_indices = tree_gt.query(points_pred, k=1)

    # Get GT normals at the nearest points
    nn_normals_gt = normals_gt[nn_indices]

    # Compute absolute dot product (cosine similarity) per point
    # dot product of unit vectors = cos(angle)
    # absolute value because winding order can flip normals
    dots = np.abs(np.sum(normals_pred * nn_normals_gt, axis=1))

    # Clamp to [0, 1] for numerical safety
    dots = np.clip(dots, 0.0, 1.0)

    return float(np.mean(dots))


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
) -> NCResult:
    """Evaluate Normal Consistency for a single GT↔Pred pair."""
    result = NCResult(
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

    # Sample points + normals
    gt_data = sample_points_and_normals(mesh_gt, n_points, seed=42)
    pred_data = sample_points_and_normals(mesh_pred, n_points, seed=43)

    if gt_data is None:
        result.error = "failed to sample gt points+normals"
        return result
    if pred_data is None:
        result.error = "failed to sample pred points+normals"
        return result

    points_gt, normals_gt = gt_data
    points_pred, normals_pred = pred_data

    result.n_gt_points = len(points_gt)
    result.n_pred_points = len(points_pred)

    # Compute Normal Consistency
    result.normal_consistency = compute_normal_consistency(
        points_gt, normals_gt, points_pred, normals_pred
    )

    result.compute_time_s = time.time() - t0
    return result


def evaluate_model(
    components: List[dict],
    gt_dir: str,
    pred_dir: str,
    model_name: str,
    prompt_ids: Optional[List[str]] = None,
    n_points: int = 10000
) -> Tuple[List[NCResult], NCSummary]:
    """
    Evaluate Normal Consistency for one model against GT.

    Args:
        components: List of component metadata dicts
        gt_dir: Directory containing GT STL files
        pred_dir: Directory containing predicted STL files
        model_name: Name of the model
        prompt_ids: Optional subset of IDs to evaluate
        n_points: Points to sample per mesh

    Returns:
        (list of NCResult, NCSummary)
    """
    logger.info(f"Evaluating Normal Consistency for: {model_name}")
    logger.info(f"  GT:   {gt_dir}")
    logger.info(f"  Pred: {pred_dir}")

    if prompt_ids:
        id_set = set(prompt_ids)
        components = [c for c in components if c["id"] in id_set]

    # Build component lookup for tier/family info
    comp_lookup = {c["id"]: c for c in components}

    # Find all GT STL files
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
                f"NC={result.normal_consistency:.4f}"
            )

    summary = _compute_summary(results, model_name)
    return results, summary


def _compute_summary(results: List[NCResult], model_name: str) -> NCSummary:
    """Compute aggregated summary from individual results."""
    summary = NCSummary(model_name=model_name)

    valid = [r for r in results if not r.error and np.isfinite(r.normal_consistency)]
    summary.n_evaluated = len(valid)
    summary.n_skipped = len(results) - len(valid)

    if not valid:
        return summary

    scores = [r.normal_consistency for r in valid]
    summary.nc_mean = float(np.mean(scores))
    summary.nc_std = float(np.std(scores))
    summary.nc_median = float(np.median(scores))
    summary.nc_min = float(np.min(scores))
    summary.nc_max = float(np.max(scores))

    for tier in ["Simple", "Medium", "Complex"]:
        tier_scores = [r.normal_consistency for r in valid if r.tier == tier]
        if tier_scores:
            summary.nc_by_tier[tier] = float(np.mean(tier_scores))
            summary.nc_std_by_tier[tier] = float(np.std(tier_scores))
            summary.nc_count_by_tier[tier] = len(tier_scores)

    return summary


# =============================================================================
# OUTPUT FORMATTERS
# =============================================================================

def save_results(
    all_results: Dict[str, List[NCResult]],
    all_summaries: Dict[str, NCSummary],
    output_dir: str
):
    """Save results to JSON, CSV, and markdown."""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Detailed results JSON
    detailed = {}
    for model_name, results in all_results.items():
        detailed[model_name] = [asdict(r) for r in results]

    with open(out_path / "nc_detailed_results.json", 'w') as f:
        json.dump(detailed, f, indent=2, default=str)

    # Summaries JSON
    summaries_data = {name: asdict(s) for name, s in all_summaries.items()}
    with open(out_path / "nc_summaries.json", 'w') as f:
        json.dump(summaries_data, f, indent=2, default=str)

    _generate_markdown_table(all_summaries, all_results, out_path)
    _generate_csv(all_results, out_path)

    logger.info(f"Results saved to {out_path}")


def _generate_csv(all_results: Dict[str, List[NCResult]], out_path: Path):
    """Generate CSV with per-sample NC scores."""
    all_ids = set()
    for results in all_results.values():
        for r in results:
            all_ids.add(r.prompt_id)

    lookups = {}
    tiers = {}
    families = {}
    for model_name, results in all_results.items():
        lookups[model_name] = {}
        for r in results:
            lookups[model_name][r.prompt_id] = r.normal_consistency
            tiers[r.prompt_id] = r.tier
            families[r.prompt_id] = r.family

    models = sorted(all_results.keys())
    sorted_ids = sorted(all_ids)

    lines = ["prompt_id,tier,family," + ",".join(f"nc_{m}" for m in models)]
    for pid in sorted_ids:
        tier = tiers.get(pid, "")
        family = families.get(pid, "")
        scores = []
        for m in models:
            val = lookups[m].get(pid, float('nan'))
            scores.append(f"{val:.6f}" if np.isfinite(val) else "")
        lines.append(f"{pid},{tier},{family},{','.join(scores)}")

    with open(out_path / "nc_scores.csv", 'w') as f:
        f.write("\n".join(lines))


def _generate_markdown_table(
    summaries: Dict[str, NCSummary],
    all_results: Dict[str, List[NCResult]],
    out_path: Path
):
    """Generate markdown comparison table."""
    lines = []
    models = sorted(summaries.keys())

    lines.append("# Normal Consistency Evaluation Results")
    lines.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"Higher NC = predicted surface normals better match GT surface normals.\n")

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
        ("NC (mean) ↑", lambda s: s.nc_mean, True),
        ("NC (std)", lambda s: s.nc_std, False),
        ("NC (median)", lambda s: s.nc_median, True),
        ("NC (min)", lambda s: s.nc_min, False),
        ("NC (max)", lambda s: s.nc_max, False),
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
            best = max(finite_vals) if finite_vals else None
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

        row = "| NC ↑ |"
        values = {}
        for m in models:
            values[m] = summaries[m].nc_by_tier.get(tier, float('nan'))
        finite_vals = [v for v in values.values() if np.isfinite(v)]
        best = max(finite_vals) if finite_vals and len(models) > 1 else None
        for m in models:
            val = values[m]
            formatted = fmt(val)
            if best is not None and np.isfinite(val) and val == best:
                formatted = f"**{formatted}**"
            row += f" {formatted} |"
        lines.append(row)

        row = "| Count |"
        for m in models:
            count = summaries[m].nc_count_by_tier.get(tier, 0)
            row += f" {count} |"
        lines.append(row)

    # Best/worst samples
    if models:
        first_model = models[0]
        first_results = [r for r in all_results[first_model]
                         if not r.error and np.isfinite(r.normal_consistency)]
        if first_results:
            sorted_results = sorted(
                first_results, key=lambda r: r.normal_consistency, reverse=True
            )

            lines.append(f"\n## Top 10 Best Surface Quality ({first_model})\n")
            lines.append("| Rank | Prompt ID | Tier | NC |")
            lines.append("|------|-----------|------|----|")
            for i, r in enumerate(sorted_results[:10], 1):
                lines.append(f"| {i} | {r.prompt_id} | {r.tier} | {fmt(r.normal_consistency)} |")

            lines.append(f"\n## Top 10 Worst Surface Quality ({first_model})\n")
            lines.append("| Rank | Prompt ID | Tier | NC |")
            lines.append("|------|-----------|------|----|")
            for i, r in enumerate(sorted_results[-10:], 1):
                lines.append(f"| {i} | {r.prompt_id} | {r.tier} | {fmt(r.normal_consistency)} |")

    md_path = out_path / "nc_comparison_table.md"
    with open(md_path, 'w') as f:
        f.write("\n".join(lines))

    logger.info(f"NC comparison table saved to {md_path}")


def print_summary(summaries: Dict[str, NCSummary]):
    """Print a compact summary to console."""
    models = sorted(summaries.keys())

    print(f"\n{'='*70}")
    print(f"NORMAL CONSISTENCY EVALUATION SUMMARY")
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

    row("NC (mean) ↑", lambda s: s.nc_mean)
    row("NC (std)", lambda s: s.nc_std)
    row("NC (median)", lambda s: s.nc_median)
    row("NC (min)", lambda s: s.nc_min)
    row("NC (max)", lambda s: s.nc_max)
    row("Evaluated", lambda s: float(s.n_evaluated), "{:>12.0f}")
    row("Skipped", lambda s: float(s.n_skipped), "{:>12.0f}")

    for tier in ["Simple", "Medium", "Complex"]:
        print(f"\n  {tier}:")
        row(f"  NC ↑", lambda s, t=tier: s.nc_by_tier.get(t, float('nan')))
        row(f"  Count", lambda s, t=tier: float(s.nc_count_by_tier.get(t, 0)), "{:>12.0f}")

    print(f"\n{'='*70}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Normal Consistency Evaluation — Surface Quality Metric",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single model
  python evaluate_normal_consistency.py --gt-dir ground_truth/stl \\
    --pred-dir results/cadence/stl --model-name cadence

  # Multiple models
  python evaluate_normal_consistency.py --gt-dir ground_truth/stl \\
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
                        default=str(SCRIPT_DIR / "evaluation_results" / "normal_consistency"),
                        help="Output directory for results")
    parser.add_argument("--n-points", type=int, default=10000,
                        help="Number of points to sample per mesh")

    args = parser.parse_args()

    if not args.pred_dir and not args.models:
        parser.error(
            "Normal Consistency requires predicted STLs to compare against GT.\n"
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
