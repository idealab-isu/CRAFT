#!/usr/bin/env python3
"""
Benchmark Evaluation Script for Text2CAD SPM 2026

Computes 4 metrics between ground truth STLs and model-generated STLs:
  1. Chamfer Distance (CD) — normalized, point-cloud based
  2. F1-Score — surface coverage at distance threshold
  3. Voxel IoU — volumetric intersection over union
  4. SSIM — structural similarity of rendered images

Usage:
    # Evaluate a single model's outputs against ground truth
    python evaluate_benchmark.py \
        --gt-dir ground_truth/stl \
        --pred-dir results/craft/stl \
        --model-name craft \
        --output-dir evaluation_results

    # Evaluate all models at once
    python evaluate_benchmark.py \
        --gt-dir ground_truth/stl \
        --models craft=results/craft/stl \
                 gpt4o=results/gpt4o/stl \
                 gpt52=results/gpt52/stl \
        --output-dir evaluation_results

    # Evaluate specific prompt IDs only
    python evaluate_benchmark.py \
        --gt-dir ground_truth/stl \
        --pred-dir results/craft/stl \
        --prompt-ids ball_bearing__BB608 washer__M6_washer \
        --output-dir evaluation_results

Requirements:
    pip install numpy trimesh scipy pillow
    Optional: pip install torch (for GPU-accelerated CD)
"""

import os
import sys
import json
import argparse
import time
import logging
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any
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
class MetricResult:
    """Metrics for a single GT↔Pred comparison."""
    prompt_id: str
    model_name: str
    tier: str = ""
    family: str = ""
    # 3D Metrics
    chamfer_distance: float = float('nan')    # Lower is better (normalized)
    f1_score_1pct: float = float('nan')       # F1 @ τ=1% of extent (higher is better)
    f1_score_5pct: float = float('nan')       # F1 @ τ=5% of extent (higher is better)
    precision_1pct: float = float('nan')
    recall_1pct: float = float('nan')
    precision_5pct: float = float('nan')
    recall_5pct: float = float('nan')
    voxel_iou: float = float('nan')           # Higher is better
    # 2D Metrics
    ssim: float = float('nan')                # Higher is better
    silhouette_iou: float = float('nan')      # Higher is better
    # Meta
    gt_stl_exists: bool = False
    pred_stl_exists: bool = False
    gt_png_exists: bool = False
    pred_png_exists: bool = False
    error: str = ""
    compute_time_s: float = 0.0


@dataclass
class ModelSummary:
    """Aggregated metrics for one model across all prompts."""
    model_name: str
    n_evaluated: int = 0
    n_failed: int = 0
    # Mean metrics
    cd_mean: float = float('nan')
    cd_std: float = float('nan')
    cd_median: float = float('nan')
    f1_1pct_mean: float = float('nan')
    f1_5pct_mean: float = float('nan')
    voxel_iou_mean: float = float('nan')
    ssim_mean: float = float('nan')
    silhouette_iou_mean: float = float('nan')
    # Per-tier means
    cd_by_tier: Dict[str, float] = field(default_factory=dict)
    f1_1pct_by_tier: Dict[str, float] = field(default_factory=dict)
    voxel_iou_by_tier: Dict[str, float] = field(default_factory=dict)
    ssim_by_tier: Dict[str, float] = field(default_factory=dict)


# =============================================================================
# POINT CLOUD UTILITIES
# =============================================================================

def normalize_to_unit_cube(points: np.ndarray) -> np.ndarray:
    """
    Center and scale points to fit inside [-0.5, 0.5]^3.
    This makes metrics scale-independent.
    """
    mn = points.min(axis=0)
    mx = points.max(axis=0)
    center = (mn + mx) * 0.5
    scale = (mx - mn).max()
    if scale < 1e-10:
        return points - center
    return (points - center) / scale


def sample_points_from_stl(
    stl_path: str,
    n_points: int = 10000,
    seed: int = 42
) -> Optional[np.ndarray]:
    """
    Load STL and uniformly sample points from its surface.

    Args:
        stl_path: Path to STL file
        n_points: Number of points to sample
        seed: Random seed for reproducibility

    Returns:
        (N, 3) numpy array of sampled points, or None on failure
    """
    import trimesh

    np.random.seed(seed)

    try:
        mesh = trimesh.load(stl_path)

        # Handle scenes (multiple meshes)
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
            # Point cloud only — subsample vertices
            verts = np.asarray(mesh.vertices)
            n = min(n_points, verts.shape[0])
            idx = np.random.choice(verts.shape[0], n, replace=False)
            return verts[idx]

        # Sample from surface
        points, _ = trimesh.sample.sample_surface(mesh, n_points)
        return np.asarray(points)

    except Exception as e:
        logger.warning(f"Failed to load STL {stl_path}: {e}")
        return None


