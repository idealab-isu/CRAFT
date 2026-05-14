"""Voxel-IoU @ 64^3 with 24-cube-rotation alignment.

Replicates Zero-to-CAD's primary evaluation metric:

    1. Normalize each STL: center at centroid, scale so longest axis = 1.0.
    2. Voxelize into a 64x64x64 boolean grid spanning [-0.5, 0.5]^3.
    3. For each of the 24 proper rotations of the cube (the orientation-
       preserving symmetries of the cube), rotate the prediction's voxel
       grid by axis permutation + sign flip and compute IoU vs. GT.
    4. Report the maximum IoU across all 24 rotations.

This matches Z2C's wording: *"we rotate the generated shape in increments of
45 degrees and report the maximum IoU."* "45-degree increments" on three
orthogonal axes equals the 24-element rotation group of the cube.

Trade-offs to be aware of (full discussion in
CRAFT_zerotocad_eval_plan.md §5):

  - Coarse alignment: a shape mis-rotated by 22.5 deg gets penalized
    for that misalignment alone. CD (with ICP) is finer-grained.
  - Resolution-bound: chamfers narrower than ~0.016 normalized units
    vanish into the grid.
  - Saturates near ~0.95 even for visually-perfect reconstructions due
    to voxelization edge effects.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

import numpy as np

logger = logging.getLogger(__name__)

DEFAULT_RESOLUTION = 64


# ---------------------------------------------------------------------------
# Voxelization
# ---------------------------------------------------------------------------


def voxelize_normalized(mesh, resolution: int = DEFAULT_RESOLUTION) -> np.ndarray:
    """Center mesh in [-0.5, 0.5]^3 and voxelize into a (R, R, R) bool array.

    The mesh is translated so that its bounding-box centroid is at the origin,
    then scaled so the longest extent equals 1.0. We then evaluate
    `mesh.contains()` on a regular grid of voxel centers, which is robust to
    non-watertight meshes when ray-casting is consistent (and is exactly
    Z2C's voxelization protocol).

    Args:
        mesh:        trimesh.Trimesh
        resolution:  number of voxels per axis (default 64).

    Returns:
        boolean numpy array of shape (resolution, resolution, resolution).
    """
    import trimesh  # local import so the module loads without trimesh

    m = mesh.copy()
    bb_center = m.bounds.mean(axis=0)
    m.apply_translation(-bb_center)
    extent = m.extents.max()
    if extent <= 0 or not np.isfinite(extent):
        return np.zeros((resolution, resolution, resolution), dtype=bool)
    m.apply_scale(1.0 / extent)

    # Voxel-center coordinates in [-0.5 + 0.5/R, +0.5 - 0.5/R]
    coords = (np.arange(resolution, dtype=np.float64) + 0.5) / resolution - 0.5
    gx, gy, gz = np.meshgrid(coords, coords, coords, indexing="ij")
    points = np.column_stack([gx.ravel(), gy.ravel(), gz.ravel()])

    try:
        inside = m.contains(points)
    except Exception as e:
        logger.warning("mesh.contains() failed (%s); falling back to voxelized().fill()", e)
        try:
            pitch = 1.0 / resolution
            vg = m.voxelized(pitch=pitch).fill()
            inside = vg.is_filled(points)
        except Exception as e2:
            logger.error("Voxelization fallback also failed: %s", e2)
            return np.zeros((resolution, resolution, resolution), dtype=bool)

    return np.asarray(inside, dtype=bool).reshape(resolution, resolution, resolution)


# ---------------------------------------------------------------------------
# 24 proper cube rotations as numpy array transforms
# ---------------------------------------------------------------------------


def _all_24_cube_rotations(arr: np.ndarray):
    """Yield all 24 proper rotations of a 3D array (axis permutations + sign flips).

    Construction: 6 ways to point the "+z" axis (forward, backward, +x, -x, +y, -y)
    times 4 in-plane rotations about z. Yields the same 24 rotations as the
    cube's orientation-preserving symmetry group.
    """
    face_orientations = [
        arr,                                       # +z up   (identity)
        np.rot90(arr, 2, axes=(0, 2)),             # -z up   (180 about y)
        np.rot90(arr, 1, axes=(0, 2)),             # +x up
        np.rot90(arr, -1, axes=(0, 2)),            # -x up
        np.rot90(arr, 1, axes=(1, 2)),             # +y up
        np.rot90(arr, -1, axes=(1, 2)),            # -y up
    ]
    for orient in face_orientations:
        cur = orient
        for _ in range(4):
            yield cur
            cur = np.rot90(cur, 1, axes=(0, 1))


def iou_with_rotation_alignment(
    pred_voxels: np.ndarray,
    gt_voxels: np.ndarray,
) -> float:
    """Maximum IoU over the 24 proper cube rotations of `pred_voxels`."""
    if pred_voxels.shape != gt_voxels.shape:
        raise ValueError(
            f"Voxel grid shape mismatch: pred={pred_voxels.shape} gt={gt_voxels.shape}"
        )
    gt_bool = gt_voxels.astype(bool)
    best = 0.0
    for rot in _all_24_cube_rotations(pred_voxels.astype(bool)):
        intersection = np.logical_and(rot, gt_bool).sum()
        union = np.logical_or(rot, gt_bool).sum()
        if union == 0:
            continue
        iou = float(intersection) / float(union)
        if iou > best:
            best = iou
    return best


# ---------------------------------------------------------------------------
# Convenience wrappers — STL paths in, IoU out
# ---------------------------------------------------------------------------


@dataclass
class VoxelIoUResult:
    iou: float
    pred_voxel_count: int
    gt_voxel_count: int
    resolution: int


def score_stl_pair(
    pred_stl: str | Path,
    gt_stl: str | Path,
    resolution: int = DEFAULT_RESOLUTION,
) -> Optional[VoxelIoUResult]:
    """Voxel IoU for a (prediction, ground-truth) STL pair.

    Returns None if either mesh fails to load. Caller is responsible for
    counting load failures as Success=0, IoU=0 per the plan §12.
    """
    import trimesh

    def _load(p):
        try:
            m = trimesh.load(str(p), force="mesh")
        except Exception as e:
            logger.warning("Failed to load %s: %s", p, e)
            return None
        if isinstance(m, trimesh.Scene):
            geoms = [g for g in m.geometry.values() if isinstance(g, trimesh.Trimesh)]
            if not geoms:
                return None
            m = trimesh.util.concatenate(geoms)
        if not isinstance(m, trimesh.Trimesh) or len(m.faces) == 0:
            return None
        return m

    pred = _load(pred_stl)
    gt = _load(gt_stl)
    if pred is None or gt is None:
        return None

    pv = voxelize_normalized(pred, resolution=resolution)
    gv = voxelize_normalized(gt, resolution=resolution)
    iou = iou_with_rotation_alignment(pv, gv)
    return VoxelIoUResult(
        iou=iou,
        pred_voxel_count=int(pv.sum()),
        gt_voxel_count=int(gv.sum()),
        resolution=resolution,
    )


def score_stl_pair_safe(
    pred_stl: str | Path,
    gt_stl: str | Path,
    resolution: int = DEFAULT_RESOLUTION,
) -> VoxelIoUResult:
    """Like score_stl_pair, but never returns None — load/score failures
    yield iou=0.0 (matching the plan's failure handling policy)."""
    res = score_stl_pair(pred_stl, gt_stl, resolution=resolution)
    if res is None:
        return VoxelIoUResult(
            iou=0.0, pred_voxel_count=0, gt_voxel_count=0, resolution=resolution
        )
    return res
