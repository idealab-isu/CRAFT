# Per-Stage Recovery Statistics

## Per layer

| Layer | Trigger rate | Mean retries (when triggered) | Post-recovery success |
|---|---:|---:|---:|
| schema repair | 0.072 | 1.00 | 1.000 |
| scad autofix | 0.007 | 1.00 | 1.000 |
| vlm correction | 0.804 | 1.62 | 0.503 |
| component verification | 0.173 | 1.61 | 0.000 |
| manual repair | 0.000 | 0.00 | 0.000 |

**Mean budget used:** 1.66 of 10 attempts (445/445 runs reported budget telemetry).

## Component verification, per-tier pass rates

| Tier | Threshold | n parts | Pass rate |
|---|---|---:|---:|
| Essential | 85% | 92 | 0.946 |
| Secondary | 65% | 353 | 0.972 |
| Optional | 50% | 0 | 0.000 |