# =============================================================================
# METRIC 1: CHAMFER DISTANCE (normalized)
# =============================================================================

def compute_chamfer_distance(
    pc_gt: np.ndarray,
    pc_pred: np.ndarray,
    normalize: bool = True,
    use_gpu: bool = False
) -> float:
    """
    Compute bidirectional Chamfer Distance.

    CD = 0.5 * (mean(min_dist(gt→pred)) + mean(min_dist(pred→gt)))

    Both point clouds are normalized to unit cube first, so CD is
    scale-independent and comparable across different component sizes.

    Args:
        pc_gt: Ground truth point cloud (N, 3)
        pc_pred: Predicted point cloud (M, 3)
        normalize: Whether to normalize to unit cube
        use_gpu: Whether to use torch GPU acceleration

    Returns:
        Chamfer distance (lower is better, 0 = perfect match)
    """
    if normalize:
        pc_gt = normalize_to_unit_cube(pc_gt.copy())
        pc_pred = normalize_to_unit_cube(pc_pred.copy())

    if use_gpu:
        return _chamfer_gpu(pc_gt, pc_pred)
    else:
        return _chamfer_cpu(pc_gt, pc_pred)


def _chamfer_cpu(pc1: np.ndarray, pc2: np.ndarray) -> float:
    """CPU implementation using scipy KDTree for efficiency."""
    from scipy.spatial import cKDTree

    tree1 = cKDTree(pc1)
    tree2 = cKDTree(pc2)

    # For each point in pc1, find nearest in pc2
    d1_to_2, _ = tree2.query(pc1)
    # For each point in pc2, find nearest in pc1
    d2_to_1, _ = tree1.query(pc2)

    cd = 0.5 * (np.mean(d1_to_2) + np.mean(d2_to_1))
    return float(cd)


def _chamfer_gpu(pc1: np.ndarray, pc2: np.ndarray) -> float:
    """GPU implementation using torch (from friend's code)."""
    try:
        import torch
        device = 'cuda' if torch.cuda.is_available() else 'cpu'

        A = torch.tensor(pc1, device=device, dtype=torch.float32)
        B = torch.tensor(pc2, device=device, dtype=torch.float32)

        # Batched distance computation for memory efficiency
        batch_size = 2048

        # A→B: for each point in A, find min distance to B
        min_dists_ab = torch.zeros(A.size(0), device=device)
        for i in range(0, A.size(0), batch_size):
            end = min(i + batch_size, A.size(0))
            diff = A[i:end].unsqueeze(1) - B.unsqueeze(0)
            dists = torch.sqrt((diff ** 2).sum(2) + 1e-8)
            min_dists_ab[i:end] = dists.min(dim=1)[0]

        # B→A
        min_dists_ba = torch.zeros(B.size(0), device=device)
        for i in range(0, B.size(0), batch_size):
            end = min(i + batch_size, B.size(0))
            diff = B[i:end].unsqueeze(1) - A.unsqueeze(0)
            dists = torch.sqrt((diff ** 2).sum(2) + 1e-8)
            min_dists_ba[i:end] = dists.min(dim=1)[0]

        cd = 0.5 * (min_dists_ab.mean() + min_dists_ba.mean())
        return float(cd.cpu().item())

    except ImportError:
        return _chamfer_cpu(pc1, pc2)


# =============================================================================
# METRIC 2: F1-SCORE (surface coverage at threshold)
# =============================================================================

