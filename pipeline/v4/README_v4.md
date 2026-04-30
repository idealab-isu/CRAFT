# CRAFT v4 — GPT-5.2-baseline-first pipeline

v4 is a deliberate inversion of v1. Instead of decomposing generation into
six stages with a JSON IR, v4 treats GPT models as the engine and adds a
verification + repair layer around them. A non-regression gate guarantees
v4 ≥ best-baseline on every sample (in expectation, modulo proxy noise).

```
prompt
  → Stage 0: parallel baselines (default gpt-5.2 + gpt-4o, parametric prompt)
  → Stage 1: render 8 views + STL for EACH baseline
  → Stage 2: deterministic sanity check on each
  → Stage 3: optional KB reference (high-confidence only, never essential_parts)
  → Stage 4: VLM gap assessment for each surviving baseline
  → Stage 4a: pick BEST baseline by criteria pass + render validity
  → Stage 5: ONE targeted patch from the chosen baseline (no iterative drift)
  → Stage 6: re-render patched output
  → Stage 7: non-regression gate (keep patched only if criteria pass count
             strictly increases AND no new render failures introduced)
```

**Why two baselines.** Empirically (see your existing `cd_summary.md`):
gpt-4o wins on simple primitive geometry (bearings, washers, nuts, basic
LEDs — pattern-matching beats reasoning), gpt-5.2 wins on complex
assemblies (motors, displays, brackets — reasoning beats pattern). An
oracle over `{gpt-4o, gpt-5.2}` is meaningfully better than either alone,
and the gate's inference-only selection rules can capture most of that
gap without ground truth.

Critically, the gate uses **inference-only signals** — never ground-truth
metrics. A separate oracle ablation reports the upper bound by replacing
the gate with a ground-truth-CD selector, but that number is reported as
ablation, never as the deployable result.

---

## 1. File layout

```
pipeline/v4/
├── __init__.py
├── baseline_generator.py     # Stage 0
├── render_check.py           # Stage 1+2 + 6 (rendering + sanity)
├── kb_reference.py           # Stage 3 (informational hint, never required)
├── gap_assessor.py           # Stage 4 / 4b
├── patcher.py                # Stage 5 (single shot, always from baseline)
├── regression_gate.py        # Stage 7
├── runner.py                 # End-to-end orchestrator
├── cli.py                    # python -m pipeline.v4.cli ...
├── smoke_test.py             # python -m pipeline.v4.smoke_test
└── README_v4.md              # this file

pipeline/evaluation/
├── run_v4_benchmark.py       # benchmark runner (NopSCADlib + ext datasets)
├── run_v4_oracle_ablation.py # ground-truth-CD oracle (separate, ablation only)
└── compute_chamfer_v4.py     # CD / F1 / IoU comparison across methods
```

---

## 2. Setup

```bash
cd CRAFT
export OPENAI_API_KEY=sk-...

pip install -r pipeline/requirements.txt
```

Smoke test (no network calls — verifies imports + gate logic):

```bash
cd pipeline
python -m v4.smoke_test
```

You should see five `OK` lines and a final `OK — all smoke checks passed.`

---

## 3. Run on a single prompt

The CLI is the simplest entry point. Each invocation creates one
output directory under `--out`:

```bash
cd pipeline
python -m v4.cli \
    --prompt-id demo01 \
    --prompt "An M8 flat washer with 16mm OD, 8.4mm ID, 1.6mm thick" \
    --out ./v4_out
```

This produces:

```
v4_out/demo01/
├── baseline.scad
├── baseline.stl
├── baseline_views/baseline_front.png ... baseline_iso3.png
├── patched.scad                   # only if a patch ran
├── patched.stl
├── patched_views/...
├── final.scad                     # whichever the gate chose
├── final.stl
├── final_views/
└── audit.json                     # full machine-readable audit
```

`audit.json` records every stage decision: KB firing, criteria pass counts
on baseline vs. patched, the gate's reason string, all errors. This is the
file you grep when debugging.

Useful flags:

| Flag                  | Effect                                                                  |
|-----------------------|-------------------------------------------------------------------------|
| `--no-kb`             | Disable KB reference lookup entirely (fastest, fewest variables).       |
| `--no-patch`          | Run baselines + assess only, skip patcher. "No-repair" ablation.        |
| `--baseline-models`   | Stage-0 generators raced in parallel. Default: `gpt-5.2 gpt-4o`.        |
| `--baseline-model`    | (legacy) Single model — overrides `--baseline-models` if set.           |
| `--assessor-model`    | Override Stage 4 vision model.                                          |
| `--patcher-model`     | Override Stage 5 model.                                                 |
| `--sketch <path>`     | Pass a reference image to Stage 4 for visual gap detection.             |

