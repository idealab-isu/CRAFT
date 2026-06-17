# CRAFT Experiments

This directory contains every script, formula, and command needed to reproduce
the experimental results in the CRAFT paper. It is organized as a six-step
pipeline that runs end-to-end from raw datasets to publication-ready LaTeX
tables.

## Layout

```
experiments/
├── 01_ground_truth/         # Build ground-truth assets for the three datasets
├── 02_benchmark/            # Generate model outputs (CRAFT, baselines, ablations, matched-effort)
├── 03_metrics/              # Score model outputs against ground truth
│   ├── fid/                 #   one self-contained subdirectory per metric
│   ├── clip/                #   each has its own README explaining the formula,
│   ├── chamfer/             #   library, inputs, and outputs
│   ├── f1/
│   ├── voxel_iou/
│   ├── hausdorff/
│   ├── normal_consistency/
│   ├── lpips/
│   └── editability/
├── 04_statistics/           # Bootstrap CIs, paired significance tests
├── 05_recovery_stats/       # Per-stage recovery statistics from CRAFT runs
└── 06_tables_and_figures/   # Emit paper-ready LaTeX tables from metric JSONs
```

Each numbered subdirectory has its own `README.md` with the exact commands.

## What goes where

| Phase | Produces | Consumed by |
|---|---|---|
| `01_ground_truth/` | `ground_truth/<dataset>/{scad,stl,png,benchmark_ground_truth.json}` | every other phase |
| `02_benchmark/` | `results/<dataset>/<method>/{scad,stl,png,results.json}` | phase 03 |
| `03_metrics/` | `metrics/<dataset>/<metric>/{detailed_results.json,summaries.json,scores.csv}` | phases 04 and 06 |
| `04_statistics/` | `metrics/<dataset>/<metric>/significance.json` (95% CIs + paired p-values) | phase 06 |
| `05_recovery_stats/` | `metrics/<dataset>/recovery/{per_layer_stats.json,per_tier_pass_rates.json}` | phase 06 |
| `06_tables_and_figures/` | `paper/ieee_lad_2026/tables/*.tex` | the paper itself |

## Quick start — reproducing the paper end-to-end

```bash
# 1. Build ground truth (one-time, hours)
python experiments/01_ground_truth/render_nopscadlib.py
python experiments/01_ground_truth/compute_complexity.py
python experiments/01_ground_truth/external_render_views.py --dataset abc
python experiments/01_ground_truth/external_render_views.py --dataset slice100k
python experiments/01_ground_truth/external_gt.py --dataset abc
python experiments/01_ground_truth/external_gt.py --dataset slice100k

# 2. Run every method × every dataset (the LLM-call phase, hours)
python experiments/02_benchmark/run_craft.py
python experiments/02_benchmark/run_direct_baselines.py
python experiments/02_benchmark/run_external.py --dataset abc --models craft gpt4o gpt52
python experiments/02_benchmark/run_external.py --dataset slice100k --models craft gpt4o gpt52
# Ablations and matched-effort baselines have their own runners (added in Phase 0b).

# 3. Compute every metric
python experiments/03_metrics/_shared/geometric.py --models craft=... gpt4o=... gpt52=...
python experiments/03_metrics/fid/compute_fid.py --models craft=... gpt4o=... gpt52=...
python experiments/03_metrics/clip/compute_clip.py --models craft=... gpt4o=... gpt52=...
python experiments/03_metrics/hausdorff/compute_hausdorff.py --models craft=... gpt4o=... gpt52=...
python experiments/03_metrics/normal_consistency/compute_nc.py --models craft=... gpt4o=... gpt52=...
python experiments/03_metrics/lpips/compute_lpips.py --models craft=... gpt4o=... gpt52=...
python experiments/03_metrics/editability/compute_editability.py --scad-dir results/<dataset>/<method>/scad

# 4. Significance + recovery analysis (no LLM calls, seconds)
python experiments/04_statistics/bootstrap_ci.py
python experiments/04_statistics/paired_tests.py
python experiments/04_statistics/fid_bootstrap.py
python experiments/05_recovery_stats/aggregate_recovery.py

# 5. Emit every table in the paper from JSON
python experiments/06_tables_and_figures/generate_all_tables.py
```

## Datasets

| Dataset | n | Source | Where to obtain |
|---|---|---|---|
| NopSCADlib | 468 | https://github.com/nophead/NopSCADlib | `git clone` into `pipeline/kb_data/` (see `pipeline/scripts/build_knowledge_base.py`) |
| ABC | 100 | https://archive.nyu.edu/handle/2451/43778 | external download, place STLs under `data/abc/` |
| Slice-100K | 100 | https://github.com/idealab-isu/Slice-100K | external download, place STLs under `data/slice100k/` |

## Models compared

| Method | Description | Where it lives |
|---|---|---|
| `craft` | Full CRAFT pipeline (6 stages, 5 recovery layers) | `pipeline/core/` |
| `gpt4o` | Direct one-shot OpenSCAD from GPT-4o (no plan, no recovery) | `experiments/02_benchmark/run_direct_baselines.py` |
| `gpt52` | Direct one-shot OpenSCAD from GPT-5.2 (no plan, no recovery) | `experiments/02_benchmark/run_direct_baselines.py` |
| `no_json_ir`, `no_retrieval`, `no_multiview`, `no_verification`, `no_recovery` | CRAFT with one component disabled (ablations) | `experiments/02_benchmark/run_ablations.py` (Phase 0b) |
| `direct_repair`, `direct_vlm`, `direct_matched_calls` | Matched-effort baselines | `experiments/02_benchmark/run_matched_effort.py` (Phase 0b) |