def compute_f1_score(
    pc_gt: np.ndarray,
    pc_pred: np.ndarray,
    tau_fraction: float = 0.01,
    normalize: bool = True
) -> Tuple[float, float, float]:
    """
    Compute F1-score between two point clouds at distance threshold τ.

    After normalizing to unit cube, τ is expressed as a fraction of the
    object extent (1.0). So tau_fraction=0.01 means "within 1% of extent".

    Precision = fraction of pred points within τ of any GT point
    Recall    = fraction of GT points within τ of any pred point
    F1 = 2 * P * R / (P + R)

    Args:
        pc_gt: Ground truth point cloud (N, 3)
        pc_pred: Predicted point cloud (M, 3)
        tau_fraction: Distance threshold as fraction of extent
        normalize: Whether to normalize to unit cube

    Returns:
        (f1_score, precision, recall) — all in [0, 1], higher is better
    """
    from scipy.spatial import cKDTree

    if normalize:
        pc_gt = normalize_to_unit_cube(pc_gt.copy())
        pc_pred = normalize_to_unit_cube(pc_pred.copy())

    # After normalization, extent is 1.0, so tau = tau_fraction
    tau = tau_fraction

    tree_gt = cKDTree(pc_gt)
    tree_pred = cKDTree(pc_pred)

    # Precision: for each point in pred, is closest GT within tau?
    d_pred_to_gt, _ = tree_gt.query(pc_pred)
    precision = float(np.mean(d_pred_to_gt <= tau))

    # Recall: for each point in gt, is closest pred within tau?
    d_gt_to_pred, _ = tree_pred.query(pc_gt)
    recall = float(np.mean(d_gt_to_pred <= tau))

    if precision + recall < 1e-10:
        return 0.0, 0.0, 0.0

    f1 = 2.0 * precision * recall / (precision + recall)
    return f1, precision, recall


# =============================================================================
# METRIC 3: VOXEL IoU
# =============================================================================

def compute_voxel_iou(
    stl_gt: str,
    stl_pred: str,
    resolution: int = 64
) -> float:
    """
    Compute volumetric IoU by voxelizing both meshes.

    Both meshes are aligned to the same bounding box and voxelized
    at the same resolution.

    Args:
        stl_gt: Path to ground truth STL
        stl_pred: Path to predicted STL
        resolution: Number of voxels along longest axis

    Returns:
        IoU in [0, 1], higher is better
    """
    import trimesh

    def load_mesh(path):
        mesh = trimesh.load(path)
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
        return mesh

    mesh_gt = load_mesh(stl_gt)
    mesh_pred = load_mesh(stl_pred)

    if mesh_gt is None or mesh_pred is None:
        return 0.0

    # Compute combined bounding box for alignment
    all_points = np.vstack([mesh_gt.vertices, mesh_pred.vertices])
    bbox_min = all_points.min(axis=0)
    bbox_max = all_points.max(axis=0)
    extent = (bbox_max - bbox_min).max()

    if extent < 1e-10:
        return 0.0

    # Voxel pitch: extent / resolution
    pitch = extent / resolution

    try:
        vox_gt = mesh_gt.voxelized(pitch)
        vox_pred = mesh_pred.voxelized(pitch)
    except Exception:
        return 0.0

    # Convert to sets of voxel indices in common grid
    def voxel_set(vox, origin, p):
        pts = vox.points  # centers of filled voxels
        indices = np.floor((pts - origin) / p).astype(np.int64)
        return set(map(tuple, indices))

    set_gt = voxel_set(vox_gt, bbox_min, pitch)
    set_pred = voxel_set(vox_pred, bbox_min, pitch)

    if not set_gt and not set_pred:
        return 0.0

    intersection = len(set_gt & set_pred)
    union = len(set_gt | set_pred)

    if union == 0:
        return 0.0

    return float(intersection / union)


# =============================================================================
# METRIC 4: SSIM (image-based)
# =============================================================================

