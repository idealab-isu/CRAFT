"""Aligned Chamfer Distance — thin wrapper over the existing CRAFT scorer.

The actual alignment pipeline (10k surface samples + PCA + 24 cube rotations
+ ICP) is in Experimentation/Chamfer_distance/align_and_score.py and remains
the source of truth. This module just exposes it under the zerotocad_eval
namespace so runners can call a single scoring API.
"""

from __future__ import annotations

import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

# Importing the existing module by path so we don't rely on PYTHONPATH gymnastics.
_REPO_ROOT = Path(__file__).resolve().parents[3]
_CD_MODULE_DIR = _REPO_ROOT / "Experimentation" / "Chamfer_distance"
if str(_CD_MODULE_DIR) not in sys.path:
    sys.path.insert(0, str(_CD_MODULE_DIR))


@dataclass
class CDResult:
    cd: float          # aligned bidirectional Chamfer Distance (lower is better)
    cd_raw: float      # CD before alignment (for reference)
    best_init: int     # which of the 24 cube rotations won
    n_points: int
    used_icp: bool


def score_cd_pair(
    pred_stl: str | Path,
    gt_stl: str | Path,
    n_points: int = 10_000,
    use_icp: bool = True,
) -> Optional[CDResult]:
    """Aligned bidirectional Chamfer Distance, returns None on load failure.

    The underlying AlignmentResult dataclass (in align_and_score.py) names the
    aligned distance `chamfer` and the pre-alignment value `chamfer_raw`. We
    surface them as `cd` / `cd_raw` so the zerotocad_eval namespace uses
    consistent terminology with `voxel_iou` (where the field is also `iou`).
    """
    from align_and_score import score_stl_pair as _score  # type: ignore

    res = _score(pred_stl, gt_stl, n_points=n_points, use_icp=use_icp)
    if res is None:
        return None
    return CDResult(
        cd=float(res.chamfer),
        cd_raw=float(res.chamfer_raw),
        best_init=int(res.best_init_index),
        n_points=n_points,
        used_icp=use_icp,
    )
