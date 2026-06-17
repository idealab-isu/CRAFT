# Hausdorff Distance (HD, HD95, HD90)

Worst-case (and high-percentile) surface-to-surface distance between predicted
and ground-truth meshes.

## Formulas

Given two point clouds `P` and `G` sampled from the predicted and ground-truth
surfaces (10,000 points each after unit-cube normalization), let

    d_PG = { min_{g∈G} ‖p − g‖₂ : p ∈ P }      (forward nearest-neighbour distances)
    d_GP = { min_{p∈P} ‖g − p‖₂ : g ∈ G }      (backward NN distances)

Then:

    HD    = max( max(d_PG), max(d_GP) )         ← classical Hausdorff
    HD95  = 95th percentile of (d_PG ∪ d_GP)    ← outlier-robust
    HD90  = 90th percentile of (d_PG ∪ d_GP)    ← even more robust

Lower is better. HD captures the single worst defect; HD95/HD90 strip the
worst few percent and are more robust to small isolated geometry errors.

Nearest-neighbour queries use `scipy.spatial.cKDTree`. Both meshes are
normalized to a unit cube before sampling, so distances are scale-invariant.

## When to read which

- **HD** — useful for catching catastrophic geometry errors (a stray vertex far
  from the model, a missing major part). Very sensitive to a single outlier.
- **HD95** — the most-cited robust variant. Good general-purpose metric.
- **HD90** — even more robust; reflects the bulk of the surface mismatch.

The paper's rebuttal addendum reports all three for completeness.

## Inputs / outputs

Inputs are STL meshes from `results/<dataset>/<method>/stl/` and
`ground_truth/<dataset>/stl/`.

Outputs in `metrics/<dataset>/hausdorff/`:

- `hd_detailed_results.json` — per-sample HD, HD95, HD90.
- `hd_scores.csv` — wide table per metric.
- `hd_summaries.json` — mean/median/std per method and per tier.
- `hd_comparison_table.md` — Markdown table.

## Command

```bash
python experiments/03_metrics/hausdorff/compute_hausdorff.py \
    --gt-dir ground_truth/nopscadlib/stl \
    --models craft=results/nopscadlib/craft/stl \
             gpt4o=results/nopscadlib/baselines/gpt4o/stl \
             gpt52=results/nopscadlib/baselines/gpt52/stl \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/hausdorff
```

## Dependencies

`trimesh`, `scipy`, `numpy`.