def compute_ssim(
    img_gt_path: str,
    img_pred_path: str,
    window_size: int = 11,
    k1: float = 0.01,
    k2: float = 0.03
) -> float:
    """
    Compute SSIM between two rendered images.

    Uses Gaussian-windowed SSIM as in the original paper (Wang et al. 2004).

    Args:
        img_gt_path: Path to ground truth rendered image
        img_pred_path: Path to predicted rendered image
        window_size: Gaussian window size
        k1, k2: Stability constants

    Returns:
        SSIM in [0, 1], higher is better
    """
    from PIL import Image
    from scipy.ndimage import convolve

    def load_gray(path):
        img = Image.open(path).convert('L')
        return np.array(img, dtype=np.float64) / 255.0

    img1 = load_gray(img_gt_path)
    img2 = load_gray(img_pred_path)

    # Resize if needed
    if img1.shape != img2.shape:
        img2_pil = Image.fromarray((img2 * 255).astype(np.uint8))
        img2_pil = img2_pil.resize((img1.shape[1], img1.shape[0]), Image.LANCZOS)
        img2 = np.array(img2_pil, dtype=np.float64) / 255.0

    L = 1.0
    c1 = (k1 * L) ** 2
    c2 = (k2 * L) ** 2

    # Gaussian window
    coords = np.arange(window_size) - window_size // 2
    g = np.exp(-(coords ** 2) / (2 * 1.5 ** 2))
    window = np.outer(g, g)
    window /= window.sum()

    mu1 = convolve(img1, window, mode='reflect')
    mu2 = convolve(img2, window, mode='reflect')

    mu1_sq = mu1 ** 2
    mu2_sq = mu2 ** 2
    mu1_mu2 = mu1 * mu2

    sigma1_sq = convolve(img1 ** 2, window, mode='reflect') - mu1_sq
    sigma2_sq = convolve(img2 ** 2, window, mode='reflect') - mu2_sq
    sigma12 = convolve(img1 * img2, window, mode='reflect') - mu1_mu2

    num = (2 * mu1_mu2 + c1) * (2 * sigma12 + c2)
    den = (mu1_sq + mu2_sq + c1) * (sigma1_sq + sigma2_sq + c2)

    ssim_map = num / (den + 1e-10)
    return float(np.mean(ssim_map))


def compute_silhouette_iou(
    img_gt_path: str,
    img_pred_path: str,
    threshold: float = 0.5
) -> float:
    """
    Compute IoU of binary silhouettes from rendered images.

    Args:
        img_gt_path: Path to ground truth rendered image
        img_pred_path: Path to predicted rendered image
        threshold: Binarization threshold

    Returns:
        IoU in [0, 1], higher is better
    """
    from PIL import Image

    def load_silhouette(path):
        img = Image.open(path).convert('L')
        arr = np.array(img, dtype=np.float64) / 255.0
        return (arr > threshold).astype(np.float64)

    sil1 = load_silhouette(img_gt_path)
    sil2 = load_silhouette(img_pred_path)

    # Resize if needed
    if sil1.shape != sil2.shape:
        img2 = Image.open(img_pred_path).convert('L')
        img2 = img2.resize((sil1.shape[1], sil1.shape[0]), Image.LANCZOS)
        sil2 = (np.array(img2, dtype=np.float64) / 255.0 > threshold).astype(np.float64)

    intersection = np.sum(sil1 * sil2)
    union = np.sum(np.maximum(sil1, sil2))

    if union < 1e-10:
        return 0.0

    return float(intersection / union)


# =============================================================================
# EVALUATION ORCHESTRATOR
# =============================================================================

