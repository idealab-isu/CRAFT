# _archive — Superseded Code, Kept for Reference

Everything in this directory has been replaced by a canonical version under
`experiments/` and `pipeline/`. Nothing here should be used to produce results
in the current paper. The directory exists to preserve provenance for older
runs and to make it easy to audit what changed between submission and
camera-ready.

## Contents

| Path | Replaced by | Why archived |
|---|---|---|
| `pipeline_evaluation/` | `experiments/` (entire phase tree) | Parallel evaluation track with overlapping but inconsistent functionality. In particular, `pipeline_evaluation/compute_chamfer_with_judge.py` and `pipeline_evaluation/run_nopscadlib_benchmark.py` used a Chamfer formula (`mean + mean`, un-normalized, 2,048 points) that does not match the paper. The `run_table_4..8.py` scripts targeted a separate 30-prompt set used in earlier exploration. |
| `pipeline_static_images/` | nothing (web-app demo artifacts) | 200+ timestamped iteration directories from runs of the Flask demo (`pipeline/app.py`). Not used by any paper experiment. |
| `pipeline_static_stl/` | nothing (web-app demo artifacts) | STL outputs from the Flask demo. |
| `_patch_paths.py` | n/a | One-shot path patcher used during the Phase 0a reorganization. Idempotent — safe to ignore. |

## Specifically about the duplicate Chamfer formula

`pipeline_evaluation/compute_chamfer_with_judge.py` defined Chamfer Distance as

    CD_old = mean(d_forward) + mean(d_backward)

operating on 2,048 surface points per mesh, **without normalizing the meshes to
a common scale.** The canonical paper formula (`experiments/03_metrics/chamfer/`)
is

    CD = 0.5 · ( mean(d_forward) + mean(d_backward) )

on 10,000 points per mesh after rigid normalization to a unit cube. The two
formulas can differ by a factor of two and by a meaningful constant when meshes
have different scales. Cross-method comparisons made with the old formula are
not directly comparable to anything in the paper.

`pipeline_utils_metrics.py` (the original `pipeline/utils/metrics.py`) had the
same issue: its `compute_fscore` used an absolute 1.0mm threshold rather than
a unit-cube-relative fraction. Image metrics from that file (SSIM, silhouette
IoU, MSE, PSNR) are correct and are still imported by the pipeline at
`pipeline/utils/metrics.py`; only the geometric functions are deprecated.
