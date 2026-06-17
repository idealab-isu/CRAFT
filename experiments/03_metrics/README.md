# Metrics

This directory holds the canonical implementation of every evaluation metric
reported in the CRAFT paper. Each metric lives in its own subdirectory with a
dedicated `README.md` explaining the formula, the library, the inputs/outputs,
and the exact command to reproduce the published numbers.

If a reviewer asks "how was X computed?", point them at the corresponding
subdirectory.

## Metric → script → paper-table mapping

| Metric | Subdirectory | Paper notation | Reported in |
|---|---|---|---|
| Fréchet Inception Distance | `fid/` | FID ↓ | Table I (perceptual NopSCADlib) |
| CLIP score | `clip/` | CLIP ↑ | Table I (perceptual NopSCADlib) |
| Chamfer Distance | `chamfer/` | CD ↓ | Tables II, III, IV (geometric) |
| F1 score (τ = 1%, 5%) | `f1/` | F1 ↑ | Tables II, III, IV |
| Voxel IoU | `voxel_iou/` | Voxel IoU ↑ | Tables II, III, IV |
| Hausdorff (HD, HD95, HD90) | `hausdorff/` | HD ↓ | rebuttal addendum |
| Normal Consistency | `normal_consistency/` | NC ↑ | rebuttal addendum |
| LPIPS | `lpips/` | LPIPS ↓ | rebuttal addendum |
| Editability (4 sub-metrics) | `editability/` | — | rebuttal addendum |

CD, F1, and Voxel IoU share a single implementation in `_shared/geometric.py`
because they all consume the same point-cloud / voxel-grid representations of
the input meshes; the per-metric subdirectories contain thin wrappers and the
per-metric README. The other metrics (FID, CLIP, Hausdorff, NC, LPIPS,
editability) are fully self-contained.

## Conventions used everywhere

- **Mesh inputs:** STL files. Predicted STLs are exported by `pipeline/utils/openscad_runner.export_stl`. Ground-truth STLs live under `ground_truth/<dataset>/`.
- **Image inputs:** PNG renders, 512 × 512 unless stated otherwise. Multi-view renders use the six orthographic views (front/back/left/right/top/bottom).
- **Point-cloud sampling:** `trimesh.sample.sample_surface` with 10,000 points and a fixed seed (42 by default; 43 used as a sensitivity check).
- **Mesh normalization (for geometric metrics):** every mesh is rigidly normalized to fit a unit cube `[0,1]^3` before comparison, so reported numbers are scale-invariant. The function is `normalize_to_unit_cube` in `_shared/geometric.py`.
- **Per-sample storage:** every metric writes a `detailed_results.json` keyed by `prompt_id`, alongside a `<metric>_scores.csv` (one row per prompt, one column per method). This format makes paired significance tests and bootstrap CIs trivial — see `experiments/04_statistics/`.
- **Per-tier aggregation:** every metric also reports means broken out by the Simple / Medium / Complex tiers defined in `experiments/01_ground_truth/compute_complexity.py`.

## When formulas matter (a note on FID)

For metrics that aggregate non-additively across subsets — most notably FID —
the per-tier numbers and the overall number are computed independently and
will not agree numerically. Read `fid/README.md` for the full explanation.
