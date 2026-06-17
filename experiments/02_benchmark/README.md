# Phase 02 — Benchmark Runners

Generates CAD outputs (SCAD, STL, PNG, results.json) for every method on every
dataset. These are the LLM-call phase — expensive in time and API spend.

## Runners

| Script | What it runs | Datasets |
|---|---|---|
| `run_craft.py` | Full CRAFT pipeline (6 stages, 5 recovery layers) | NopSCADlib (468) |
| `run_direct_baselines.py` | GPT-4o and GPT-5.2 one-shot direct generation | NopSCADlib (468) |
| `run_external.py` | CRAFT + GPT-4o + GPT-5.2 on external datasets | ABC (100), Slice-100K (100) |
| `run_external_metrics.py` | Orchestrates Chamfer/F1/Voxel IoU on external datasets | ABC, Slice-100K |
| `run_ablations.py` *(Phase 0b)* | CRAFT with one component disabled per variant | all |
| `run_matched_effort.py` *(Phase 0b)* | Matched-effort baselines | all |

## Output layout

Every runner writes to the same shape:

```
results/<dataset>/<method>/
├── scad/<prompt_id>.scad
├── stl/<prompt_id>.stl
├── png/<prompt_id>.png
└── results.json
```

Where:

- `<dataset>` ∈ {`nopscadlib`, `abc`, `slice100k`}
- `<method>` ∈ {`craft`, `baselines/gpt4o`, `baselines/gpt52`, `ablations/<variant>`, `matched_effort/<variant>`}

`results.json` is a dict keyed by `prompt_id` with per-item fields:
`prompt_text, family, success, reasoner_ok, planner_ok, compiler_ok, render_ok,
vlm_ok, verify_ok, stl_ok, scad_path, stl_path, png_path, code, code_length,
kb_component_matched, kb_module_used, dimensional_match, *_time, total_time,
error`.

Per-stage recovery statistics (per-layer trigger flags, retry counts,
component verification pass/fail per tier) are added in Phase 0b.

## Reproducing

```bash
# NopSCADlib (468 prompts each)
python experiments/02_benchmark/run_craft.py
python experiments/02_benchmark/run_direct_baselines.py --model gpt4o
python experiments/02_benchmark/run_direct_baselines.py --model gpt52

# ABC + Slice-100K (100 prompts each, three methods each)
python experiments/02_benchmark/run_external.py --dataset abc      --models craft gpt4o gpt52
python experiments/02_benchmark/run_external.py --dataset slice100k --models craft gpt4o gpt52

# Ablations + matched effort (added in Phase 0b)
python experiments/02_benchmark/run_ablations.py     --variants no_json_ir no_retrieval no_multiview no_verification no_recovery
python experiments/02_benchmark/run_matched_effort.py --variants direct_repair direct_vlm direct_matched_calls
```

All runners support `--checkpoint` (resume after partial failure) and `--limit N`
(smoke-test on N samples) — see each script's `--help`.

## Configuration

Runners read `OPENAI_API_KEY` (and optional `GEMINI_API_KEY`) from the
environment or `.env`. Model assignments inside CRAFT (which model handles
which stage) are set in `pipeline/app.py` constants `MODEL_PIPELINE` and
`MODEL_VLM`.
