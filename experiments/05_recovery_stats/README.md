# Phase 05 — Per-Stage Recovery Statistics

> **Status (Phase 1, depends on Phase 0b instrumentation):** scripts in this
> directory aggregate the per-layer recovery telemetry that Phase 0b adds to
> `pipeline/core/`. This README documents the formats they produce.

Aggregates the layer-by-layer recovery statistics requested by reviewers
R-UJGD, R-GyxV, and R-Awu5 ("operationalize robustness").

## What this phase produces

For each dataset:

```
metrics/<dataset>/recovery/
├── per_layer_stats.json       # Trigger rate, retry count, success rate, per layer
├── per_tier_pass_rates.json   # Component-verification pass rates by part-tier (essential/secondary/optional)
└── recovery_table.md          # Markdown summary
```

## The five recovery layers

| Layer | Component | What it does | Where it's logged |
|---|---|---|---|
| 1 | Schema Auto-Repair | JSON-schema validation + LLM repair (max 2 retries) | `state.plan_attempts` |
| 2 | SCAD Auto-Fix | Detects `hull`/`minkowski`/high `$fn`; simplifies; extends timeout | `state.vlm_iteration_history[*].autofix_attempted/succeeded` *(added Phase 0b)* |
| 3 | VLM Correction | Six-view render → GPT-5.2 assessment → LLM fix → iterate (max 3) | `state.vlm_iteration_history` |
| 4 | Component Verification | Tiered part check (essential 85%, secondary 65%, optional 50%) → connectivity check → targeted fix (max 3) | `state.component_verification_history` |
| 5 | Manual Repair | User-supplied hint folded into prompt (interactive only, not invoked in benchmark runs) | `state.repair_attempts` |

A shared `RecoveryBudget` counter (added in Phase 0b) caps the *combined* total
across layers at 10 attempts, which is what the paper text refers to as "the
fixed 10-attempt budget."

## Metrics produced

For each layer:

- **Trigger rate** — `count(layer fired) / total_runs`
- **Mean retry count** — average retries used when the layer fires
- **Post-recovery success rate** — fraction of cases that ultimately succeed
  after the layer ran
- **Budget utilization** — mean attempts used out of the 10-attempt budget

For layer 4 specifically, an additional table breaks down per-tier pass rates:

| Tier | Threshold | Pass rate (CRAFT) |
|---|---|---|
| Essential | 85% | … |
| Secondary | 65% | … |
| Optional | 50% | … |

## Inputs

`results/<dataset>/craft/results.json` (per-item recovery telemetry, fully
populated by Phase 0b instrumentation).

## Commands

```bash
python experiments/05_recovery_stats/aggregate_recovery.py --dataset nopscadlib
python experiments/05_recovery_stats/aggregate_recovery.py --dataset abc
python experiments/05_recovery_stats/aggregate_recovery.py --dataset slice100k
```
