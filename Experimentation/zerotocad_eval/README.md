# Zero-to-CAD evaluation harness

End-to-end pipeline that benchmarks CRAFT v3 against Zero-to-CAD's fine-tuned
Qwen3-VL-2B and GPT-5.2 zero-shot baselines, using Zero-to-CAD's own
evaluation protocol (8 multi-view PNG inputs, 64³ voxel-IoU with
24-cube-rotation alignment, Success Rate). The plan that drives this
work is at `CRAFT_zerotocad_eval_plan.md` at the repo root.

## Layout

```
Experimentation/zerotocad_eval/
├── fetch_ztc_test.py            HF streaming → per-sample folders
├── score_sample.py              one (method, sample) → metrics.json
├── run_eval.py                  top-level orchestrator (Phases 4-7)
├── run_ablations.sh             Phase 6 — four ablation runs
├── voxel_iou/                   primary metric (Z2C's metric)
│   ├── score.py
│   └── test_voxel_iou.py        4 sanity tests; runs without API calls
├── cd/                          wraps existing aligned-CD scorer
├── metrics/                     success rate + editability
├── runners/                     per-method generators
│   ├── run_craft.py
│   ├── run_gpt5_baseline.py
│   ├── run_their_qwen.py
│   └── _common.py
├── data/{benchmark}/{uuid}/     INPUT data (gitignored — fetch on demand)
└── README.md                    you are here
```

## Five-step playbook

```bash
# 0. one-time deps (CRAFT env already has most of these)
pip install datasets pillow tqdm trimesh scipy
# for the GPT-5.2 baseline:
pip install openai
# for Their model:
pip install 'transformers>=4.45' torch
# for CadQuery STL execution:
pip install cadquery   # or: mamba install -c conda-forge cadquery

# 1. pull the test split (only what we need; ~3-4 GB on disk)
python -m Experimentation.zerotocad_eval.fetch_ztc_test --limit 5     # smoke
python -m Experimentation.zerotocad_eval.fetch_ztc_test --limit 50    # pilot
python -m Experimentation.zerotocad_eval.fetch_ztc_test               # full 10K

# 2. verify the scorer (no API calls)
python -m Experimentation.zerotocad_eval.voxel_iou.test_voxel_iou

# 3. pilot — 50 samples per method, decision gate at ABC Success ≥70%
export OPENAI_API_KEY=...
python -m Experimentation.zerotocad_eval.run_eval \
    --phase pilot --benchmark ztc_test \
    --methods craft_v3 gpt52_openscad gpt52_cadquery their_qwen \
    --score

# 4. headline — 1,000 samples per method (~$2K of OpenAI spend)
python -m Experimentation.zerotocad_eval.run_eval \
    --phase headline --benchmark ztc_test \
    --methods craft_v3 gpt52_openscad gpt52_cadquery their_qwen \
    --score

# 5. ablations — 4 CRAFT variants, 1K each
bash Experimentation/zerotocad_eval/run_ablations.sh ztc_test 1000

# (optional) stretch — full 10K. Only if headline shows clear wins.
python -m Experimentation.zerotocad_eval.run_eval \
    --phase stretch --benchmark ztc_test \
    --methods craft_v3 gpt52_openscad gpt52_cadquery their_qwen \
    --score
```

Summary tables land in `results/zerotocad_eval/metrics/{benchmark}/`,
ready to drop into `paper/cad_journal_2026/results_tables.md`.

## Metrics

| Metric | Implementation | Notes |
|---|---|---|
| Voxel IoU @ 64³ (24 cube rotations) | `voxel_iou/score.py` | Z2C's primary metric |
| Success Rate | `metrics/success_rate.py` | code executes + STL has faces + voxel count > 1 |
| Aligned Chamfer Distance | `cd/score.py` → existing `Experimentation/Chamfer_distance/` | finer-grained cross-check |
| Editability | `metrics/editability.py` | parameter refs / (refs + literals) |

## CRAFT changes that landed for this eval

Phase 2 added a new image-only entry point that doesn't disturb the
existing UI flow:

- `pipeline/core/vision.py` — new `ZEROTOCAD_8VIEW_PROMPT` + new method
  `VisionAnalyzer.analyze_zerotocad_8view()`.
- `pipeline/core/gap_refiner.py` — new `GAP_ANALYSIS_PROMPT_VIEWS` +
  new `input_view_paths` parameter on `GapRefiner.run()`.
- `pipeline/app.py` — new `PipelineState.input_view_paths` field; new
  `CRAFTPipeline.run_zerotocad_vision(image_paths)` method;
  `_run_v3_refinement` now threads input views through to the gap refiner.
- `pipeline/core/smooth_surface_optimizer.py` — new `CRAFT_DISABLE_NURBS`
  env toggle for the NURBS-ablation run.

The existing `run_text()`, `run_vision()`, `run_single_image()` entry
points are unchanged and the Flask UI still routes through them.