def evaluate_single(
    gt_stl_path: str,
    pred_stl_path: str,
    prompt_id: str,
    model_name: str,
    gt_png_path: str = None,
    pred_png_path: str = None,
    tier: str = "",
    family: str = "",
    n_points: int = 10000,
    use_gpu: bool = False
) -> MetricResult:
    """
    Evaluate a single GT↔Pred pair across all 4 metrics.

    Args:
        gt_stl_path: Path to ground truth STL
        pred_stl_path: Path to predicted STL
        prompt_id: Component ID
        model_name: Name of the model being evaluated
        gt_png_path: Optional path to GT rendered image (for SSIM)
        pred_png_path: Optional path to predicted rendered image (for SSIM)
        tier: Complexity tier (Simple/Medium/Complex)
        family: Component family
        n_points: Points to sample for CD and F1
        use_gpu: Whether to use GPU for CD

    Returns:
        MetricResult with all metrics
    """
    t0 = time.time()
    result = MetricResult(
        prompt_id=prompt_id,
        model_name=model_name,
        tier=tier,
        family=family
    )

    # Check file existence
    result.gt_stl_exists = os.path.exists(gt_stl_path)
    result.pred_stl_exists = os.path.exists(pred_stl_path)
    result.gt_png_exists = gt_png_path is not None and os.path.exists(gt_png_path)
    result.pred_png_exists = pred_png_path is not None and os.path.exists(pred_png_path)

    if not result.gt_stl_exists:
        result.error = f"GT STL not found: {gt_stl_path}"
        return result

    if not result.pred_stl_exists:
        result.error = f"Pred STL not found: {pred_stl_path}"
        return result

    try:
        # Sample point clouds
        pc_gt = sample_points_from_stl(gt_stl_path, n_points, seed=42)
        pc_pred = sample_points_from_stl(pred_stl_path, n_points, seed=43)

        if pc_gt is None or pc_pred is None:
            result.error = "Failed to sample points from STL"
            return result

        # Metric 1: Chamfer Distance
        result.chamfer_distance = compute_chamfer_distance(
            pc_gt, pc_pred, normalize=True, use_gpu=use_gpu
        )

        # Metric 2: F1-Score at two thresholds
        f1_1, p_1, r_1 = compute_f1_score(pc_gt, pc_pred, tau_fraction=0.01)
        f1_5, p_5, r_5 = compute_f1_score(pc_gt, pc_pred, tau_fraction=0.05)
        result.f1_score_1pct = f1_1
        result.precision_1pct = p_1
        result.recall_1pct = r_1
        result.f1_score_5pct = f1_5
        result.precision_5pct = p_5
        result.recall_5pct = r_5

        # Metric 3: Voxel IoU
        result.voxel_iou = compute_voxel_iou(gt_stl_path, pred_stl_path)

    except Exception as e:
        result.error = f"3D metrics error: {e}"
        logger.warning(f"  3D metrics failed for {prompt_id}: {e}")

    # Metric 4: SSIM (if images available)
    try:
        if result.gt_png_exists and result.pred_png_exists:
            result.ssim = compute_ssim(gt_png_path, pred_png_path)
            result.silhouette_iou = compute_silhouette_iou(gt_png_path, pred_png_path)
    except Exception as e:
        logger.warning(f"  Image metrics failed for {prompt_id}: {e}")

    result.compute_time_s = time.time() - t0
    return result


def evaluate_model(
    gt_dir: str,
    pred_dir: str,
    model_name: str,
    benchmark_json: str = None,
    prompt_ids: List[str] = None,
    gt_png_dir: str = None,
    pred_png_dir: str = None,
    n_points: int = 10000,
    use_gpu: bool = False
) -> Tuple[List[MetricResult], ModelSummary]:
    """
    Evaluate all prompts for a model.

    Args:
        gt_dir: Directory containing ground truth STLs
        pred_dir: Directory containing predicted STLs
        model_name: Name of the model
        benchmark_json: Path to benchmark_ground_truth.json (for tier/family info)
        prompt_ids: Optional list of specific prompt IDs to evaluate
        gt_png_dir: Optional directory for GT images
        pred_png_dir: Optional directory for predicted images
        n_points: Points to sample
        use_gpu: Whether to use GPU

    Returns:
        (list of MetricResult, ModelSummary)
    """
    # Load benchmark metadata if available
    comp_meta = {}
    if benchmark_json and os.path.exists(benchmark_json):
        with open(benchmark_json) as f:
            data = json.load(f)
        for comp in data.get("components", []):
            comp_meta[comp["id"]] = {
                "tier": comp.get("tier", ""),
                "family": comp.get("component_family", ""),
                "prompt": comp.get("prompt", ""),
            }

    # Discover prompt IDs from GT directory
    if prompt_ids is None:
        gt_stls = sorted(Path(gt_dir).glob("*.stl"))
        prompt_ids = [p.stem for p in gt_stls]

    logger.info(f"Evaluating model '{model_name}': {len(prompt_ids)} prompts")

    results = []
    for i, pid in enumerate(prompt_ids):
        gt_stl = os.path.join(gt_dir, f"{pid}.stl")
        pred_stl = os.path.join(pred_dir, f"{pid}.stl")

        gt_png = os.path.join(gt_png_dir, f"{pid}.png") if gt_png_dir else None
        pred_png = os.path.join(pred_png_dir, f"{pid}.png") if pred_png_dir else None

        meta = comp_meta.get(pid, {})

        logger.info(f"  [{i+1}/{len(prompt_ids)}] {pid}")

        result = evaluate_single(
            gt_stl_path=gt_stl,
            pred_stl_path=pred_stl,
            prompt_id=pid,
            model_name=model_name,
            gt_png_path=gt_png,
            pred_png_path=pred_png,
            tier=meta.get("tier", ""),
            family=meta.get("family", ""),
            n_points=n_points,
            use_gpu=use_gpu
        )

        results.append(result)

        if result.error:
            logger.warning(f"    ERROR: {result.error}")
        else:
            logger.info(
                f"    CD={result.chamfer_distance:.6f}  "
                f"F1@1%={result.f1_score_1pct:.4f}  "
                f"F1@5%={result.f1_score_5pct:.4f}  "
                f"VoxIoU={result.voxel_iou:.4f}  "
                f"SSIM={result.ssim:.4f}  "
                f"({result.compute_time_s:.1f}s)"
            )

    # Compute summary
    summary = _compute_summary(results, model_name)
    return results, summary


