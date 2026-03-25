# FID (Fréchet Inception Distance) Evaluation Results

Generated: 2026-03-01 16:14:57
Feature extractor: Inception-v3 (pool3, 2048-dim)
Lower FID = generated renders are distributionally closer to GT renders.

## Overall Comparison

| Metric | cadence | gpt4o | gpt52 |
|--------|------|------|------|
| FID ↓ | **94.47** | 118.01 | 104.63 |
| Matched pairs | 463 | 467 | 462 |
| GT images | 468 | 468 | 468 |
| Pred images | 463 | 467 | 462 |

## Per-Tier FID

Note: Per-tier FID is computed with ~150 samples per tier. Interpret with caution — FID is most reliable with 500+ samples.

| Tier | cadence | gpt4o | gpt52 |
|------|------|------|------|
| Simple | 154.65 (n=158) | 144.85 (n=159) | **136.43** (n=159) |
| Medium | **130.33** (n=158) | 155.06 (n=160) | 143.33 (n=158) |
| Complex | **136.90** (n=147) | 184.38 (n=148) | 160.51 (n=145) |

## Interpretation Guide

| FID Range | Interpretation |
|-----------|----------------|
| 0–10 | Very similar distributions (excellent) |
| 10–50 | Good quality, some distributional differences |
| 50–100 | Noticeable differences in quality or diversity |
| 100+ | Very different distributions |

Note: These ranges are approximate. FID values depend heavily on the domain (CAD renders vs natural photos) and dataset size. Compare models against each other, not against absolute thresholds.