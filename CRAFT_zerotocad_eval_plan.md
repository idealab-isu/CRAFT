# CRAFT × Zero-to-CAD — Evaluation-Harness Plan

> **Purpose of this file.** Session-to-session handoff so work can resume in a new chat without re-explaining context. Drop this file into a new session and the assistant should be able to pick up where we left off. Keep it updated as decisions are made.

> **Authoring status.** Drafted between the researcher (Mohammed Musthafa Rafi, PhD CS, Iowa State) and an AI collaborator. Everything here is a proposal unless explicitly marked **DECIDED**.

> **Companion documents — read in this order at the start of any new session:**
> 1. This file (`CRAFT_zerotocad_eval_plan.md`) — current paper plan.
> 2. `pipeline/app.py` — current pipeline (CRAFT v3, single-pass refinement; this is what the paper uses).
> 3. `README.md` — CRAFT v1 overview and published numbers.
> 4. `Experimentation/Chamfer_distance/README.md` — current aligned-CD scorer; the new voxel-IoU scorer must coexist with this.
> 5. `CRAFT_v2_research_plan.md` (background only) — earlier dual-mode design; image-input ideas are referenced here but the v2 plan is *not* the architecture for this paper.
> 6. `pipeline/v4/README_v4.md` (background only) — alternative architecture; *not* used for this paper.

---

## 1. Context

**Project.** CRAFT — Corrective and Robust Multi-Agent Framework for Text-to-Parametric CAD.

**Current pipeline (the one we use for this paper).** `pipeline/app.py` exposes `CRAFTPipeline`, currently labeled **CRAFT v3** in the file's docstring. After a baseline plan → compile → render, it runs an intent sketch (if needed), six orthographic renders, *one* structured gap analysis vs. text/sketch, and *one* text-only OpenSCAD patch. This replaces v1's multi-iterate VLM correction loop. Toggled by `USE_VLM_CORRECTION`.

