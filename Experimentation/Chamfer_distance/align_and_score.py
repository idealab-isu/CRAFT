"""
Alignment + Chamfer Distance for CAD mesh comparison.

Pipeline (applied independently to prediction and ground-truth):
    1. Load STL, combine scenes, sample N points uniformly from surface
    2. Center at centroid + scale to unit bounding-sphere (scale-invariant)
    3. PCA canonicalization (rotate so principal axes align with x,y,z)
    4. Try 24 proper rotations of the cube as ICP initializations on the
       PCA-aligned prediction (handles PCA sign ambiguity + near-symmetric
       shapes where principal axes are not well-defined)
    5. Refine each initialization with ICP
    6. Return the minimum bidirectional Chamfer distance across all starts

Why these choices:
    - Unit-sphere scaling (not unit cube) is rotation-invariant; a unit-cube
      normalization changes after rotation and would contaminate alignment.
    - PCA + 24 rotations covers the "block stood up vs laid down" case you
      described, plus all axis-swaps / sign flips that a generator may output.
    - ICP refines for small non-axis-aligned tilts.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from itertools import permutations, product
from pathlib import Path
from typing import List, Optional, Tuple

import numpy as np
import trimesh
from scipy.spatial import cKDTree

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Mesh loading + sampling
# ---------------------------------------------------------------------------

def load_mesh(stl_path: str | Path) -> Optional[trimesh.Trimesh]:
    """Load an STL; flatten scenes into a single Trimesh."""
    try:
        mesh = trimesh.load(str(stl_path), force="mesh")
    except Exception as exc:
        logger.warning("Failed to load %s: %s", stl_path, exc)
        return None

    if isinstance(mesh, trimesh.Scene):
        geoms = [g for g in mesh.geometry.values() if isinstance(g, trimesh.Trimesh)]
        if not geoms:
            return None
        mesh = trimesh.util.concatenate(geoms)

    if not isinstance(mesh, trimesh.Trimesh) or len(mesh.faces) == 0:
        return None
    return mesh


def sample_surface(mesh: trimesh.Trimesh, n_points: int, seed: int = 42) -> np.ndarray:
    """Uniformly sample N points from the mesh surface (area-weighted)."""
    rng = np.random.default_rng(seed)
    # trimesh.sample.sample_surface uses the numpy legacy RandomState; seed it
    # manually for reproducibility.
    np.random.seed(seed)
    points, _ = trimesh.sample.sample_surface(mesh, n_points)
    return np.asarray(points, dtype=np.float64)


def load_and_sample(stl_path: str | Path, n_points: int = 10_000, seed: int = 42) -> Optional[np.ndarray]:
    mesh = load_mesh(stl_path)
    if mesh is None:
        return None
    return sample_surface(mesh, n_points, seed=seed)


# ---------------------------------------------------------------------------
# Normalization: centroid + unit bounding-sphere (rotation-invariant)
# ---------------------------------------------------------------------------

def normalize_unit_sphere(points: np.ndarray) -> np.ndarray:
    """Center at centroid and scale so max distance from origin = 1."""
    centered = points - points.mean(axis=0, keepdims=True)
    radius = np.linalg.norm(centered, axis=1).max()
    if radius < 1e-10:
        return centered
    return centered / radius


# ---------------------------------------------------------------------------
# PCA canonicalization
# ---------------------------------------------------------------------------

def pca_canonicalize(points: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Rotate points so the principal axes (descending variance) coincide with
    world x, y, z.

    Returns
    -------
    rotated : (N, 3) point cloud in canonical pose
    R       : (3, 3) rotation matrix such that rotated = points @ R.T
    """
    centered = points - points.mean(axis=0, keepdims=True)
    cov = (centered.T @ centered) / max(1, centered.shape[0] - 1)

    eigvals, eigvecs = np.linalg.eigh(cov)
    # eigh returns ascending; flip to descending so axis-0 = largest variance
    order = np.argsort(eigvals)[::-1]
    R = eigvecs[:, order].T  # rows are principal directions

    # Ensure a proper rotation (det = +1) so we never mirror the object
    if np.linalg.det(R) < 0:
        R[-1, :] *= -1

    rotated = centered @ R.T
    return rotated, R


# ---------------------------------------------------------------------------
# 24 proper rotations of the cube (axis swaps + sign flips with det = +1)
# ---------------------------------------------------------------------------

