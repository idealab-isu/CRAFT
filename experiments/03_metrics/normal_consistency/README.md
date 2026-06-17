# Normal Consistency

Surface-orientation agreement between predicted and ground-truth meshes.

## Formula

For each point `p ∈ P` (with unit surface normal `n_p`), find its nearest
neighbour `g ∈ G` (with unit surface normal `n_g`), and compute the absolute
dot product:

    NC(P, G) = mean_{p ∈ P} | n_p · n_g_nearest(p) |

Higher is better. The absolute value treats opposite-pointing normals as
consistent (a flipped winding order does not penalize), which matches the
convention in OccNet, IF-Net, and most mesh-evaluation work.

Surface samples come from `trimesh.sample.sample_surface` (10,000 points) with
face normals retrieved via `mesh.face_normals` indexed by the face id returned
by `sample_surface`. Nearest neighbours via `scipy.spatial.cKDTree`.

## Inputs / outputs

- Inputs: STL meshes (same as Chamfer / Hausdorff).
- Outputs in `metrics/<dataset>/normal_consistency/`:
  - `nc_detailed_results.json` — per-sample NC scores.
  - `nc_scores.csv` — wide table for paired tests.
  - `nc_summaries.json` — mean/median/std, per method and per tier.
  - `nc_comparison_table.md` — Markdown table.

## Command

```bash
python experiments/03_metrics/normal_consistency/compute_nc.py \
    --gt-dir ground_truth/nopscadlib/stl \
    --models craft=results/nopscadlib/craft/stl \
             gpt4o=results/nopscadlib/baselines/gpt4o/stl \
             gpt52=results/nopscadlib/baselines/gpt52/stl \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/normal_consistency
```

## Dependencies

`trimesh`, `scipy`, `numpy`.
