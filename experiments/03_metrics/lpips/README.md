# LPIPS — Learned Perceptual Image Patch Similarity

Perceptual distance between two images using features from a pretrained CNN.

> **Status (Phase 0b):** the canonical implementation `compute_lpips.py` is
> being added here as part of the Phase 0b foundation work. Existing result
> files at `metrics/nopscadlib/lpips/lpips_scores.csv` and `lpips_summaries.json`
> were produced by a generator script that was not committed to the repo. The
> new script reproduces those numbers and will be the only blessed
> implementation going forward.

## Formula

Following Zhang et al. (2018), "The Unreasonable Effectiveness of Deep
Features as a Perceptual Metric":

    LPIPS(I_P, I_G) = Σ_l  || w_l ⊙ ( ϕ_l(I_P) − ϕ_l(I_G) ) ||²₂   /  (H_l · W_l)

where ϕ_l are the per-layer features of a pretrained backbone, w_l are
learned per-channel weights, and the inner difference is taken after
channel-wise unit-normalization.

## Backbone

The reference numbers in `metrics/nopscadlib/lpips/lpips_summaries.json` use
`backbone = "vgg"` (specifically the VGG-16 LPIPS network from the `lpips`
package). The new `compute_lpips.py` defaults to the same backbone for
backward compatibility with those numbers; pass `--backbone alex` to use
AlexNet (faster, slightly different scale).

## Inputs / outputs

- Inputs: PNG renders (same paths as FID and CLIP).
- Outputs in `metrics/<dataset>/lpips/`:
  - `lpips_detailed_results.json` — per-sample LPIPS scores.
  - `lpips_scores.csv`.
  - `lpips_summaries.json`.
  - `lpips_comparison_table.md`.

## Command

```bash
python experiments/03_metrics/lpips/compute_lpips.py \
    --gt-png-dir ground_truth/nopscadlib/png \
    --models craft=results/nopscadlib/craft/png \
             gpt4o=results/nopscadlib/baselines/gpt4o/png \
             gpt52=results/nopscadlib/baselines/gpt52/png \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --backbone vgg \
    --output-dir metrics/nopscadlib/lpips
```

## Dependencies

`lpips`, `torch`, `torchvision`, `pillow`.
