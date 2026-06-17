# FID (Fréchet Inception Distance) Evaluation Results

Generated: 2026-06-04 01:27:36
Feature extractor: Inception-v3 (pool3, 2048-dim)
Lower FID = generated renders are distributionally closer to GT renders.

## Overall Comparison

| Metric | craft | gpt4o | gpt52 |
|--------|------|------|------|
| FID ↓ | **95.11** | 119.42 | 106.22 |
| Matched pairs | 467 | 467 | 462 |
| GT images | 468 | 468 | 468 |
| Pred images | 467 | 467 | 462 |

## Per-Tier FID

Note: Per-tier FID is computed with ~150 samples per tier. Interpret with caution — FID is most reliable with 500+ samples.

| Tier | craft | gpt4o | gpt52 |
|------|------|------|------|
| Simple | 152.37 (n=158) | 144.38 (n=159) | **136.22** (n=159) |
| Medium | **126.88** (n=160) | 159.56 (n=160) | 147.95 (n=158) |
| Complex | **144.85** (n=149) | 184.39 (n=148) | 160.51 (n=145) |

## Interpretation Guide

| FID Range | Interpretation |
|-----------|----------------|
| 0–10 | Very similar distributions (excellent) |
| 10–50 | Good quality, some distributional differences |
| 50–100 | Noticeable differences in quality or diversity |
| 100+ | Very different distributions |

Note: These ranges are approximate. FID values depend heavily on the domain (CAD renders vs natural photos) and dataset size. Compare models against each other, not against absolute thresholds.