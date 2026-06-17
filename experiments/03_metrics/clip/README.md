# CLIP Score

Text-image alignment score for evaluating whether the rendered model matches
the original natural-language prompt.

## Formula

For a (prompt, render) pair:

    CLIP_score = cos( CLIP_text_encode(prompt), CLIP_image_encode(render) )

Both embeddings are L2-normalized; the cosine reduces to a dot product.

## Model

- Backbone: `ViT-L-14`, OpenAI pretrained weights.
- Loaded through the `open_clip` library: `open_clip.create_model_and_transforms('ViT-L-14', pretrained='openai')`.
- Tokenizer: `open_clip.get_tokenizer('ViT-L-14')`.

## Inputs

- Predicted PNG renders at `results/<dataset>/<method>/png/<prompt_id>.png`.
- Natural-language prompts from `ground_truth/<dataset>/benchmark_ground_truth.json` (field `prompt_text`).
- Ground-truth PNGs only used to compute the GT ceiling (the highest score a
  perfect render of the ground-truth could achieve), not for the headline
  CRAFT-vs-baselines comparison.

## Per-sample, per-tier aggregation

- Per-sample CLIP score saved in `clip_scores.csv` (one row per prompt, one
  column per method).
- Per-method summaries: mean, std, median, min, max.
- Per-tier breakdown (Simple / Medium / Complex) from
  `compute_complexity.py`.

## Outputs

Written to `metrics/<dataset>/clip/`:

- `clip_detailed_results.json` — per-sample scores keyed by `prompt_id`.
- `clip_scores.csv` — wide table, one row per prompt, one column per method.
- `clip_comparison_table.md` — markdown comparison.

## Command

```bash
python experiments/03_metrics/clip/compute_clip.py \
    --gt-png-dir ground_truth/nopscadlib/png \
    --models craft=results/nopscadlib/craft/png \
             gpt4o=results/nopscadlib/baselines/gpt4o/png \
             gpt52=results/nopscadlib/baselines/gpt52/png \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --output-dir metrics/nopscadlib/clip
```

## Reproducing the paper numbers

NopSCADlib, ViT-L-14/openai weights, pooled over 468 prompts:

| Method | CLIP ↑ |
|---|---|
| CRAFT | **0.2223** |
| GPT-4o (direct) | 0.2033 |
| GPT-5.2 (direct) | 0.2145 |
| Ground truth ceiling | 0.2333 |

Verified against `metrics/nopscadlib/clip/clip_detailed_results.json`.

## Dependencies

`open_clip_torch`, `torch`, `pillow`, `pandas`, `numpy`.