---

## 4. Run on the full benchmark

### 4.1 v2 ground-truth benchmark (canonical 30 prompts) — DEFAULT

This is the right benchmark for paper-comparable numbers. Prompts come
from `Experimentation/GroundTruth/benchmark_ground_truth_v2.json` (485
curated components with hand-authored prompts and known ground-truth
SCAD/STL). By default v4 restricts to the same 30 IDs that produced the
existing `Experimentation/Chamfer_distance/results/cd_summary.md`, so
v4's column slots into that table directly.

```bash
cd pipeline

# Default: canonical 30 prompts from v2 (same set as published cd_summary.md)
python -m evaluation.run_v4_benchmark --source v2 \
    --out-dir ../results/v4 --dataset-name v2

# Pick a different N stratified by tier:
python -m evaluation.run_v4_benchmark --source v2 --all \
    --tier Simple,Medium --n-prompts 30 --seed 42 \
    --out-dir ../results/v4 --dataset-name v2_simple_med30

# Restrict to specific IDs:
python -m evaluation.run_v4_benchmark --source v2 \
    --ids ball_bearing__BB608 nut__M2_nut led__LED10mm \
    --out-dir ../results/v4 --dataset-name v2_handpicked
```

The tier mix of the canonical 30 is 10 Simple / 7 Medium / 13 Complex.

### 4.2 NopSCADlib (in-pipeline prompts) — legacy

```bash
cd pipeline
python -m evaluation.run_v4_benchmark --source nopscadlib \
    --out-dir ../results/v4 --dataset-name nopscadlib
```

Output layout (matches the rest of CRAFT so existing metric scripts find
it automatically):

```
results/v4/nopscadlib/v4/
├── scad/<id>.scad              ← chosen final SCAD
├── stl/<id>.stl                ← chosen final STL
├── png/<id>.png                ← isometric view
├── runs/<id>/                  ← full per-prompt artifacts (baseline, patched, audit)
└── results.json                ← summary across the dataset
```

Resume support: rerunning the same command skips prompts whose
`runs/<id>/audit.json` exists. Pass `--force` to redo them.

### 4.3 ABC and Slice-100K (external ground-truth JSONs)

These datasets use the ground-truth JSON produced by
`evaluation/ext_step2_generate_ground_truth.py`:

```bash
# ABC
python -m evaluation.run_v4_benchmark \
    --source ext \
    --benchmark-json ../evaluation/abc_ground_truth.json \
    --dataset-name abc \
    --out-dir ../results/v4

# Slice-100K
python -m evaluation.run_v4_benchmark \
    --source ext \
    --benchmark-json ../evaluation/slice100k_ground_truth.json \
    --dataset-name slice100k \
    --out-dir ../results/v4
```

Restrict to specific prompt IDs with `--ids id_001 id_002 ...`.

---

## 5. Compare against baselines (aligned Chamfer Distance)

**The headline-number scorer is `Experimentation/Chamfer_distance/run_eval.py`.**
That script is what produced the published `craft / gpt52 / gpt4o` numbers
— 10 000 surface points, unit bounding-sphere normalisation, PCA
canonicalisation, 24 cube-rotation initialisations, ICP refinement, the lot.
v4 must be scored through the same pipeline or the comparison isn't honest.

There are two ways to run it:

### 5a. (recommended) Run `run_eval.py` directly

```bash
cd Experimentation/Chamfer_distance

# stage v4 STLs into the directory layout run_eval.py expects
mkdir -p stls/v4
cp ../../results/v4/<dataset>/v4/stl/*.stl stls/v4/

# run; defaults are 10k points + ICP on, matching prior runs
python run_eval.py --methods craft gpt52 gpt4o v4
```

Outputs land in `Experimentation/Chamfer_distance/results/`:

- `cd_results.json` — per-example aligned + raw CDs.
- `cd_summary.md` — markdown table for the paper.

### 5b. (alternative) `compute_chamfer_v4.py` — same scorer, no staging

When the prediction STLs are already organised under
`<root>/<method>/stl/<id>.stl` and you'd rather not copy them, this thin
wrapper imports `score_stl_pair` from `align_and_score.py` and runs it
across multiple methods at once:

