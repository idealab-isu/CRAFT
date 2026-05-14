"""Success Rate — mirrors Zero-to-CAD's binary success criterion.

From their paper: *"percentage of generations that produce valid, executable
code."* For our harness we also require:

  - the output STL exists,
  - the mesh has at least one face,
  - the voxelized volume is non-trivial (> 1 voxel) at 64^3.

The "trivial cube returns 100%" pathology mentioned in their paper still
applies; this metric is reported as a coarse floor, not the headline.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Optional


@dataclass
class SuccessRateResult:
    success: bool
    reason: str             # human-readable failure reason or "ok"
    has_code: bool
    has_stl: bool
    n_faces: int
    voxel_count: int        # at 64^3, after normalization


def success_rate_for_sample(
    code_path: Optional[str | Path],
    stl_path: Optional[str | Path],
    min_voxels: int = 1,
) -> SuccessRateResult:
    """Evaluate Success on one sample given its output code + STL paths."""
    has_code = bool(code_path and Path(code_path).exists() and Path(code_path).stat().st_size > 0)
    if not has_code:
        return SuccessRateResult(False, "no_code", False, False, 0, 0)

    has_stl = bool(stl_path and Path(stl_path).exists() and Path(stl_path).stat().st_size > 0)
    if not has_stl:
        return SuccessRateResult(False, "no_stl", True, False, 0, 0)

    try:
        import trimesh
        m = trimesh.load(str(stl_path), force="mesh")
        if isinstance(m, trimesh.Scene):
            geoms = [g for g in m.geometry.values() if isinstance(g, trimesh.Trimesh)]
            if not geoms:
                return SuccessRateResult(False, "empty_scene", True, True, 0, 0)
            m = trimesh.util.concatenate(geoms)
        if not isinstance(m, trimesh.Trimesh) or len(m.faces) == 0:
            return SuccessRateResult(False, "no_faces", True, True, 0, 0)
    except Exception as e:
        return SuccessRateResult(False, f"load_error:{type(e).__name__}", True, True, 0, 0)

    n_faces = int(len(m.faces))

    try:
        from ..voxel_iou.score import voxelize_normalized
        vox = voxelize_normalized(m, resolution=64)
        voxel_count = int(vox.sum())
    except Exception:
        voxel_count = 0

    if voxel_count < min_voxels:
        return SuccessRateResult(False, "empty_voxel_grid", True, True, n_faces, voxel_count)

    return SuccessRateResult(True, "ok", True, True, n_faces, voxel_count)