def _compute_summary(results: List[MetricResult], model_name: str) -> ModelSummary:
    """Compute aggregated summary from individual results."""
    summary = ModelSummary(model_name=model_name)

    valid = [r for r in results if not r.error]
    summary.n_evaluated = len(valid)
    summary.n_failed = len(results) - len(valid)

    if not valid:
        return summary

    # Overall means
    cds = [r.chamfer_distance for r in valid if np.isfinite(r.chamfer_distance)]
    f1_1s = [r.f1_score_1pct for r in valid if np.isfinite(r.f1_score_1pct)]
    f1_5s = [r.f1_score_5pct for r in valid if np.isfinite(r.f1_score_5pct)]
    vious = [r.voxel_iou for r in valid if np.isfinite(r.voxel_iou)]
    ssims = [r.ssim for r in valid if np.isfinite(r.ssim)]
    sil_ious = [r.silhouette_iou for r in valid if np.isfinite(r.silhouette_iou)]

    if cds:
        summary.cd_mean = float(np.mean(cds))
        summary.cd_std = float(np.std(cds))
        summary.cd_median = float(np.median(cds))
    if f1_1s:
        summary.f1_1pct_mean = float(np.mean(f1_1s))
    if f1_5s:
        summary.f1_5pct_mean = float(np.mean(f1_5s))
    if vious:
        summary.voxel_iou_mean = float(np.mean(vious))
    if ssims:
        summary.ssim_mean = float(np.mean(ssims))
    if sil_ious:
        summary.silhouette_iou_mean = float(np.mean(sil_ious))

    # Per-tier means
    for tier in ["Simple", "Medium", "Complex"]:
        tier_results = [r for r in valid if r.tier == tier]
        if not tier_results:
            continue

        tier_cds = [r.chamfer_distance for r in tier_results if np.isfinite(r.chamfer_distance)]
        tier_f1s = [r.f1_score_1pct for r in tier_results if np.isfinite(r.f1_score_1pct)]
        tier_vious = [r.voxel_iou for r in tier_results if np.isfinite(r.voxel_iou)]
        tier_ssims = [r.ssim for r in tier_results if np.isfinite(r.ssim)]

        if tier_cds:
            summary.cd_by_tier[tier] = float(np.mean(tier_cds))
        if tier_f1s:
            summary.f1_1pct_by_tier[tier] = float(np.mean(tier_f1s))
        if tier_vious:
            summary.voxel_iou_by_tier[tier] = float(np.mean(tier_vious))
        if tier_ssims:
            summary.ssim_by_tier[tier] = float(np.mean(tier_ssims))

    return summary


# =============================================================================
# OUTPUT FORMATTERS
# =============================================================================