**What was added in the latest commit (your professor's work).**
- `core/nurbs_surfaces.py` (605 LOC) — NURBS surface generation, smooth profile revolution, smooth blob form, airfoil profile, tapered surface, fuselage, smooth vase / bottle / sculpture → all converted to OpenSCAD via `nurbs_surface_to_openscad`, `airfoil_wing_to_openscad`, `fuselage_to_openscad`, etc.
- `core/smooth_surface_optimizer.py` (301 LOC) — `detect_curved_surface_need`, `detect_aerodynamic_shape`, `get_smooth_surface_guidance`, `get_nurbs_enhancement_prompt`, `get_smooth_surface_code_pattern`, `get_nurbs_code_suggestion`. Detects when a prompt or shape needs curved surfaces and routes the planner to NURBS/smooth output.
- `core/progress.py` (197 LOC) — `ProgressTracker`, `PipelineStage`, `create_sse_progress_handler`. Used by app.py to stream pipeline progress.
- `core/planner.py` (+46) — accepts smooth-surface guidance.
- `core/compiler.py` (+1), `core/llm_client.py` (+7), `templates/index.html` (+294), `app.py` (+314).
- `test_gemini.py` (124 LOC) — Gemini support is now an option alongside OpenAI.

**Why these additions matter for the Zero-to-CAD comparison.** The Zero-to-CAD dataset is rich in lofts, sweeps, revolves, and shells — operations that naturally produce curved surfaces. Pure CSG-on-primitives in OpenSCAD struggles with these. The new NURBS / smooth-surface modules let CRAFT produce curved geometry that has historically been the weakest spot for OpenSCAD-target methods. This is a structural advantage that didn't exist in v1.

**Status.** Nothing has been submitted. All current results in `metrics/`, `results/`, and `Experimentation/Chamfer_distance/` are from prior in-house experiments. Target venue for the *next* submission is a **CAD journal** (timeline allows ~3–6 months of careful work).

---

## 2. The competing paper — Zero-to-CAD

*Zero-to-CAD: Agentic Synthesis of Interpretable CAD Programs at Million-Scale Without Real Data* — Ataei et al., Autodesk Research, arXiv:2604.24479, April 2026.

### What they did
- Built a 1M synthetic CadQuery dataset using gpt-oss-120b in an agentic loop (execute → validate → look up docs → repair).
- Two-stage synthesis: catalog (~200 part descriptions per call across 65 categories) → code (with 19 design principles + reference snippet + 3 tools).
- Validation: code executes + ≥7 B-Rep faces + single connected solid + STL/STEP export.
- 22.3% first-attempt success rate, 3.30 mean attempts, 4.34 mean function calls.
- Compute: ~1 week × 80 GPUs + 3,000 CPU cores; 60.2B input tokens, 5.59B output tokens.
- Curated a 100K subset using DINOv3 visual embeddings + k-means + nearest-to-centroid.
- Full-fine-tuned Qwen3-VL-2B-Instruct on the 1M (16× H100, 3 epochs, eff batch 16, LR 1e-4 uniform).

### What they shipped on HuggingFace (Apache 2.0)
- Model: `ADSKAILab/Zero-To-CAD-Qwen3-VL-2B`
- 1M dataset: `ADSKAILab/Zero-To-CAD-1m` (349 GB, train 979,633 / val 10,000 / test 10,000)
- 100K subset: `ADSKAILab/Zero-To-CAD-100k` (28 GB)
- FAISS index of DINOv3 embeddings + nearest-neighbor CSV

### Their published numbers — these are the rows we are slotting into

**Key Results table** (we add a "CRAFT" row as the third entry):

| Benchmark | Success Rate | Mean IoU | Median IoU | P90 IoU |
|---|---|---|---|---|
| Zero-to-CAD test | 82.1% | 0.747 | 0.847 | 0.999 |
| ABC (out-of-distribution) | 61.0% | 0.377 | 0.303 | 0.854 |
| **CRAFT — ZTC test** | **TBD** | **TBD** | **TBD** | **TBD** |
| **CRAFT — ABC OOD** | **TBD** | **TBD** | **TBD** | **TBD** |

**Comparison with Baselines table** (we add a CRAFT row as the fifth entry):

| Model | Zero-to-CAD Success | Zero-to-CAD Mean IoU | ABC Success | ABC Mean IoU |
|---|---|---|---|---|
| Their model (Qwen3-VL-2B fine-tuned) | 82.1% | 0.747 | 61.0% | 0.377 |
| GPT-5.2 High | 72.2% | 0.485 | 66.2% | 0.344 |
| GPT-5.2 Medium | 71.1% | 0.495 | 62.6% | 0.346 |
| Qwen3-VL-2B (base) | 6.6% | 0.184 | 5.4% | 0.131 |
| **CRAFT (this paper)** | **TBD** | **TBD** | **TBD** | **TBD** |

**The single most important fact from those numbers.** GPT-5.2 already beats their fine-tuned model on ABC Success Rate (66.2% vs. 61.0%). Their own paper concedes: *"GPT-5.2 degrades less from Zero-to-CAD to ABC than the fine-tuned Qwen model, suggesting that synthetic-to-real transfer remains challenging."* This is the opening for CRAFT.

---

## 3. The Plan (one-paragraph summary)

Use Zero-to-CAD's **evaluation harness** as the testbed. Inputs: their 8 multi-view PNG renders (4 front + 4 rear, 256×256) per shape, taken straight from the published test split. Method: **CRAFT v3** running through the OpenAI / Gemini API with no fine-tuning and no local model — the pipeline already in `pipeline/app.py`, exposed via `CRAFTPipeline.run_vision()`. Output: **OpenSCAD code** (CRAFT's native target language; benefits from the new NURBS / smooth-surface modules for curved shapes) → rendered to STL via the OpenSCAD CLI. Evaluation: voxelize at 64³, compute IoU vs. their ground-truth STL with 45° rotation alignment, plus Success Rate, plus CRAFT's existing aligned Chamfer Distance as a stricter cross-check. Same task, same inputs, same metric, different method. Their fine-tuned 2B VLM does one forward pass; CRAFT v3 wraps a frontier VLM (GPT-5.2 / Gemini) with a structured gap-analysis-and-patch loop that benefits from NopSCADlib retrieval and NURBS-aware planning.

**Headline claim for the paper:** *Zero-shot agentic correction with a frontier VLM matches or exceeds supervised million-scale fine-tuning of a 2B model on Zero-to-CAD's own benchmark — at no training cost, with editable parametric output, in a different target language.*

---

## 4. Inputs / outputs / metric (exact specs)

### Input format
- 8 PNG renders per shape, 256×256, embedded as raw bytes in the parquet dataset.
- 4 front-facing camera angles + 4 rear-facing angles.
- White / clean background, consistent lighting (synthetic renders).
- No text prompt — image-only mode. The "instruction" is a fixed system prompt asking for parametric OpenSCAD reproducing the geometry.