```bash
cd pipeline

python -m evaluation.compute_chamfer_v4 \
    --gt-dir ../results/abc/ground_truth/stl \
    --results-root ../results/abc \
    --methods gpt4o gpt52 craft v4 \
    --dataset abc \
    --out ../results/abc/v4_metrics.json
```

The wrapper accepts either `<method>/stl/<id>.stl` or `<method>/<id>.stl`.
Defaults: `--n-points 10000`, ICP on, seed 42 — matching `run_eval.py`.

For v4 outputs from `run_v4_benchmark.py`, symlink the STL directory:

```bash
mkdir -p ../results/abc/v4
ln -s "$(pwd)/../results/v4/abc/v4/stl" ../results/abc/v4/stl
```

Sample console output:

```
=== Aligned Chamfer Distance (lower is better) ===
method         N    CD↓ aligned       CD raw
------------------------------------------------
gpt4o         98       0.06120      0.18211
gpt52         98       0.05883      0.17042
craft         98       0.05420      0.16205
v4            98       0.04915      0.15388
```

Both 5a and 5b produce numbers comparable to the existing `cd_summary.md`
in the repo because they share the same `align_and_score.py` core.

---

## 6. Step-by-step recipe — baseline → v4 → Chamfer comparison

The end-to-end recipe for one dataset (NopSCADlib used as the example —
the same flow applies to ABC and Slice-100K with the `--source ext`
variant from §4.2).

### Step 1 — Verify environment

```bash
cd CRAFT
export OPENAI_API_KEY=sk-...
which openscad                # must exist on PATH
python -c "import trimesh, scipy, numpy"   # required by metric scripts
```

### Step 2 — Smoke-test v4

```bash
cd pipeline
python -m v4.smoke_test
```

Expect `OK — all smoke checks passed.`

### Step 3 — (skip if you already have them) Generate craft / gpt52 / gpt4o on the same v2 IDs

The existing `cd_summary.md` was built from STLs in
`Experimentation/Chamfer_distance/stls/{craft,gpt52,gpt4o,ground_truth}/`.
If those directories are still populated from prior runs, **skip this step**.

If you need to rebuild them, the cleanest path is the existing in-pipeline
NopSCADlib runner — but note its prompts are NOT the same set as the v2
canonical 30. To stay apples-to-apples on the v2 IDs you'd need to point a
baseline runner at `benchmark_ground_truth_v2.json` and the canonical IDs
discovered from `stls/ground_truth/`. Easiest: just keep your existing
craft / gpt52 / gpt4o STLs from the prior run that produced cd_summary.md.

### Step 4 — Generate v4 on the canonical 30 v2 prompts

```bash
cd pipeline
python -m evaluation.run_v4_benchmark --source v2 \
    --out-dir ../results/v4 --dataset-name v2
```

This loads `Experimentation/GroundTruth/benchmark_ground_truth_v2.json`,
auto-detects the 30 IDs already in
`Experimentation/Chamfer_distance/stls/ground_truth/`, and runs v4 on
exactly that set. Outputs land at `results/v4/v2/v4/{scad,stl,png,runs}/`.

The benchmark runner prints a tier mix and a per-baseline-model win
tally at the end so you can see how often gpt-4o beat gpt-5.2 on this
set before scoring.

Inspect a few `runs/<id>/audit.json` files to spot-check gate decisions
before computing metrics. You want to see things like:

```json
{
  "chosen": "patched",
  "gate_reason": "patched passes more criteria (2 -> 4)",
  "baseline_criteria_pass": 2,
  "patched_criteria_pass": 4,
  ...
}
```

If you see lots of `"chosen": "baseline"` with `"gate_reason": "patched did
not strictly improve criteria"`, that's expected — it means baseline was
already good and the gate correctly refused to gamble on a patch.

### Step 5 — Stage v4 STLs for `run_eval.py` and compute aligned CD

`Experimentation/Chamfer_distance/run_eval.py` is the canonical scorer
(10 000 points, PCA + 24 rotations + ICP). Stage v4 outputs under
`Experimentation/Chamfer_distance/stls/v4/` and let the existing
gpt4o / gpt52 / craft / ground_truth folders provide the rest:

```bash
cd /Users/mohd7/Local/CRAFT/Experimentation/Chamfer_distance
mkdir -p stls/v4
cp /Users/mohd7/Local/CRAFT/results/v4/v2/v4/stl/*.stl stls/v4/

# Sanity: every method should have the same set of stems
ls stls/ground_truth | wc -l    # 30
ls stls/v4 | wc -l              # should also be 30

python run_eval.py --methods craft gpt52 gpt4o v4
```

