"""Aligned Chamfer Distance — wraps Experimentation/Chamfer_distance.

CD is reported alongside voxel-IoU as a stricter cross-check on surface
fidelity (see CRAFT_zerotocad_eval_plan.md §5).
"""

from .score import score_cd_pair, CDResult

__all__ = ["score_cd_pair", "CDResult"]
