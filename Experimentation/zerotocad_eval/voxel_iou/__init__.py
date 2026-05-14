"""Voxel-IoU scoring at 64^3 with 24-cube-rotation alignment.

Replicates the primary metric used in Zero-to-CAD (Ataei et al., 2026).
"""

from .score import (
    voxelize_normalized,
    iou_with_rotation_alignment,
    score_stl_pair,
    score_stl_pair_safe,
)

__all__ = [
    "voxelize_normalized",
    "iou_with_rotation_alignment",
    "score_stl_pair",
    "score_stl_pair_safe",
]