def save_results(
    all_results: Dict[str, List[MetricResult]],
    all_summaries: Dict[str, ModelSummary],
    output_dir: str
):
    """Save evaluation results to JSON and markdown."""
    out_path = Path(output_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Save detailed results as JSON
    detailed = {}
    for model_name, results in all_results.items():
        detailed[model_name] = [asdict(r) for r in results]

    with open(out_path / "detailed_results.json", 'w') as f:
        json.dump(detailed, f, indent=2, default=str)

    # Save summaries as JSON
    summaries = {name: asdict(s) for name, s in all_summaries.items()}
    with open(out_path / "summaries.json", 'w') as f:
        json.dump(summaries, f, indent=2, default=str)

    # Generate comparison markdown table
    _generate_markdown_table(all_summaries, all_results, out_path)

    logger.info(f"Results saved to {out_path}")


def _generate_markdown_table(
    summaries: Dict[str, ModelSummary],
    all_results: Dict[str, List[MetricResult]],
    out_path: Path
):
    """Generate markdown comparison table for the paper."""
    lines = []
    models = sorted(summaries.keys())

    lines.append("# Text2CAD Benchmark Evaluation Results")
    lines.append(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

    # Main comparison table
    lines.append("## Overall Comparison\n")
    header = "| Metric |"
    sep = "|--------|"
    for m in models:
        header += f" {m} |"
        sep += "------|"
    lines.append(header)
    lines.append(sep)

    # Rows
    def fmt(val, lower_better=False):
        if np.isnan(val):
            return "N/A"
        return f"{val:.4f}"

    rows = [
        ("CD ↓", lambda s: s.cd_mean, True),
        ("CD (std)", lambda s: s.cd_std, True),
        ("CD (median)", lambda s: s.cd_median, True),
        ("F1@1% ↑", lambda s: s.f1_1pct_mean, False),
        ("F1@5% ↑", lambda s: s.f1_5pct_mean, False),
        ("Voxel IoU ↑", lambda s: s.voxel_iou_mean, False),
        ("SSIM ↑", lambda s: s.ssim_mean, False),
        ("Silhouette IoU ↑", lambda s: s.silhouette_iou_mean, False),
        ("Evaluated", lambda s: float(s.n_evaluated), False),
        ("Failed", lambda s: float(s.n_failed), True),
    ]

    for label, getter, lower_better in rows:
        row = f"| {label} |"
        values = {}
        for m in models:
            val = getter(summaries[m])
            values[m] = val
            row += f" {fmt(val)} |"
        lines.append(row)

    # Per-tier table
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

        tier_rows = [
            ("CD ↓", lambda s, t=tier: s.cd_by_tier.get(t, float('nan'))),
            ("F1@1% ↑", lambda s, t=tier: s.f1_1pct_by_tier.get(t, float('nan'))),
            ("Voxel IoU ↑", lambda s, t=tier: s.voxel_iou_by_tier.get(t, float('nan'))),
            ("SSIM ↑", lambda s, t=tier: s.ssim_by_tier.get(t, float('nan'))),
        ]

        for label, getter in tier_rows:
            row = f"| {label} |"
            for m in models:
                val = getter(summaries[m])
                row += f" {fmt(val)} |"
            lines.append(row)

    # Per-prompt detail table (for paper appendix)
    lines.append("\n## Per-Prompt Results\n")
    header = "| Prompt ID | Tier | Family |"
    sep = "|-----------|------|--------|"
    for m in models:
        header += f" CD ({m}) | F1@5% ({m}) | VoxIoU ({m}) |"
        sep += "------|-------|--------|"
    lines.append(header)
    lines.append(sep)

    # Get all prompt IDs (from first model)
    first_model = models[0] if models else None
    if first_model and first_model in all_results:
        for r in all_results[first_model]:
            row = f"| {r.prompt_id} | {r.tier} | {r.family} |"
            for m in models:
                m_results = {mr.prompt_id: mr for mr in all_results.get(m, [])}
                mr = m_results.get(r.prompt_id)
                if mr and not mr.error:
                    row += f" {fmt(mr.chamfer_distance)} | {fmt(mr.f1_score_5pct)} | {fmt(mr.voxel_iou)} |"
                else:
                    row += " N/A | N/A | N/A |"
            lines.append(row)

    md_path = out_path / "comparison_table.md"
    with open(md_path, 'w') as f:
        f.write("\n".join(lines))

    logger.info(f"Comparison table saved to {md_path}")


def print_summary(summaries: Dict[str, ModelSummary]):
    """Print a compact summary to console."""
    models = sorted(summaries.keys())

    print(f"\n{'='*80}")
    print("EVALUATION SUMMARY")
    print(f"{'='*80}")

    # Header
    header = f"{'Metric':<20}"
    for m in models:
        header += f" {m:>12}"
    print(header)
    print("-" * len(header))

    def row(label, getter, fmt_str="{:>12.4f}"):
        line = f"{label:<20}"
        for m in models:
            val = getter(summaries[m])
            if np.isnan(val):
                line += f" {'N/A':>12}"
            else:
                line += fmt_str.format(val)
        print(line)

    row("CD ↓", lambda s: s.cd_mean)
    row("CD (median)", lambda s: s.cd_median)
    row("F1@1% ↑", lambda s: s.f1_1pct_mean)
    row("F1@5% ↑", lambda s: s.f1_5pct_mean)
    row("Voxel IoU ↑", lambda s: s.voxel_iou_mean)
    row("SSIM ↑", lambda s: s.ssim_mean)
    row("Sil. IoU ↑", lambda s: s.silhouette_iou_mean)
    row("Evaluated", lambda s: float(s.n_evaluated), "{:>12.0f}")
    row("Failed", lambda s: float(s.n_failed), "{:>12.0f}")

    # Per-tier breakdown
    for tier in ["Simple", "Medium", "Complex"]:
        print(f"\n  {tier}:")
        row(f"  CD ↓", lambda s, t=tier: s.cd_by_tier.get(t, float('nan')))
        row(f"  F1@1% ↑", lambda s, t=tier: s.f1_1pct_by_tier.get(t, float('nan')))
        row(f"  VoxIoU ↑", lambda s, t=tier: s.voxel_iou_by_tier.get(t, float('nan')))

    print(f"\n{'='*80}")


# =============================================================================
# CLI
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Text2CAD Benchmark Evaluation — 4 Metrics",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Single model
  python evaluate_benchmark.py --gt-dir ground_truth/stl --pred-dir results/craft/stl --model-name craft

  # Multiple models
  python evaluate_benchmark.py --gt-dir ground_truth/stl \\
    --models craft=results/craft/stl gpt4o=results/gpt4o/stl gpt52=results/gpt52/stl

  # With images for SSIM
  python evaluate_benchmark.py --gt-dir ground_truth/stl --pred-dir results/craft/stl \\
    --gt-png-dir ground_truth/png --pred-png-dir results/craft/png
        """
    )

    parser.add_argument("--gt-dir", type=str, required=True,
                        help="Directory containing ground truth STLs")
    parser.add_argument("--pred-dir", type=str, default=None,
                        help="Directory containing predicted STLs (for single model)")
    parser.add_argument("--model-name", type=str, default="model",
                        help="Name of the model (for single model)")
    parser.add_argument("--models", nargs="+", default=None,
                        help="Multiple models as name=dir pairs (e.g., craft=results/craft/stl)")
    parser.add_argument("--benchmark-json", type=str,
                        default=str(SCRIPT_DIR / "benchmark_ground_truth.json"),
                        help="Path to benchmark_ground_truth.json")
    parser.add_argument("--prompt-ids", nargs="+", default=None,
                        help="Specific prompt IDs to evaluate")
    parser.add_argument("--gt-png-dir", type=str, default=None,
                        help="Directory containing GT rendered images")
    parser.add_argument("--pred-png-dir", type=str, default=None,
                        help="Directory containing predicted rendered images")
    parser.add_argument("--output-dir", type=str,
                        default=str(SCRIPT_DIR / "evaluation_results"),
                        help="Output directory for results")
    parser.add_argument("--n-points", type=int, default=10000,
                        help="Number of points to sample for CD and F1")
    parser.add_argument("--gpu", action="store_true",
                        help="Use GPU for Chamfer Distance computation")

    args = parser.parse_args()

    # Build model configurations
    model_configs = {}

    if args.models:
        for model_spec in args.models:
            name, pred_dir = model_spec.split("=", 1)
            model_configs[name] = {
                "pred_dir": pred_dir,
                "pred_png_dir": None  # Can be extended
            }
    elif args.pred_dir:
        model_configs[args.model_name] = {
            "pred_dir": args.pred_dir,
            "pred_png_dir": args.pred_png_dir
        }
    else:
        parser.error("Must specify either --pred-dir or --models")

    # Run evaluation
    all_results = {}
    all_summaries = {}

    for model_name, config in model_configs.items():
        print(f"\n{'='*60}")
        print(f"Evaluating: {model_name}")
        print(f"{'='*60}")

        results, summary = evaluate_model(
            gt_dir=args.gt_dir,
            pred_dir=config["pred_dir"],
            model_name=model_name,
            benchmark_json=args.benchmark_json,
            prompt_ids=args.prompt_ids,
            gt_png_dir=args.gt_png_dir,
            pred_png_dir=config.get("pred_png_dir"),
            n_points=args.n_points,
            use_gpu=args.gpu
        )

        all_results[model_name] = results
        all_summaries[model_name] = summary

    # Save results
    save_results(all_results, all_summaries, args.output_dir)

    # Print summary
    print_summary(all_summaries)


if __name__ == "__main__":
    main()
