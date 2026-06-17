# Additional Study

This directory holds experiments and analyses that are **not reported in the
LAD 2026 paper**. They are kept here, separate from the main repository, for
completeness and provenance. Nothing in this folder is required to reproduce
the paper's results — everything the paper reports lives at the top level of
the repository.

## Contents

### `matched_effort/`
Matched-effort baselines that give a direct-generation model a comparable
inference budget to CRAFT (iterative repair, VLM feedback, and matched API
calls), rather than a single shot. These were explored during the rebuttal
but are not part of the paper.

- `results/` — generated OpenSCAD programs (`.scad`) and `results.json` for
  `direct_repair`, `direct_vlm`, and `direct_matched_calls` on NopSCADlib.
- `editability_matched/` — editability metrics for the matched-effort runs.
- `table_7_matched_effort.tex` — the corresponding LaTeX table.
- Runner: [`../experiments/02_benchmark/run_matched_effort.py`](../experiments/02_benchmark/run_matched_effort.py).

### `extra_metrics/`
Additional geometric/perceptual metrics that were computed but not reported in
the paper (the paper reports Chamfer Distance, F1, Voxel IoU, CLIP, and FID).

- `hausdorff/` — Hausdorff distance results.
- `lpips/` — LPIPS perceptual-distance results.
- `normal_consistency/` — surface-normal-consistency results.
- Scripts live in `../experiments/03_metrics/{hausdorff,lpips,normal_consistency}/`.

### `_archive/`
Superseded code and earlier evaluation harnesses, kept for provenance only and
never edited. Large image/mesh artifacts under `_archive/` are intentionally
not committed.

### `notes/`
Process and camera-ready notes carried over from development
(`CAMERA_READY_CHANGES.md`, rebuttal experiment logs, results summaries).
