# Chamfer Distance

Surface-to-surface distance between predicted and ground-truth meshes,
operating on point clouds sampled from both surfaces.

## Formula

Given two point clouds `P` (predicted) and `G` (ground truth), each containing
N = 10,000 surface samples:

    CD(P, G) = 0.5 · ( mean_{p∈P} min_{g∈G} ‖p − g‖₂  +  mean_{g∈G} min_{p∈P} ‖g − p‖₂ )

This is the symmetric mean form (sometimes called "mean Chamfer"). It is the
average of forward and backward one-sided Chamfer means. Both meshes are
rigidly normalized to fit a unit cube before sampling, so CD values are
scale-invariant and directly comparable across datasets.

Nearest-neighbour queries use `scipy.spatial.cKDTree` (CPU). A GPU
implementation is available in `_shared/geometric.py:_chamfer_gpu` for large
batches; it produces identical results to floating-point precision.

## Why this formula (and not "sum of means")

Two CD formulas exist in the wild:

1. `0.5 · (forward_mean + backward_mean)` — the **symmetric mean**, used here.
2. `forward_mean + backward_mean` — the **sum**, sometimes called "asymmetric Chamfer."

The paper reports form (1). The older, archived implementation at
`_archive/pipeline_utils_metrics.py:compute_fscore` used form (2) on
un-normalized meshes with only 2,048 points — those numbers are not comparable
to the paper. Do not use that implementation.

## Inputs

- Predicted STL meshes at `results/<dataset>/<method>/stl/<prompt_id>.stl`.
- Ground-truth STL meshes at `ground_truth/<dataset>/stl/<prompt_id>.stl`.
- Component metadata from `ground_truth/<dataset>/benchmark_ground_truth.json`.

## Sampling

- `trimesh.sample.sample_surface(mesh, count=10_000, seed=42)` for each side.
- A second seed (43) is used by `_chamfer_cpu` as a sensitivity check; results
  are reported with seed=42 only.

## Outputs

Written to `metrics/<dataset>/chamfer/` (shared with f1/ and voxel_iou/ because
they consume the same point-cloud step):

- `detailed_results.json` — per-sample CD keyed by `prompt_id`, alongside F1
  and Voxel IoU.
- `chamfer_scores.csv` — wide table for paired tests.
- `comparison_table.md` — per-method, per-tier means.

## Command

```bash
python experiments/03_metrics/_shared/geometric.py \
    --gt-dir ground_truth/nopscadlib/stl \
    --models craft=results/nopscadlib/craft/stl \
             gpt4o=results/nopscadlib/baselines/gpt4o/stl \
             gpt52=results/nopscadlib/baselines/gpt52/stl \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/chamfer \
    --metrics chamfer f1 voxel_iou
```

## Reproducing the paper numbers

| Dataset | CRAFT | GPT-4o | GPT-5.2 |
|---|---|---|---|
| NopSCADlib | 0.0704 | 0.0742 | **0.0671** |
| ABC | **0.0804** | 0.1009 | 0.0950 |
| Slice-100K | 0.0617 | 0.0743 | **0.0607** |

## Dependencies

`trimesh`, `scipy`, `numpy`. GPU path additionally requires `torch`.
