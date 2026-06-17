# F1 Score (point-cloud)

Precision/recall/F1 at distance thresholds τ, computed on the same point-cloud
sampling used for Chamfer Distance.

## Formula

Sample N = 10,000 points from each of `P` (predicted) and `G` (ground truth)
after rigid normalization to a unit cube. For a threshold τ (expressed as a
fraction of the unit-cube extent, so τ = 0.01 means 1% of the bounding-box
side):

    precision(τ) = | { p ∈ P : min_{g∈G} ‖p − g‖₂ ≤ τ } |  /  |P|
    recall(τ)    = | { g ∈ G : min_{p∈P} ‖g − p‖₂ ≤ τ } |  /  |G|
    F1(τ)        = 2 · precision · recall / (precision + recall)

## Thresholds

The paper reports two thresholds:

| Symbol | τ | Interpretation |
|---|---|---|
| `f1_score_1pct` | 0.01 | strict (1% of unit-cube edge ≈ 1mm at a 100mm part) |
| `f1_score_5pct` | 0.05 | lax (5% of unit-cube edge ≈ 5mm at a 100mm part) |

Both meshes are normalized to the unit cube before sampling, so τ is
scale-invariant. Nearest-neighbour queries use `scipy.spatial.cKDTree`.

## Inputs / outputs

Same as Chamfer (shared implementation in `_shared/geometric.py`). Per-sample
precision, recall, F1@1%, and F1@5% are all saved in
`detailed_results.json` keyed by `prompt_id`. Per-tier (Simple / Medium /
Complex) means are written to `comparison_table.md`.

## Why not a fixed absolute τ in millimetres

The archived implementation at `_archive/pipeline_utils_metrics.py:compute_fscore`
used an absolute τ of 1.0mm without normalization. That makes F1 dependent on
the physical scale of the part — a 10mm component and a 100mm component see
very different F1 values for the same relative error. The paper uses the
unit-cube-relative form so reported F1s are comparable across components of
wildly different sizes.

## Command

Identical to the Chamfer command (shared implementation):

```bash
python experiments/03_metrics/_shared/geometric.py \
    --gt-dir ground_truth/nopscadlib/stl \
    --models craft=results/nopscadlib/craft/stl \
             gpt4o=results/nopscadlib/baselines/gpt4o/stl \
             gpt52=results/nopscadlib/baselines/gpt52/stl \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/f1 \
    --metrics f1
```

## Reproducing the paper numbers (F1@1%)

| Dataset | CRAFT | GPT-4o | GPT-5.2 |
|---|---|---|---|
| NopSCADlib | 0.2369 | 0.2467 | **0.2585** |
| ABC | **0.1303** | 0.0847 | 0.0880 |
| Slice-100K | **0.2831** | 0.2146 | 0.2828 |

## Dependencies

`trimesh`, `scipy`, `numpy`.
