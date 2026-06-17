# CRAFT Rebuttal — Experiment Record for Verification

**Purpose.** This document records every experiment run for the CRAFT rebuttal, *why* each was run (mapped to the reviewers' requests), how the datasets compare, and exactly how each pipeline agent was isolated in the ablation (the code flags). It is intended for the professor to verify the experimental design and results before the paper revision is written.

All numbers below are from the fresh re-run (June 2026) on the lab PC, computed from the per-sample metric JSONs in `metrics/`.

---

## 1. What the reviewers asked for

Three reviewers (all rated **7 / accept**) converged on the same gaps. De-duplicated, they asked for:

| # | Reviewer request | Raised by |
|---|---|---|
| R1 | **Ablation** isolating each component (JSON-IR, retrieval, multi-view, verification, recovery) | Awu5, UJGD, GyxV |
| R2 | **Stronger / fairer baselines** — direct GPT + repair, GPT + visual feedback, and a version with the *same number of LLM calls* as CRAFT ("is it just more compute?") | Awu5 |
| R3 | **Quantify editability** — exposed parameters, edit success rate, validity after edits | Awu5 |
| R4 | **Per-stage failure / recovery statistics** ("robustness" made quantitative) | UJGD, GyxV |
| R5 | **Statistical significance testing** of metric differences | GyxV |
| R6 | **Explain** why CRAFT does not always beat direct generation (esp. F1) | GyxV, UJGD |
| R7 | Clarify "Overall" FID; fix typos; move ablation into the main paper | Awu5 |

Every item R1–R5 is an **experiment** (done, except R2 in progress). R6–R7 are **writing**, now supported by the data below.

---

## 2. The CRAFT pipeline (needed to read the ablation)

CRAFT is a six-stage agent pipeline. Each stage is a separately-controllable component:

| Stage | Agent (code) | Role |
|---|---|---|
| 1. Understanding | `TextReasoner` | Parse prompt → design brief; **retrieve** matching NopSCADlib components (KB) + dimensional matching |
| 2. Planning | `Planner` | Produce the **JSON-IR** plan (preserves symbolic parametric expressions) |
| 3. Compilation | `Compiler` | JSON-IR → OpenSCAD source |
| 4. Rendering | `OpenScadRunner` | Render multi-view images / export STL |
| 5. Visual correction | `VisualSelfCorrector` | **Multi-view VLM** assessment + correction |
| 6. Component verification | `ComponentVerifier` | Check expected parts are present; fix if missing |

Across stages, a **5-layer recovery** strategy runs under a shared 10-attempt budget: `schema_repair`, `scad_autofix`, `vlm_correction`, `component_verification`, `manual_repair`.

---

## 3. Datasets and the in-domain vs. out-of-domain comparison

| Dataset | N | Role | KB / retrieval |
|---|---|---|---|
| **NopSCADlib** | 468 (Simple 159 / Medium 160 / Complex 149) | Primary benchmark — a real OpenSCAD mechanical component library that CRAFT retrieves from | **ON** (in-domain) |
| **ABC** | 100 | External CAD parts (Onshape-derived) not in the library | **OFF** (out-of-domain) |
| **Slice-100K** | 100 | External CAD dataset, also unseen | **OFF** (out-of-domain) |

**Why three datasets, and why this matters for the comparison:** NopSCADlib tests the *complete* system in-domain (retrieval active). ABC and Slice-100K test whether the **pipeline generalizes without retrieval** — by design, `run_external.py` runs CRAFT with `use_kb=False`, because those components are not in NopSCADlib and cannot be retrieved. This is why the external runs show **0 KB matches**: it is intentional, and it isolates the contribution of CRAFT's structured generation + correction from the retrieval library. Strong external results therefore demonstrate generalization, which the reviewers valued.

---

## 4. Metrics and why each was chosen

| Family | Metrics | Why / which reviewer point |
|---|---|---|
| **Perceptual** | CLIP score, FID | Rendered-image alignment to ground truth (existing in paper) |
| **Geometric** | Chamfer Distance (CD, normalized to unit cube), F1@1% & F1@5% (point precision/recall at 1%/5% of extent), Voxel IoU (res 64) | 3D shape fidelity vs. GT mesh (existing; the F1 question is R6) |
| **Editability (new)** | Exposed parameter count, symbolic-preservation rate, edit-success rate, post-edit render validity | **R3** — quantifies the paper's central claim |
| **Recovery (new)** | Per-layer trigger rate, mean retries, post-recovery success rate | **R4** — "robustness" made quantitative |
| **Statistics (new)** | Bootstrap 95% CIs; paired Wilcoxon, Benjamini–Hochberg corrected | **R5** — significance of every difference |

---

## 5. The experiments

### Experiment 1 — Main benchmark (CRAFT vs. GPT-4o vs. GPT-5.2)
**Why:** baseline comparison across all three datasets (existing claim; foundation for everything).
**How:** `run_craft.py` (NopSCADlib, KB on) and `run_external.py` (ABC, Slice-100K, KB off) generate SCAD→STL→PNG for CRAFT and the two single-shot GPT baselines.
**Result (NopSCADlib, n≈465):**

| Method | CLIP ↑ | FID ↓ | CD ↓ | F1@1% ↑ | F1@5% ↑ | Voxel IoU ↑ |
|---|---|---|---|---|---|---|
| **CRAFT** | **0.2226** | **95.11** | **0.0654** | 0.2533 | **0.6262** | **0.2361** |
| GPT-4o | 0.2033 | 119.42 | 0.0733 | 0.2464 | 0.5716 | 0.2118 |
| GPT-5.2 | 0.2145 | 106.22 | 0.0663 | 0.2585 | 0.6052 | 0.1889 |

External (geometric): **ABC** — CRAFT best on CD/F1/IoU (clean sweep). **Slice-100K** — CRAFT best on CD and F1, GPT-4o edges IoU.

### Experiment 2 — Ablation study (5 variants × 468)  → **R1**
**Why:** isolate the contribution of each agent; answer "is it just more LLM calls / which part actually helps?"
**How:** `run_ablations.py` calls `run_craft.py` once per variant with a single component disabled (flag table in §6), writing to `results/nopscadlib/ablations/<variant>/`. All 8 models (CRAFT + 2 baselines + 5 ablations) are scored in **one** `geometric.py` call so the table is internally consistent.
**Result (CD ↓ / F1@1% ↑ / Voxel IoU ↑), with paired Wilcoxon vs. CRAFT:**

| Variant | CD | F1@1% | Voxel IoU | Significant vs CRAFT? |
|---|---|---|---|---|
| **CRAFT (full)** | 0.0654 | 0.2533 | 0.2361 | — |
| no_retrieval | 0.0764 | 0.2028 | 0.1553 | **CRAFT better on all 3 (sig)** |
| no_multiview | 0.0738 | 0.1911 | 0.2279 | CRAFT better; CD & F1 sig |
| no_recovery | 0.0773 | 0.1878 | 0.2289 | CRAFT better; CD & F1 sig |
| no_json_ir | 0.0642 | 0.2386 | 0.2009 | only IoU sig for CRAFT |
| no_verification | 0.0637 | 0.2575 | 0.2390 | **verification removal *improves* CD (sig, p=0.012)** |

**Reading:** removing the **knowledge base (retrieval) hurts the most and significantly on every metric** — this is the core of CRAFT and the result is unambiguous. Multi-view and recovery also significantly help CD/F1. Two honest caveats are documented in §8.

### Experiment 3 — Editability quantification  → **R3**
**Why:** the paper's central claim (editable parametric CAD) was only qualitative (Fig. 3). Reviewer asked to quantify it.
**How:** `compute_editability.py` parses each SCAD's exposed parameters, perturbs them (±10%, ±50%), re-renders, and measures whether structure survives.
**Result:**

| Method | Exposed params | Symbolic preservation | Edit success | Post-edit render valid |
|---|---|---|---|---|
| **CRAFT** | **13.1** | **66.8%** | 99.9% | 99.1% |
| GPT-5.2 | 4.2 | 47.7% | 99.2% | 97.7% |
| GPT-4o | 0.1 | 3.0% | 95.0% | 95.0% |

Per-tier symbolic preservation for CRAFT widens with complexity: **Simple 59.2% → Medium 63.9% → Complex 78.1%**. This is CRAFT's most decisive, defensible advantage.

### Experiment 4 — Per-stage recovery statistics  → **R4**
**Why:** quantify "robustness"; report per-stage behavior and cost.
**How:** `aggregate_recovery.py` reads the per-sample recovery telemetry instrumented in `run_craft.py`.
**Result (NopSCADlib):**

| Recovery layer | Trigger rate | Mean retries | Post-recovery success |
|---|---|---|---|
| schema_repair | 0.072 | 1.00 | 1.000 |
| scad_autofix | 0.007 | 1.00 | 1.000 |
| vlm_correction | 0.804 | 1.62 | 0.503 |
| component_verification | 0.173 | 1.61 | 0.000 |
| manual_repair | 0.000 | — | — |

### Experiment 5 — Statistical significance  → **R5**
**Why:** reviewers asked whether observed gaps are meaningful.
**How:** `bootstrap_ci.py` (1000-resample 95% CIs) and `paired_tests.py` (paired Wilcoxon, BH-corrected) on the per-sample metric data.
**Key result — CRAFT vs. baselines (NopSCADlib):**

| vs | CD | F1@1% | F1@5% | Voxel IoU |
|---|---|---|---|---|
| GPT-4o | CRAFT (sig) | tie | CRAFT (sig) | CRAFT (sig) |
| GPT-5.2 | tie | tie (p=0.94) | tie | CRAFT (sig) |

**This directly answers R6:** the F1 "underperformance" the reviewers flagged is **not statistically significant** (vs the strongest baseline, p=0.94). CRAFT is **never significantly worse than any baseline on any geometric metric**, and significantly better on several.

### Experiment 6 — Matched-effort baselines  → **R2**  *(remaining)*
**Why:** answer "is CRAFT's advantage just more LLM calls?" — the one experiment still to run.
**Variants:** `direct_repair` (GPT one-shot + auto-fix), `direct_vlm` (GPT one-shot + VLM correction), `direct_matched_calls` (GPT invoked N times = CRAFT's mean call count, keep best). Commands in §7.

---

## 6. How each agent was isolated — the ablation flags

The runner `CRAFTBenchmarkRunner.__init__` exposes four booleans (`use_kb`, `use_json_ir`, `use_vlm`, `use_verify`, all default `True`). `run_ablations.py` maps each variant to a CLI flag on `run_craft.py`, which flips exactly one:

| Variant | CLI flag | Runner setting | Component removed | Code mechanism |
|---|---|---|---|---|
| **CRAFT (full)** | *(none)* | all `True` | none | full 6-stage pipeline |
| **no_retrieval** | `--no-kb` | `use_kb=False` | Stage 1 retrieval + dimensional matcher | `TextReasoner(use_kb=False)` → `design_brief.kb_components` stays empty; no component injected into the compiler prompt |
| **no_json_ir** | `--no-json-ir` | `use_json_ir=False` | Stages 2–3 (Planner + Compiler) | `run_single` calls `_direct_codegen()` — a single LLM call text→SCAD, bypassing JSON-IR planning/compilation; recorded as `json_ir_bypassed=True` |
| **no_multiview** | `--no-vlm` | `use_vlm=False` | Stage 5 visual correction | `VisualSelfCorrector` never instantiated; the VLM-correction loop is skipped |
| **no_verification** | `--no-verify` | `use_verify=False` | Stage 6 component verification | `ComponentVerifier` never instantiated; the verify-and-fix loop is skipped |
| **no_recovery** | `--no-recovery` | `use_vlm=False`, `use_verify=False`, + schema/autofix off | all recovery layers | disables VLM + verifier *and* the schema-repair / SCAD-autofix layers; only the bare generate→render→export path remains |

Each variant writes to its own `results/nopscadlib/ablations/<variant>/results.json`, so the comparison is one-component-at-a-time against the identical full pipeline.

**Verification of correct isolation** (from the run logs): `no_retrieval` shows zero KB matches across all 468; `no_multiview` shows no `[VLM Correction]` blocks; `no_verification` shows no `[Component Verifier]` blocks; `no_json_ir` records `json_ir_bypassed=True` on every sample; `no_recovery` shows neither correction loop and is ~3× faster per sample.

---

## 7. Step-by-step to complete the remaining experiment (matched-effort)

Each terminal first: `conda activate text2cad`, `$env:PYTHONUTF8="1"`, confirm `openscad --version`.

**(a) Smoke each variant (5 samples):**
```powershell
python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --variants direct_repair --limit 5
python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --variants direct_vlm --limit 5
python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --variants direct_matched_calls --limit 5
```
**(b) Compute CRAFT's mean LLM-call count for `direct_matched_calls`:**
```powershell
python -c "import json; rs=json.load(open('results/nopscadlib/craft/results.json'))['results']; c=[r.get('recovery_budget',{}).get('used',0)+3 for r in rs if r.get('success')]; print(round(sum(c)/len(c),1))"
```
**(c) Full runs (parallel terminals; ~overnight):**
```powershell
python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --variants direct_repair
python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --variants direct_vlm
python experiments/02_benchmark/run_matched_effort.py --dataset nopscadlib --variants direct_matched_calls --matched-calls 5
```
*(CRAFT's measured mean = 4.7 LLM calls/sample → matched-calls = 5. The baseline makes exactly 5 one-shot generations and keeps the best validator-scored candidate, so it gets the same compute budget as CRAFT.)*
**(d) Post-processing (no API):**
```powershell
python scripts/decimate_big_stls.py
# ONE geometric run with ALL 11 models (craft + 2 baselines + 5 ablations + 3 matched-effort):
python experiments/03_metrics/_shared/geometric.py --gt-dir ground_truth/nopscadlib/stl --models craft=results/nopscadlib/craft/stl gpt4o=results/nopscadlib/baselines/gpt4o/stl gpt52=results/nopscadlib/baselines/gpt52/stl no_json_ir=results/nopscadlib/ablations/no_json_ir/stl no_retrieval=results/nopscadlib/ablations/no_retrieval/stl no_multiview=results/nopscadlib/ablations/no_multiview/stl no_verification=results/nopscadlib/ablations/no_verification/stl no_recovery=results/nopscadlib/ablations/no_recovery/stl direct_repair=results/nopscadlib/matched_effort/direct_repair/stl direct_vlm=results/nopscadlib/matched_effort/direct_vlm/stl direct_matched_calls=results/nopscadlib/matched_effort/direct_matched_calls/stl --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json --output-dir metrics/nopscadlib
Copy-Item metrics/nopscadlib/summaries.json metrics/nopscadlib/chamfer/summaries.json -Force
python experiments/04_statistics/bootstrap_ci.py --dataset nopscadlib
python experiments/04_statistics/paired_tests.py --dataset nopscadlib --reference craft
python experiments/06_tables_and_figures/generate_all_tables.py --all
git add -A; git commit -m "Phase 4: matched-effort baselines + Table VII"; git push
```

---

## 8. Honest caveats the professor should see (and the paper must reflect)

1. **`no_verification` significantly *improves* CD (p=0.012).** Component verification adds/fixes parts to satisfy the prompt, which can move the surface away from the GT. Its contribution is **semantic completeness / part-presence**, not chamfer distance — and its post-recovery success rate is 0.000 (it rarely achieves a full pass). The paper must **not** claim verification improves geometric metrics; frame it as completeness, and state the small CD trade-off explicitly.
2. **`no_json_ir` is geometrically weak** — only Voxel IoU significantly favors CRAFT (CD/F1 are noise). The JSON-IR's primary value is **editability** (Experiment 3), where its symbolic structure is what produces CRAFT's 13.1 exposed parameters; that is the honest place to argue for it, not geometry.
3. **Geometry is "tied or better, never significantly worse."** Do not claim geometric dominance. CRAFT's significant, decisive wins are **editability, perceptual (CLIP/FID), the retrieval ablation, and IoU**. Framing it this precisely converts the reviewers' "overstating" critique into a strength.

---

## 9. Status summary

| Item | Status |
|---|---|
| Main benchmark, all 3 datasets | ✅ done |
| Ablation (5 variants) + significance | ✅ done |
| Editability metrics | ✅ done |
| Recovery / per-stage statistics | ✅ done |
| Statistical significance (bootstrap + Wilcoxon) | ✅ done |
| Matched-effort baselines (3 variants) | ⏳ remaining (§7) |
| Paper writing: F1 explanation, FID clarification, ablation→main, typos, honest framing | 📝 data ready; writing remains |
