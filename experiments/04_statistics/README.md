# Phase 04 — Statistical Significance

> **Status (Phase 1):** scripts in this directory are added in Phase 1. This
> README documents their interface and the formulas they use.

Bootstrap confidence intervals and paired significance tests on top of the
per-sample metric outputs from Phase 03. No LLM calls; runs in seconds against
already-saved data.

## Scripts

| Script | Output | Description |
|---|---|---|
| `bootstrap_ci.py` | `metrics/<dataset>/<metric>/ci.json` | 95% bootstrap confidence intervals on means, per method and per tier, for every metric with per-sample data |
| `paired_tests.py` | `metrics/<dataset>/<metric>/paired_tests.json` | Paired Wilcoxon signed-rank p-values for every CRAFT-vs-method comparison, with Benjamini–Hochberg correction across metrics |
| `fid_bootstrap.py` | `metrics/<dataset>/fid/ci.json` | Bootstrap CI on FID specifically — resamples the matched-pair feature set 1,000× and recomputes FID against cached Inception features |

## Why bootstrap and Wilcoxon

- **Bootstrap CI:** non-parametric, robust to heavy-tailed metric distributions
  (very common in CD/F1 because rendering failures produce extreme values).
  1,000 resamples by default; configurable.
- **Paired Wilcoxon signed-rank:** non-parametric, exploits the within-prompt
  pairing (every method generates a model for the same `prompt_id`, so the
  same prompts give matched samples). More powerful than independent-samples
  tests when prompt difficulty varies, as it does here.
- **Benjamini–Hochberg FDR:** controls the false-discovery rate at α=0.05
  across the family of metric comparisons reported in one table. Used instead
  of the more conservative Bonferroni so we retain some power.

## Inputs

Reads the per-sample artifacts written by Phase 03:

- `metrics/<dataset>/chamfer/detailed_results.json` (per-sample CD, F1, VoxIoU, SSIM)
- `metrics/<dataset>/clip/clip_detailed_results.json`
- `metrics/<dataset>/hausdorff/hd_detailed_results.json`
- `metrics/<dataset>/normal_consistency/nc_detailed_results.json`
- `metrics/<dataset>/lpips/lpips_detailed_results.json`
- For FID: the cached Inception features at `metrics/<dataset>/fid/_cache/`.

Per-sample data is keyed by `prompt_id` for paired tests to work.

## Commands

```bash
python experiments/04_statistics/bootstrap_ci.py    --dataset nopscadlib --n-resamples 1000
python experiments/04_statistics/paired_tests.py    --dataset nopscadlib --reference craft
python experiments/04_statistics/fid_bootstrap.py   --dataset nopscadlib --n-resamples 1000
# repeat with --dataset abc and --dataset slice100k
```

## Output schema

`ci.json`:
```json
{
  "metric": "chamfer_distance",
  "dataset": "nopscadlib",
  "method": "craft",
  "tier": "Complex",
  "mean": 0.0823,
  "ci_low": 0.0741,
  "ci_high": 0.0908,
  "n": 149,
  "n_resamples": 1000
}
```

`paired_tests.json`:
```json
{
  "metric": "chamfer_distance",
  "dataset": "nopscadlib",
  "reference": "craft",
  "comparison": "gpt52",
  "median_delta": -0.0033,
  "n_pairs": 463,
  "p_value": 0.0421,
  "p_value_adj": 0.1263,
  "significant": false,
  "test": "wilcoxon_signed_rank",
  "correction": "benjamini_hochberg"
}
```