Outputs:

- `Experimentation/Chamfer_distance/results/cd_results.json` —
  per-example aligned + raw CDs.
- `Experimentation/Chamfer_distance/results/cd_summary.md` —
  markdown table for the paper / quick read.

This is the same scorer that produced your existing published numbers, so
v4's column is directly comparable to the prior `craft / gpt52 / gpt4o`
columns — no apples-to-oranges risk.

### Step 6 — (alternative) `compute_chamfer_v4.py`

If you don't want to copy STLs into `Experimentation/Chamfer_distance/stls/`,
you can call `compute_chamfer_v4.py` instead. It imports `score_stl_pair`
from `align_and_score.py` so the maths is identical:

```bash
cd pipeline

# Symlink methods into one comparison root
mkdir -p ../results/nopscadlib_v4_compare
cd ../results/nopscadlib_v4_compare
ln -s "$(pwd)/../../pipeline/evaluation/nopscadlib_benchmark/<timestamp>/gpt4o/stl" gpt4o/stl
ln -s "$(pwd)/../../pipeline/evaluation/nopscadlib_benchmark/<timestamp>/gpt52/stl" gpt52/stl
ln -s "$(pwd)/../../pipeline/evaluation/nopscadlib_benchmark/<timestamp>/craft/stl" craft/stl
ln -s "$(pwd)/../v4/nopscadlib/v4/stl" v4/stl
ln -s "$(pwd)/../../pipeline/evaluation/nopscadlib_benchmark/<timestamp>/stl" gt

cd ../../pipeline
python -m evaluation.compute_chamfer_v4 \
    --gt-dir ../results/nopscadlib_v4_compare/gt \
    --results-root ../results/nopscadlib_v4_compare \
    --methods gpt4o gpt52 craft v4 \
    --dataset nopscadlib \
    --out ../results/nopscadlib_v4_compare/v4_metrics.json
```

### Step 7 — Run the oracle ablation (paper figure only)

This is the upper-bound figure — it is **not** the deployable system.
The oracle scorer also uses `align_and_score.score_stl_pair`, so its
CDs are comparable to the headline numbers.

```bash
cd pipeline
python -m evaluation.run_v4_oracle_ablation \
    --v4-dir ../results/v4/nopscadlib/v4 \
    --gt-dir /Users/mohd7/Local/CRAFT/Experimentation/Chamfer_distance/stls/ground_truth \
    --out-dir ../results/v4/nopscadlib/v4_oracle
```

Then re-run Step 5 with `v4_oracle` added to `--methods` (after staging
its STLs into `stls/v4_oracle/`). The CD gap between `v4` and `v4_oracle`
quantifies how much headroom your inference-only gate is leaving on the
table — that's the load-bearing empirical question discussed in §8.

---

## 7. Knobs that actually matter (and how to ablate them)

The paper write-up wants ablations on these levers. Each one corresponds to
a single CLI flag and produces a separate results directory; everything else
is held fixed.

| Flag                                        | What it ablates                                                |
|---------------------------------------------|----------------------------------------------------------------|
| `--no-patch` on `run_v4_benchmark.py`       | "Is the regression gate doing anything?" Compare to default.  |
| `--no-kb`                                   | "Does KB reference help?" Run with/without on the same dataset. |
| `--baseline-model gpt-4o`                   | "Does the architecture only work with GPT-5.2?"                |
| `--assessor-model gpt-4o`                   | "Does the gap assessor need a strong VLM?"                     |
| `run_v4_oracle_ablation.py`                 | "What's the ceiling if our gate were perfect?"                 |

Each ablation should write to `results/v4_<ablation>/<dataset>/v4/...` and
then be added as a column in the metrics table.

---

## 8. Why the regression gate is the load-bearing component

The whole architecture stands or falls on one empirical question:

> Do the inference-only signals (criteria pass count + render validity)
> agree with ground-truth Chamfer often enough that the gate keeps the
> right output?

The oracle ablation answers this directly. The number to look at in
`results/v4/<dataset>/v4_oracle/oracle_log.json` is:

```json
{
  "agreement_rate": 0.83,
  ...
}
```

If agreement is high (≥80%), the inference-only rule is doing the job and
v4 is genuinely robust. If it's low, you need a better proxy — at that
point the right move is to train a small classifier on a validation split
mapping (assessor outputs, sanity verdicts) → CD-improved-or-not, and
deploy that classifier as the gate. The oracle log gives you the labels.

This is the empirical work that decides whether v4 ships or whether the
regression rule needs another iteration.
