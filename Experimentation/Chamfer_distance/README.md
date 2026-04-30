# Chamfer Distance — aligned benchmark

Isolated experiment for comparing **CRAFT v2 (full pipeline)** vs
**GPT-5.2 (direct)** vs **GPT-4o (direct)** on a fixed set of 30 prompts,
with **pose- and scale-invariant Chamfer distance** against the NopSCADlib
ground-truth meshes.

## Why this exists

Raw Chamfer distance is unusable when different generators place the object in
different positions / orientations / scales — a 5×2×1 mm block rendered "laid
down" and "stood up" will score far from a GT that is 2×5×1. This pipeline
neutralizes those nuisance factors before computing CD, so the reported
number reflects actual shape fidelity.

## End-to-end workflow

```
(1) generate outputs          (2) (optional manual review)      (3) score
    prompts ──▶ GPT-4o direct ──▶ stls/gpt4o/*.stl  ─┐
            ──▶ GPT-5.2 direct ─▶ stls/gpt52/*.stl  ─┼─▶ run_eval.py ─▶ results/
            ──▶ CRAFT full     ──▶ stls/craft/*.stl  ─┤
    GT STLs copied from Experimentation/GroundTruth ──▶ stls/ground_truth/*
```

## Directory layout

```
Experimentation/Chamfer_distance/
├── benchmark/
│   ├── bench_utils.py          # prompt selection + GT STL copy
│   ├── run_gpt_baseline.py     # GPT-4o / GPT-5.2 direct baseline runner
│   └── run_craft.py            # full CRAFT v2 pipeline runner
├── stls/
│   ├── ground_truth/           # GT STLs (auto-populated from GroundTruth/stl)
│   ├── craft/                  # final CRAFT STLs, <id>.stl
│   ├── gpt52/                  # final GPT-5.2 STLs
│   └── gpt4o/                  # final GPT-4o STLs
├── runs/                       # per-method per-example artifacts
│   └── <method>/<id>/
│       ├── prompt.txt          # the exact bench prompt
│       ├── model.scad          # generated OpenSCAD
│       ├── model.stl           # exported STL
│       ├── sketch.png          # (CRAFT only) stage 1.5 sketch
│       ├── final_render.png    # (CRAFT only) post-correction render
│       └── state.json          # (CRAFT only) full pipeline state
├── results/
│   ├── cd_results.json         # written by run_eval.py
│   └── cd_summary.md
├── align_and_score.py          # CD pipeline (library)
├── run_eval.py                 # CD CLI
└── README.md
```

Filename stem convention: `<component_id>` from
`Experimentation/GroundTruth/benchmark_ground_truth_v2.json`, e.g.
`ball_bearing__BB608`. Every method uses this same stem so `run_eval.py` pairs
the files automatically.

## Step 0 — build the knowledge base (one-time)

CRAFT's reasoner, prompt-enhancer, and visual corrector all consume the
NopSCADlib RAG index at `pipeline/kb_data/`. If that index is missing the
pipeline silently degrades to KB-off behaviour, so **every CRAFT run
invalidates the KB ablation**. Build it once:

```bash
cd pipeline

# One-time (clones NopSCADlib, indexes 397 components, parses docs,
# copies ~150 reference images, and builds OpenAI embeddings in ChromaDB).
python scripts/build_knowledge_base.py

# Or, if NopSCADlib is already on disk (typical OpenSCAD users have
# ~/Documents/OpenSCAD/libraries/nopscadlib), symlink it first to skip
# the clone:
#   ln -s ~/Documents/OpenSCAD/libraries/nopscadlib pipeline/kb_data/nopscadlib
```

Expected output at the end:

```
Components indexed: 397
  ✓ Component index: Ready
  ✓ Reference images: Available
  ✓ Vector store: Available
```

Once built, `run_craft.py` verifies the KB is populated at startup (the
`[KB STATUS]` line) and fails with a clear message if it isn't — pass
`--no-kb` to explicitly run the ablation.

## Step 1 — generate the outputs (30 prompts × 3 models)

From the repo root:

```bash
cd Experimentation/Chamfer_distance

# GPT-4o direct baseline (no pipeline, just prompt -> SCAD -> STL)
python benchmark/run_gpt_baseline.py --model gpt-4o  --method gpt4o -n 30 --stratified

# GPT-5.2 direct baseline
python benchmark/run_gpt_baseline.py --model gpt-5.2 --method gpt52 -n 30 --stratified

# CRAFT v2 full pipeline (sketch + KB + VLM correction + component verification)
python benchmark/run_craft.py -n 30 --stratified
# ablations:
#   python benchmark/run_craft.py --no-sketch        # disable Stage 1.5
#   python benchmark/run_craft.py --no-kb            # disable RAG
```

The `--stratified` flag round-robins across component families (alphabetically)
so 30 prompts span 30 different families. The underlying benchmark JSON is
sorted alphabetically by family, so **without this flag** the first 30 items
are dominated by whatever family sorts first (17 ball_bearing + 9 batterie +
4 others in our dataset). Using `--stratified` is strongly recommended for
reporting numbers — it also produces a much more even tier mix (roughly equal
Simple / Medium / Complex).

Each runner also copies the matching GT STLs into `stls/ground_truth/` on the
first call, so you don't have to touch them manually.

## Step 2 — score with aligned Chamfer distance

```bash
python run_eval.py                         # default: 10k points, full alignment
python run_eval.py --no-icp                # PCA + 24 rotations only (faster)
python run_eval.py --n-points 20000        # denser sampling for final numbers
python run_eval.py --methods craft gpt52   # subset
```

Alignment pipeline applied to every pair (detailed in `align_and_score.py`):

1. Sample 10 000 points uniformly from each STL surface.
2. Centre at centroid, scale so max radius = 1 (unit bounding sphere).
3. PCA-canonicalize: rotate so principal axes align with world x, y, z.
4. Try all 24 proper rotations of the cube as ICP initializations.
5. Refine each with ICP (`trimesh.registration.icp`).
6. Report the minimum bidirectional Chamfer distance across starts.

CD is computed on unit-sphere-normalized clouds, so the reported number is
**unitless** and comparable across examples of very different physical sizes.

Outputs:
- `results/cd_results.json` — full per-example distances, raw CD, which
  rotation init won, and timing.
- `results/cd_summary.md` — markdown table (per-row best is **bold**, means
  at the bottom).

## Sanity check

Copy a ground-truth STL into one of the method folders under the same name;
its CD should come out at ~0 (sampling noise, ~1e-3 at 10 000 points). This
was verified during development with a 5×2×1 block rotated + translated — the
aligned CD was `0.00000` vs raw CD of `109.70`.

## Dependencies

Already in `pipeline/requirements.txt`:

- numpy ≥ 1.24
- scipy ≥ 1.11
- trimesh ≥ 4

Plus OpenSCAD on PATH (the runners call `openscad -o <out>.stl <in>.scad`).