### Method
- **CRAFT v3 from `pipeline/app.py`**, entry point `CRAFTPipeline.run_vision(image_paths, ...)`.
- All LLM calls via OpenAI API (or Gemini). Default models per `app.py`'s current configuration.
- Single-pass refinement: baseline → 6 ortho renders → gap analysis vs. inputs → one OpenSCAD patch.
- NURBS / smooth-surface routing fires automatically when `detect_curved_surface_need` or `detect_aerodynamic_shape` triggers (relevant for lofts/sweeps/revolves in the dataset).
- KB retrieval is enabled if `is_kb_ready()`; expected to be largely inert on Z2C synthetic shapes (they're not catalog mechanical parts) but it's not a confound.

### Output
- OpenSCAD source code (`.scad`).
- Rendered to STL via `openscad -o out.stl in.scad` (already wired in `pipeline/utils/openscad_runner.py`).

### Primary metric — voxel IoU at 64³
- Normalize each STL: center at centroid, scale so the longest axis = 1 (unit bounding box).
- Voxelize at 64³ resolution. Use `trimesh.voxel.creation.voxelize` or equivalent. A voxel is "occupied" if any part of the shape's volume lies inside it.
- Rotate prediction in 45° increments around the orthogonal axes (interpreted as the **24 proper cube rotations** — orientation-preserving symmetries of the cube). Compute IoU at each. Report the **maximum**.
- Faithfully match Z2C's definition: *"we rotate the generated shape in increments of 45 degrees and report the maximum IoU."*

### Secondary metric — Success Rate
- Generation produces valid, executable code AND the rendered STL has positive volume above threshold AND has at least one connected component.
- Mirror their definition: *"percentage of generations that produce valid, executable code."*
- They themselves note this is insufficient ("a model that always returns a trivial box achieves 100% success") — report it but lead with IoU.

### Cross-check metric — aligned Chamfer Distance
- CRAFT's existing scorer (`Experimentation/Chamfer_distance/align_and_score.py`): 10k surface points, PCA canonicalization, 24 cube rotations, ICP refinement.
- Strictly more discriminative than 64³ voxel IoU for surface fidelity.
- Report alongside the primary metric to show the result is robust to metric choice.

### Editability metric — new for this paper
- Define: fraction of dimensions in generated code that are bound to **named parameters** vs. **literal numbers**.
- CRAFT's JSON IR preserves symbolic expressions (e.g., `outer_diameter/2`); their fine-tuned model emits values baked from training.
- Cheap to compute, structurally favors CRAFT, communicates a real advantage to CAD-journal reviewers.

---

## 5. Voxel IoU vs. Chamfer Distance — the metric explainer

This section exists because we report both and they measure different things. Future sessions: read this before assuming either metric is "more correct."

### Aligned Chamfer Distance (CRAFT's scorer)
**What it is.** Average bidirectional closest-point distance between two point clouds sampled uniformly from the surfaces of two STLs. Lower is better.

**Pipeline.** Sample 10,000 points from each surface → center at centroid → scale to unit bounding sphere → PCA-canonicalize → for each of 24 cube rotations, run ICP refinement → take the minimum CD across starts.

**Strengths.**
- Sensitive to fine surface detail (chamfers, fillets, sharp vs. rounded edges).
- Fine-grained rotation alignment via ICP.
- Catches missing or extra small features.

**Weaknesses.**
- Cannot distinguish solid from hollow with the same outer surface.
- One outlier vertex can drag the average up.
- Hard to compare across very different shape complexities.

### Voxel IoU at 64³ (Zero-to-CAD's scorer)
**What it is.** Intersection-over-union of occupied voxel sets in a 64×64×64 grid. Higher is better, range [0, 1].

**Pipeline.** Normalize each STL to a unit bounding box → voxelize at 64³ → for each of (typically) 24 cube rotations, compute IoU → take the max.

**Strengths.**
- Captures volumetric agreement — distinguishes solid vs. hollow.
- Simple, intuitive, bounded.
- Robust to triangulation noise.

**Weaknesses.**
- Resolution-bound. At 64³, each voxel is ~0.016 normalized units on a side. Features smaller than that — chamfers under ~1 mm on a 100 mm part, narrow slots, thin ribs — disappear into the grid.
- Coarse 45° rotation alignment. A shape mis-rotated by 22° is penalized for that misalignment alone.
- Saturates near ~0.95 even for visually-perfect reconstructions due to voxelization edge effects.

### Why they often disagree

- **A 10 mm cube vs. the same cube with 1 mm chamfers** scores IoU ≈ 0.99 (chamfer voxels overlap with cube voxels) but a much worse CD (every chamfer point is far from the cube edge).
- **A hollow shell vs. a solid with the same outer surface** scores CD ≈ 0 (surfaces match) but much lower IoU (interior voxels are unoccupied in the shell).
- **A slightly mis-scaled or mis-rotated reconstruction** loses IoU fast (voxels stop overlapping); CD degrades smoothly.

### Why we report both

- **IoU is what Z2C reports.** Required for direct apples-to-apples slot-in. Without it, the paper has no headline comparison.
- **CD is more discriminative.** Useful for ablations where two CRAFT variants both look similar by IoU but one is actually closer in surface fidelity.
- **Reporting both lets us write:** *"CRAFT outperforms Zero-to-CAD on both volumetric (IoU) and surface-fidelity (CD) metrics, indicating the win is robust to metric choice."* That sentence is much stronger than reporting only one.

### A sentence on why Z2C's metric is "easier"

CRAFT's CD scorer does PCA canonicalization + ICP refinement on top of cube rotations. Z2C's IoU scorer does only the 24 cube rotations. So a borderline-case win that's washed out by IoU's coarse alignment may sharpen under CD's fine alignment. Mention this in the discussion section.

---

## 6. Test sets — what to evaluate on

### Important clarification on the 1M (read this carefully)

The Zero-to-CAD dataset has **train 979,633 / val 10,000 / test 10,000** = ~1M total.

**CRAFT itself has no train/test constraint** — it's zero-shot, never trained on any of these samples, so all 1M samples would in principle be valid CRAFT measurements. The constraint is on the *comparison*, not on CRAFT.

**Their fine-tuned Qwen was trained on the 980K training split and tuned on the 10K validation split.** If we evaluated Their model on training samples, it would score artificially high (memorization). If we evaluated CRAFT on training samples but Their model on test samples, the sample sets differ and reviewers will reject the comparison. So for the side-by-side numbers in our headline tables to be fair, **both methods must be evaluated on the same samples, drawn from data Their model didn't see during training**.

That gives two valid pools:
- **The 10K ZTC test split** — Their model didn't train on it. Maximum meaningful sample size for in-distribution evaluation.
- **ABC** — neither model was trained on this. Z2C's paper used 1,000 shapes filtered to 7–100 B-Rep faces, but the full ABC dataset has well over a million shapes. We can expand if we want.

We do **not** evaluate against the 980K training set or the 10K validation set, because Their model is contaminated on both.

### 6.1 In-distribution: Zero-to-CAD test split
- HF: `ADSKAILab/Zero-To-CAD-1m`, split `test`, 10,000 samples.
- **Headline run: 1,000 samples** (matches the protocol Z2C used for GPT-5.2 — they were cost-limited too). Use a fixed seed.
- **Stretch run: full 10,000 samples** if Phase 5 headline shows clear wins.
- This is in-distribution for Z2C. CRAFT may lose here — that is fine and reportable.

### 6.2 Out-of-distribution: ABC subset (THE HEADLINE BENCHMARK)
- **Headline run: 1,000 shapes** from ABC, filtered to 7–100 B-Rep faces (matches Z2C's protocol).
- **Optional stretch: 5,000 or 10,000 ABC shapes** with the same filter, only if a reviewer pushes back on 1K being too small.
- **Open question:** are the exact 1,000 IDs released? Check the HF discussion / dataset files first. If yes, use them. If no, replicate the filter (B-Rep face count between 7 and 100) and accept some sampling drift, but document the filter and seed.
- This is where CRAFT is most likely to win — Z2C already loses to GPT-5.2 here.

### 6.3 Why 1K headline is the right starting point (not a compromise)
- **Statistical power.** Standard error on a 65% Success Rate at n=1,000 is ~1.5 percentage points. Easily enough to detect a meaningful win — if CRAFT is 5pp above a baseline, n=1,000 will show it.
- **Cost discipline.** Headline run at 1K per benchmark for both CRAFT and re-run baselines is ~$2K of API spend. 10K is ~$15–20K. Don't burn the bigger budget before validating the method works.
- **Phase 4 dependency.** The 50-sample pilot is what tells us whether image-only Stage 1 works. If that's weak, we tune before scaling — saves money and time.
- **Path forward.** 1K headline → if numbers are strong, 10K stretch on ZTC test goes in the paper as "we additionally validated on the full test split." Reviewer-proof.

### 6.3 Schema reminder
Each parquet row contains:
- `uuid` (string)
- `cadquery_file` (base64-encoded source — for analysis only, *not* used as model input)
- `num_faces` (int, B-Rep face count)
- `cadquery_ops_json` (operations sequence)
- `image_0` … `image_7` (raw PNG bytes — these are the model inputs)
- `stl_file` (raw STL bytes — this is the ground truth for IoU)
- `step_file` (raw STEP bytes — not used directly)

---

## 7. Baselines to re-run on identical samples

Re-running on the *same samples we feed CRAFT* removes any sampling-drift question from the comparison. This is the single most important methodological move. Do not rely solely on the paper's published numbers.

| Baseline | Source | What to run |
|---|---|---|
| **Their fine-tuned Qwen** | Download `ADSKAILab/Zero-To-CAD-Qwen3-VL-2B` from HF | Run on the same samples we feed CRAFT |
| **GPT-5.2 High zero-shot, CadQuery output** | OpenAI API | Their exact six-line prompt + 8 images + "Generate CadQuery code for this shape." |
| **GPT-5.2 High zero-shot, OpenSCAD output** | OpenAI API | Same prompt structure, but ask for OpenSCAD — controls for "is the win from CRAFT or from OpenSCAD being friendlier?" |
| **GPT-5.2 Medium zero-shot** | OpenAI API | Optional — paper publishes 71.1% / 62.6% so this can be cited rather than re-run |
| **CRAFT v3** (this paper) | Local | `CRAFTPipeline.run_vision()` from `pipeline/app.py` |
| **CRAFT v3 — VLM correction disabled** | Local | Ablation: shows the gap-analysis-and-patch step is doing work (`USE_VLM_CORRECTION=False`) |
| **CRAFT v3 — KB disabled** | Local | Ablation: shows whether NopSCADlib retrieval helps on synthetic shapes (it probably doesn't) |
| **CRAFT v3 — NURBS modules disabled** | Local | Ablation: isolates the smooth-surface contribution; compare on samples flagged as "curved" |
| **Qwen-2B base** (no fine-tune) | HF | Optional — paper publishes 6.6% / 5.4% so this can be cited rather than re-run |

---

## 8. What CRAFT already has vs. what needs building

### Already exists in the repo
- `CRAFTPipeline` in `pipeline/app.py` with `run_vision(image_paths, ...)` for multi-view input.
- 6-orthographic-view rendering pipeline.
- OpenSCAD output via `pipeline/utils/openscad_runner.py`.
- NURBS / smooth-surface modules (`core/nurbs_surfaces.py`, `core/smooth_surface_optimizer.py`).
- Aligned-CD scorer (`Experimentation/Chamfer_distance/align_and_score.py`).
- Single-image and multi-image input support (`SingleImageAnalyzer`, `VisionAnalyzer`, `vision_to_design_brief`).
- KB / NopSCADlib retrieval (likely inert on this benchmark but not a confound).
- v3 single-pass gap-analysis-and-patch refinement (`_run_v3_refinement`).
- Gemini support (added by the recent commit).

### Net-new work
1. **8-view input adapter.** `run_vision()` already accepts multiple image paths, but the existing `VisionAnalyzer` was tuned for 6 ortho views (front/back/left/right/top/bottom). The Z2C input is 4 front-facing + 4 rear-facing camera angles — not labeled with viewpoint names. The analyzer needs an "unlabeled multi-view" mode that doesn't assume orthographic camera positions.
2. **Image-only Stage 1 prompt.** Currently `vision.py`'s analyzer expects to caption shapes for downstream text-mode reasoning. New prompt that asks for a **structured topology description from 8 unlabeled views** rich enough that the planner can write OpenSCAD without a real text prompt. Reuse the JSON schema sketched in `CRAFT_v2_research_plan.md` §3.2.
3. **Voxel IoU at 64³ scorer** with 24-cube-rotation alignment. New file: `Experimentation/voxel_iou/score.py`. Sanity tests: `IoU(GT, GT) ≈ 1.0`, `IoU(GT, rotated GT) ≈ 1.0`, `IoU(cube, sphere)` somewhere mid-range.
4. **HF dataset glue.** Stream `ADSKAILab/Zero-To-CAD-1m`, split `test`, decode parquet → write per-sample directories with `views/view_{0..7}.png`, `gt.stl`, `gt.step`, `meta.json`. Use `datasets.load_dataset(..., streaming=True)` so we don't download 349 GB.
5. **Three-way visual comparison in v3 refinement.** The existing v3 gap analysis compares render to text/sketch. In image-only mode it should compare render to the **input 8 views**. Modify `_run_v3_refinement` to accept input views as the "intent" reference.
6. **Result-folder convention.** Each method writes under `results/zerotocad_eval/{benchmark}/{method}/{uuid}/` containing `output.scad` (or `.py` for CadQuery), `output.stl`, `audit.json`. Both the voxel-IoU and aligned-CD scripts read from this layout.
7. **Editability scorer.** Parse generated code, count parameters vs. literals, write a per-sample JSON.

### Implementation budget
- 2–3 weeks of focused work to a working end-to-end image-to-code pipeline.
- + 1 week for baselines (download Qwen, run GPT-5.2 with their prompt).
- + 1 week for full-scale runs.
- + 2–4 weeks of paper writing.
- Total: ~2 months of substantive work, plus calendar buffer for journal-paper polish.

---

## 9. Decisions made (DECIDED) and open questions

### DECIDED
- **`pipeline/app.py` (CRAFT v3) is the architecture** for this paper — not v2 (design-only, not implemented), not v4 (different design).
- **OpenSCAD as output** (CRAFT's native target language). NURBS / smooth-surface modules give CRAFT a structural advantage on curved geometry that didn't exist in v1. Reframe: language-agnostic STL-space evaluation makes target language an axis to *report*, not a confound.
- **ABC OOD is the headline benchmark; ZTC test is in-distribution sanity.** Wins on OOD are worth more.
- **Same-sample re-runs** of their fine-tuned model and GPT-5.2 baseline (don't trust published numbers alone).
- **Sample size: 1,000 each per benchmark for the headline run.** Matches Z2C's GPT-5.2 protocol. If headline numbers are strong, run a 10,000-sample stretch on the ZTC test split for variance-reduction. ABC stretch (5K–10K) is optional and only if reviewers push.
- **No fine-tuning of our own model.** This paper is zero-shot CRAFT vs. their fine-tuned Qwen.
- **No 1M-scale dataset construction.**
- **Report both voxel IoU and aligned CD.** IoU for direct comparison (their metric); CD for surface-fidelity cross-check.
- **Add an editability metric** (parameters vs. literals).
- **Evaluate only on the 10K ZTC test split + ABC.** Not on training (Their model trained there) or validation (Their model tuned there). CRAFT itself has no contamination — the constraint is on the comparison.

### OPEN (lock these before any code is written)
- [ ] ABC OOD: use Z2C's exact IDs if released, else replicate filter? Check HF discussion / data files first.
- [ ] Stage 1 image-only prompt: write a v0 draft and iterate during Phase 4 pilot.
- [ ] Failure handling policy: CRAFT timeouts, OpenSCAD render failures, unparsable outputs. **Recommendation: count as failures (Success=0, IoU=0)** so the metric is honest.
- [ ] Voxel-IoU implementation: replicate from scratch or reuse if Z2C released a script in their HF repo? Check first.
- [ ] OpenAI API budget approval. See §11 estimates.
- [ ] Local GPU access for running their Qwen model: which machine, how much VRAM? Qwen3-VL-2B in bf16 needs ~5 GB; runnable on most workstations.
- [ ] Gemini vs. OpenAI as primary backbone — `app.py` now supports both. Pick one for the headline; report the other as ablation.
- [ ] Decision criterion for "did NURBS module fire" — needed for the NURBS-module ablation. Log it in `audit.json`.

---

## 10. Implementation order

Each phase is independently shippable and independently testable. Don't stack phases before the prior one is verified.

### Phase 1 — Eval harness (no model calls)
1. Pull HF test set with streaming. Decode parquet → per-sample folders.
2. Implement voxel-IoU scorer at 64³ with 24-cube-rotation alignment.
3. Sanity test: `IoU(GT, GT) ≈ 1.0` for 50 random samples.
4. Sanity test: `IoU(GT, rotated GT) ≈ 1.0` (alignment works).
5. Sanity test: `IoU(GT, scaled GT) ≈ 1.0` (normalization works).
6. Sanity test: `IoU(cube, sphere)` — should be moderate (~0.5), not 1.0.
7. Implement Success Rate scorer matching Z2C's definition.
8. Wire CRAFT's existing aligned-CD scorer into the same result-folder layout.

### Phase 2 — 8-view image-to-code in CRAFT v3
1. Extend `core/vision.py` to accept 8 unlabeled views; emit structured JSON topology.
2. Write Stage 1 image-only prompt (iterate on v0 draft).
3. Plumb 8-view input through `CRAFTPipeline.run_vision()` (verify it already works, or add a new `run_multiview()` if cleaner).
4. Modify `_run_v3_refinement` to compare render against input views (three-way: input views / current render / fitness rubric).
5. Verify end-to-end on 5 hand-picked samples: 8 PNGs in → OpenSCAD out → STL out, no crashes.
6. Visual sanity: render output and compare to inputs by eye on those 5 samples.

### Phase 3 — Baseline runs on identical samples
1. Download `ADSKAILab/Zero-To-CAD-Qwen3-VL-2B`. Verify inference works on a single sample using the model card's exact code.
2. Run their model on a 50-sample pilot from each benchmark.
3. Run GPT-5.2 zero-shot (CadQuery output, their exact prompt) on the same 50.
4. Run GPT-5.2 zero-shot (OpenSCAD output, modified prompt) on the same 50.
5. Verify all baselines write outputs to the canonical folder layout.

### Phase 4 — Pilot (50 samples per benchmark)
1. Run CRAFT v3 image-mode on 50 ABC + 50 ZTC-test samples.
2. Compute voxel IoU + Success Rate + aligned CD for all methods on the same 100 samples.
3. **Decision gate.** Compare CRAFT v3 vs. GPT-5.2 zero-shot vs. their fine-tuned Qwen on ABC Success Rate.
   - If CRAFT ≥ 70% on ABC pilot → proceed to full run.
   - If CRAFT 60–70% → debug Stage 1 prompt, gap-analysis behavior, retry pilot.
   - If CRAFT < 60% → architecture issue, regroup before scaling.
4. Eyeball 10 failure cases per method to characterize failure modes.

### Phase 5 — Full run (1,000 samples per benchmark)
1. Run all methods on all samples. Estimate ~24–48 hours of wall time depending on parallelism.
2. Compute all metrics. Generate the headline tables.
3. Generate per-tier breakdowns (simple / medium / complex by `cadquery_ops_count` or `num_faces`).

### Phase 6 — Ablations
- v3 with VLM correction disabled.
- v3 with KB disabled.
- v3 with NURBS modules disabled (compare on curved-shape subset).
- v3 with Gemini vs. GPT-5.2 backbone.
- CRAFT outputting OpenSCAD vs. CadQuery (controls for language confound).

### Phase 7 — Stretch: full 10K test split (ZTC) + optional ABC expansion
- **Trigger.** Run only if Phase 5 (1K headline) shows clear wins on the metrics that matter.
- **ZTC test stretch.** Run all methods on the full 10K test split. Adds statistical confidence and stops a reviewer from saying "1K is too small." This is the more important of the two.
- **ABC stretch (optional).** Expand ABC eval from 1K to 5K or 10K with the same 7–100 B-Rep face filter. Only do this if a reviewer specifically pushes back on the 1K ABC sample being too small — otherwise the cost isn't worth it.
- **Don't run the stretch if headline is mixed.** If CRAFT is clearly behind on the 1K run, fixing the method is more valuable than adding samples.

### Phase 8 — Paper writing
- Outline: motivation, related work (Zero-to-CAD as primary, DeepCAD/CAD-Recode/Text2CAD as secondary), method (CRAFT v3 + image-only adaptation + NURBS extension), evaluation protocol (their harness + cross-checks), results (headline tables + ablations + per-tier), discussion (cost, editability, target language, NURBS), limitations.

---

## 11. Cost estimates

API spend is the main variable cost. Local Qwen inference is free (one-time GPU time). OpenSCAD rendering is free.

### Per-sample cost (rough estimates)
- **CRAFT v3 (one prompt → output)**: ~$0.30–0.80 depending on iterations and model. Use $0.50 as planning estimate.
- **GPT-5.2 zero-shot with 8 images**: ~$0.10–0.20 per call. Use $0.15 as planning estimate.
- **Their Qwen model**: $0 (local inference).

### Phase totals (planning estimates)
- **Phase 4 pilot** (100 samples × CRAFT + 100 × GPT-5.2 × 2 variants): ~$80.
- **Phase 5 headline run** (2,000 samples × CRAFT + 2,000 × GPT-5.2 × 2 variants): ~$1,600.
- **Phase 6 ablations** (4 ablations × 1,000 samples × CRAFT): ~$2,000.
- **Phase 7 stretch full 10K** (additional 18,000 samples for both benchmarks across all methods): ~$15,000–20,000.

**Headline budget without stretch: ~$4,000.** With stretch: ~$25,000.

### Cost mitigation
- Cache and resume — never re-run a sample whose output already exists.
- Parallelize across processes (Python's `concurrent.futures.ThreadPoolExecutor` for I/O-bound API calls).
- Use Gemini for some ablations if it's substantially cheaper.

---

## 12. Pitfalls and gotchas (read this before coding)

- **Their parquet stores PNGs as raw bytes, not paths.** Decoding requires `Image.open(io.BytesIO(sample[f"image_{i}"]))`. Their model card has the exact decode pattern — copy it.
- **Their CadQuery code is base64-encoded** in the parquet. `bytes(sample["cadquery_file"]).decode("utf-8")` per the model card.
- **Voxelization is sensitive to mesh quality.** Some ground-truth STLs may be non-watertight. Compute volume after voxelization and skip samples where GT volume is suspicious.
- **45° rotation = 24 cube rotations**, not 8 around the vertical axis. Their wording is ambiguous; the standard interpretation is the 24 orientation-preserving rotations of the cube. Confirm by reading their eval script if released.
- **OpenSCAD STL exports can have inconsistent normals.** Use trimesh to normalize before voxelization.
- **CRAFT failures must count as Success=0**, not be skipped. Otherwise the metric is dishonest.
- **Their fine-tuned model expects images in a specific channel order and value range.** Use the `AutoProcessor` from the model card — don't hand-roll the preprocessing.
- **GPT-5.2 with 8 images is not free.** Each call sends 8 × 256×256 PNGs through the API.
- **Their voxel resolution (64³) is coarse.** Small features (chamfers, narrow slots, thin ribs) will be smoothed out. Flag it as a limitation; don't change the metric (changing it loses comparability).
- **Their Success Rate is generous.** A trivially returned cube counts as success. Don't be surprised if all methods including base Qwen approach high Success Rate when the question is malformed; the IoU number is what matters.
- **The 8 views are RENDERS of the ground-truth STL.** Inputs are noise-free — no real photos, no lighting variation, no occlusion. Reviewers will ask whether the method generalizes to real photos. Address it in limitations.
- **No KB win on synthetic shapes.** NopSCADlib retrieval won't fire on Z2C's synthetic parts. Run with KB on by default but expect the ablation to show small gap.
- **The 1M is the dataset size, not the eval size.** Test split is 10K. Train is 980K. CRAFT *could* run on the train split (it's zero-shot), but Their model can't be fairly evaluated there, so the comparison must come from the 10K test split or from ABC.
- **NURBS module triggering is implicit.** The smooth-surface optimizer fires based on prompt/topology cues. Log when it fires for the ablation.
- **The Gemini path is new code.** Verify parity with OpenAI on a 10-sample sanity check before relying on it.

---

## 13. Resume in a new session

If you're a future session picking this up:

1. Read this file end-to-end.
2. Read `pipeline/app.py` (top of file + `CRAFTPipeline.run_vision`, `_run_v3_refinement`).
3. Read `README.md` (CRAFT v1 overview).
4. Read `Experimentation/Chamfer_distance/README.md` (existing scorer).
5. Skim `core/nurbs_surfaces.py` and `core/smooth_surface_optimizer.py` to know what's available.
6. Check `git log` for the latest CRAFT commits to see how far Phase 1–2 have progressed.
7. Look at `results/zerotocad_eval/` if it exists — that's where outputs land.
8. Ask the researcher which phase of §10 is current. Pick up from there.

### Sample message to paste into a fresh chat

> I'm continuing CRAFT work — specifically a CAD-journal paper that compares CRAFT to Zero-to-CAD on Zero-to-CAD's own evaluation harness. The full plan is at `/Users/mohd7/Local/CRAFT/CRAFT_zerotocad_eval_plan.md`. Please read that file end-to-end first, then read `pipeline/app.py` (top of file + `CRAFTPipeline.run_vision` + `_run_v3_refinement`), then `README.md`, then `Experimentation/Chamfer_distance/README.md`. Skim `core/nurbs_surfaces.py` and `core/smooth_surface_optimizer.py` so you know what's available. Once you've read those, summarize back to me in 8–10 bullets what we're doing and why so I know we're aligned. Don't write any code yet — we'll pick the first file to touch after I confirm the summary.
>
> Context you need:
> - Target: CAD journal paper comparing CRAFT v3 (zero-shot, agentic, OpenSCAD output, NURBS-aware) against Zero-to-CAD's fine-tuned Qwen3-VL-2B and GPT-5.2 baselines.
> - We are using THEIR evaluation harness — 8 multi-view PNG inputs, 64³ voxel IoU + 45° rotation alignment, Success Rate. Same-sample re-runs of all baselines so the comparison is apples-to-apples.
> - We use the pipeline in `pipeline/app.py` (`CRAFTPipeline.run_vision`), NOT v2 or v4. The professor's recent commit added NURBS / smooth-surface modules that benefit CRAFT on curved shapes from Zero-to-CAD's lofts/sweeps/revolves.
> - Implementation order is in §10 of the plan: Phase 1 (eval harness) → Phase 2 (image-to-code in CRAFT) → Phase 3 (baselines) → Phase 4 (pilot, decision gate) → Phase 5 (full 1K run) → Phase 6 (ablations) → Phase 7 (optional 10K stretch) → Phase 8 (paper).
> - Goal in chart form: add a CRAFT row as the 3rd entry in the Key Results table and the 5th entry in the Comparison-with-Baselines table, with numbers that beat all four published rows.
> - We are NOT building a 1M-scale OpenSCAD dataset. We are NOT fine-tuning. We are running CRAFT through API calls only. Test split is 10K (not 1M — the 1M is the total dataset size).
> - All artifacts (their dataset, their model) are public on HuggingFace. Apache 2.0.

The instruction *"read first, summarize back, then we pick the first file"* forces alignment before any code changes and catches misunderstandings early.

---

## 14. What success looks like

By the end of this work the repo should contain:

```
results/zerotocad_eval/
├── ztc_test/                          # in-distribution
│   ├── craft_v3/{uuid}/output.scad, output.stl, audit.json
│   ├── craft_v3_no_vlm/{uuid}/...
│   ├── craft_v3_no_kb/{uuid}/...
│   ├── craft_v3_no_nurbs/{uuid}/...
│   ├── their_qwen/{uuid}/output.py, output.stl
│   ├── gpt52_cadquery/{uuid}/output.py, output.stl
│   ├── gpt52_openscad/{uuid}/output.scad, output.stl
│   └── ground_truth/{uuid}/gt.stl
├── abc_ood/                           # out-of-distribution (HEADLINE)
│   └── (same structure)
└── metrics/
    ├── voxel_iou_64.json              # primary metric
    ├── success_rate.json
    ├── aligned_cd.json                # secondary cross-check
    ├── editability.json
    └── headline_table.md              # paper-ready table matching Z2C's chart layout
```

And a paper draft showing CRAFT v3 wins on ABC OOD by some non-trivial margin over the published Zero-to-CAD numbers, with full ablation support.

If those things exist and the numbers are real, the paper writes itself. The journal version can take its time on the discussion, the limitations, and the editability story — this is the work that gets you into a CAD journal cleanly.
