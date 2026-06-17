# Phase 06 — Tables and Figures

> **Status (Phase 0b):** `generate_all_tables.py` is added in Phase 0b.

Emits every LaTeX table reported in the paper, directly from the metric JSONs
in `metrics/`. Eliminates hand-transcription as a source of error and makes
every published number traceable to data on disk.

## Tables in the paper

| Table | Caption | Reads from |
|---|---|---|
| I | Perceptual alignment (NopSCADlib) — CLIP, FID | `metrics/nopscadlib/clip/`, `metrics/nopscadlib/fid/` |
| II | Geometric accuracy (NopSCADlib) — CD, F1, Voxel IoU | `metrics/nopscadlib/chamfer/` |
| III | Ablation study | `metrics/nopscadlib/*/` for each ablation variant |
| IV | Geometric accuracy (ABC) | `metrics/abc/chamfer/` |
| V | Geometric accuracy (Slice-100K) | `metrics/slice100k/chamfer/` |
| VI | Per-stage recovery statistics | `metrics/<dataset>/recovery/` |
| VII | Matched-effort baselines | `metrics/<dataset>/*/` filtered to matched_effort variants |
| VIII | Editability | `metrics/<dataset>/editability/` |
| (appendix) | Hausdorff, Normal Consistency, LPIPS | `metrics/<dataset>/{hausdorff,normal_consistency,lpips}/` |

Bootstrap CIs and significance markers (from Phase 04) are merged in
automatically when present.

## Commands

```bash
# Emit one table
python experiments/06_tables_and_figures/generate_all_tables.py --table 1

# Emit every table
python experiments/06_tables_and_figures/generate_all_tables.py --all
```

Tables are written to `paper/ieee_lad_2026/tables/table_<N>.tex` and can be
`\input{}`'d directly from the main LaTeX source.
