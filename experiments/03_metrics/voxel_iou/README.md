# Voxel IoU

Volumetric Intersection-over-Union between predicted and ground-truth meshes
after voxelization.

## Formula

Both meshes are voxelized on a shared grid:

- Joint bounding box: the union of the two meshes' axis-aligned bounding boxes.
- Resolution: **64 voxels along the longest axis** of the joint bbox; the other
  two axes are scaled proportionally so voxels are cubic.
- Voxelization via `trimesh.voxelized(pitch)` followed by `fill()` to convert
  surface voxels into solid voxels.

Let `V_P` and `V_G` be the resulting voxel sets:

    VoxelIoU = |V_P ∩ V_G| / |V_P ∪ V_G|

Implemented as `compute_voxel_iou` in `_shared/geometric.py`.

## Why volumetric and not just surface?

CD and F1 measure surface-to-surface proximity. They can both look acceptable
on a model that is missing entire interior components or has wildly wrong wall
thicknesses. Voxel IoU directly measures volumetric overlap and is therefore
sensitive to:

- Missing internal cavities or hollow features.
- Incorrect solid/shell topology.
- Compositional errors where parts are present but disconnected from the
  intended assembly.

CRAFT's structured planning and component verification tend to score
disproportionately well on Voxel IoU for exactly these reasons.

## Inputs / outputs

Same shared pipeline as Chamfer and F1. Per-sample Voxel IoU is saved in
`detailed_results.json`. Per-tier means in `comparison_table.md`.

## Command

```bash
python experiments/03_metrics/_shared/geometric.py \
    --gt-dir ground_truth/nopscadlib/stl \
    --models craft=results/nopscadlib/craft/stl \
             gpt4o=results/nopscadlib/baselines/gpt4o/stl \
             gpt52=results/nopscadlib/baselines/gpt52/stl \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/voxel_iou \
    --metrics voxel_iou
```

## Reproducing the paper numbers

| Dataset | CRAFT | GPT-4o | GPT-5.2 |
|---|---|---|---|
| NopSCADlib | **0.2242** | 0.2182 | 0.1870 |
| ABC | **0.0401** | 0.0211 | 0.0187 |
| Slice-100K | 0.0633 | **0.0718** | 0.0627 |

## Dependencies

`trimesh`, `numpy`.