def cube_rotation_group() -> List[np.ndarray]:
    """Return the 24 proper rotation matrices mapping cube to itself."""
    rotations: List[np.ndarray] = []
    for perm in permutations(range(3)):
        for signs in product((1, -1), repeat=3):
            R = np.zeros((3, 3))
            for i, p in enumerate(perm):
                R[i, p] = signs[i]
            if np.isclose(np.linalg.det(R), 1.0):
                rotations.append(R)
    assert len(rotations) == 24
    return rotations


# ---------------------------------------------------------------------------
# Chamfer distance + ICP
# ---------------------------------------------------------------------------

def chamfer_distance(pc_a: np.ndarray, pc_b: np.ndarray) -> float:
    """Bidirectional Chamfer: 0.5 * (mean d(a->b) + mean d(b->a))."""
    tree_a = cKDTree(pc_a)
    tree_b = cKDTree(pc_b)
    d_ab, _ = tree_b.query(pc_a)
    d_ba, _ = tree_a.query(pc_b)
    return 0.5 * (float(d_ab.mean()) + float(d_ba.mean()))


def icp_refine(
    source: np.ndarray,
    target: np.ndarray,
    initial: Optional[np.ndarray] = None,
    max_iterations: int = 30,
) -> Tuple[np.ndarray, float]:
    """
    Run ICP to align `source` onto `target`.

    Parameters
    ----------
    source, target : (N, 3) / (M, 3) point clouds
    initial        : optional 4x4 homogeneous initial transform

    Returns
    -------
    aligned : (N, 3) source points after transformation
    cost    : final ICP cost (mean nearest-neighbour distance)
    """
    try:
        matrix, transformed, cost = trimesh.registration.icp(
            source,
            target,
            initial=initial if initial is not None else np.eye(4),
            max_iterations=max_iterations,
            reflection=False,
            scale=False,
        )
        return np.asarray(transformed), float(cost)
    except Exception as exc:
        logger.debug("ICP failed (%s); returning unrefined source.", exc)
        return source, float("inf")


# ---------------------------------------------------------------------------
# Main alignment-aware CD
# ---------------------------------------------------------------------------

@dataclass
class AlignmentResult:
    chamfer: float              # lower is better; computed after alignment
    chamfer_raw: float          # CD before any alignment (for reference)
    best_init_index: int        # which of the 24 rotations won
    n_points_pred: int
    n_points_gt: int


def align_and_score(
    pc_pred: np.ndarray,
    pc_gt: np.ndarray,
    use_icp: bool = True,
) -> AlignmentResult:
    """
    Compute Chamfer distance between pred and GT point clouds with full
    alignment (normalize -> PCA -> 24 rotations -> ICP refine -> min CD).

    Both inputs should be (N, 3) arrays (already surface-sampled).
    """
    raw_cd = chamfer_distance(pc_pred, pc_gt)

    # Step 1: normalize (translation + scale)
    pred_n = normalize_unit_sphere(pc_pred)
    gt_n = normalize_unit_sphere(pc_gt)

    # Step 2: PCA canonicalize both
    pred_pca, _ = pca_canonicalize(pred_n)
    gt_pca, _ = pca_canonicalize(gt_n)

    # Step 3+4: try 24 rotations on pred, ICP refine, keep min CD
    best_cd = float("inf")
    best_idx = -1
    for i, R in enumerate(cube_rotation_group()):
        pred_rot = pred_pca @ R.T

        if use_icp:
            T_init = np.eye(4)
            # no translation init — both clouds already centered
            aligned, _ = icp_refine(pred_rot, gt_pca, initial=T_init)
            cd = chamfer_distance(aligned, gt_pca)
        else:
            cd = chamfer_distance(pred_rot, gt_pca)

        if cd < best_cd:
            best_cd = cd
            best_idx = i

    return AlignmentResult(
        chamfer=best_cd,
        chamfer_raw=raw_cd,
        best_init_index=best_idx,
        n_points_pred=pc_pred.shape[0],
        n_points_gt=pc_gt.shape[0],
    )


def score_stl_pair(
    pred_stl: str | Path,
    gt_stl: str | Path,
    n_points: int = 10_000,
    seed: int = 42,
    use_icp: bool = True,
) -> Optional[AlignmentResult]:
    """Convenience wrapper: load two STLs, sample, align, score."""
    pc_pred = load_and_sample(pred_stl, n_points=n_points, seed=seed)
    pc_gt = load_and_sample(gt_stl, n_points=n_points, seed=seed)
    if pc_pred is None or pc_gt is None:
        return None
    return align_and_score(pc_pred, pc_gt, use_icp=use_icp)
