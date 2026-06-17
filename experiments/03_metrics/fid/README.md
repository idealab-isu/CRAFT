# FID — Fréchet Inception Distance

Implementation of FID following Heusel et al. (2017),
"GANs Trained by a Two Time-Scale Update Rule Converge to a Local Nash Equilibrium."

## Formula

For two distributions of images, characterized by their Inception-v3 feature
mean μ and covariance Σ:

    FID = ‖μ_gt − μ_pred‖²  +  trace( Σ_gt + Σ_pred − 2·(Σ_gt · Σ_pred)^(1/2) )

The matrix square root is computed by `scipy.linalg.sqrtm`.

## Inputs

- Predicted PNG renders, located at `results/<dataset>/<method>/png/<prompt_id>.png`.
- Ground-truth PNG renders, located at `ground_truth/<dataset>/png/<prompt_id>.png`.
- Component metadata (tier, family) from `ground_truth/<dataset>/benchmark_ground_truth.json`.

## Feature extractor

- Inception-v3, ImageNet-pretrained, weights loaded by `torchvision.models.inception_v3(pretrained=True)`.
- Avgpool layer output, **2048-dimensional**.
- Images resized to 299×299 and normalized with ImageNet statistics
  `mean=[0.485,0.456,0.406]`, `std=[0.229,0.224,0.225]` before being fed to the network.

## How samples are pooled (read this if you are reviewer R-Awu5)

**The headline "Overall FID" reported in the paper is computed once on the full
pooled set of matched (gt, pred) renders — not as an average of per-tier FIDs.**
FID is a distributional statistic over Inception feature means and covariances;
it is *not* additive across subsets. Concretely, for the NopSCADlib benchmark:

- Overall FID uses the 463 matched (gt, pred) pairs found across all tiers
  (some prompts produced an unrenderable model and are dropped; that's the
  difference vs. the nominal 468).
- Per-tier FIDs are computed independently on their respective subsets
  (Simple n=159, Medium n=160, Complex n=149 — actual matched counts may be
  slightly smaller after dropping unrenderable predictions).

Because the per-tier covariance estimates are noisier (fewer samples), per-tier
FIDs are *systematically larger* than the pooled overall FID. The pooled FID is
the more reliable single-number summary; the per-tier values are useful as
diagnostics but should not be averaged. This is exactly the property reviewer
R-Awu5 flagged as confusing in the original submission.

The script reports per-tier FID only when a tier has `n ≥ 30` samples, to keep
the per-tier estimates from being dominated by covariance noise.

## Outputs

Written to `metrics/<dataset>/fid/`:

- `fid_results.json` — one record per method, containing `fid_score` (pooled),
  `fid_by_tier`, `n_matched`, runtime, and the configuration used.
- `fid_comparison_table.md` — Markdown comparison across methods (used by
  `experiments/06_tables_and_figures/`).
- Cached Inception features (npz) for each PNG directory, so re-runs are cheap.

**Per-sample feature vectors are cached but per-sample FID values do not exist
by construction.** For confidence intervals, see
`experiments/04_statistics/fid_bootstrap.py`, which bootstrap-resamples the
matched-image set and recomputes FID 1,000 times against the cached features.

## Command

```bash
# Single method
python experiments/03_metrics/fid/compute_fid.py \
    --gt-png-dir ground_truth/nopscadlib/png \
    --pred-png-dir results/nopscadlib/craft/png \
    --model-name craft \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/fid

# All methods at once (recommended)
python experiments/03_metrics/fid/compute_fid.py \
    --gt-png-dir ground_truth/nopscadlib/png \
    --models craft=results/nopscadlib/craft/png \
             gpt4o=results/nopscadlib/baselines/gpt4o/png \
             gpt52=results/nopscadlib/baselines/gpt52/png \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/fid
```

## Reproducing the paper number

NopSCADlib, CRAFT method, ImageNet-pretrained Inception-v3, all 463 matched
pairs pooled → **FID = 94.47**.

Verified against `metrics/nopscadlib/fid/fid_results.json:fid_score`.

## Dependencies

`torch`, `torchvision`, `scipy`, `numpy`, `pillow`. Install via the top-level
`requirements.txt`.
