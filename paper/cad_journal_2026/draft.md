# CRAFT: Zero-Shot Agentic Reconstruction Matches Million-Scale Supervised Fine-Tuning on Parametric CAD Generation

**Status:** skeleton. Numbers are TODO until Phase 5 completes.
**Plan:** `CRAFT_zerotocad_eval_plan.md` at repo root.
**Target venue:** CAD journal (calendar 3-6 months).

---

## Abstract (TODO — write after Results)

Zero-to-CAD (Ataei et al., 2026) demonstrates that an agentic synthesis loop
can produce a 1M-sample CAD dataset and that a small VLM (Qwen3-VL-2B)
fine-tuned on this data outperforms zero-shot frontier models on in-distribution
test samples. However, the same paper reports that their fine-tuned model
*underperforms* GPT-5.2 on out-of-distribution ABC shapes (61.0% vs. 66.2%
Success Rate), suggesting the synthetic-to-real transfer gap remains open.

We show that CRAFT — a zero-shot agentic CAD generation framework that wraps
a frontier VLM with a structured gap-analysis-and-patch loop — matches or
exceeds the fine-tuned baseline on both benchmarks at no training cost,
preserving editable parametric output and using a different target language
(OpenSCAD vs. CadQuery). On Zero-to-CAD's published test split, CRAFT
achieves Success Rate of **TODO%** and Mean IoU of **TODO** (vs. their
82.1% / 0.747). On the out-of-distribution ABC subset, CRAFT achieves
**TODO%** / **TODO** (vs. their 61.0% / 0.377 and GPT-5.2's 66.2% / 0.344).
Ablations isolate the contribution of (i) NURBS-aware curved-surface
generation, (ii) structured single-pass refinement, and (iii) frontier VLM
choice. CRAFT generates code with **TODO×** higher parameter-to-literal
ratio than the fine-tuned baseline, supporting downstream editing.

---

## 1. Introduction

- The text-to-CAD / image-to-CAD problem and why parametric output matters
  for engineering workflows.
- Two dominant strategies: (a) million-scale supervised fine-tuning on
  synthetic CAD code (DeepCAD, CAD-Recode, Zero-to-CAD); (b) zero-shot
  prompting of frontier VLMs (GPT-5.2, Gemini, Claude). Both have known
  weaknesses (training data cost; generalization gap).
- Our contribution: CRAFT, an agentic framework that achieves the
  generalization profile of frontier VLMs *plus* the fidelity profile of
  supervised methods, by adding a structured gap-analysis-and-patch loop
  grounded in visual feedback against the input views.
- We re-use Zero-to-CAD's evaluation harness verbatim — same 8-view PNG
  inputs, same 64³ voxel-IoU metric with 45° rotation alignment, same
  Success Rate definition — so the comparison is direct.

**Contributions:**

1. **Image-only operation** — Section 3.2 — CRAFT extends to multi-view
   image-only input (no text prompt) by introducing a dedicated 8-view
   topology-extraction stage.
2. **Visually-grounded gap refinement** — Section 3.3 — single structured
   pass that compares current renders against input views to identify
   actionable deltas, then applies one minimal patch.
3. **NURBS-aware OpenSCAD generation** — Section 3.4 — automatic routing
   to smooth-surface modules when the topology requires lofts/sweeps/
   revolves, which CSG-on-primitives handles poorly.
4. **Empirical results** — Section 5 — TODO: matches/beats Zero-to-CAD on
   their own protocol; ablations attribute the win to each component;
   editability metric quantifies the parametric-IR advantage.

---

## 2. Related Work

- **Supervised CAD generation.** DeepCAD, CAD-Recode, Text2CAD, Zero-to-CAD.
- **Zero-shot CAD with frontier models.** GPT-5.2, Gemini, code-LLM
  benchmarks on engineering tasks.
- **Self-correction / agentic loops.** Reflexion, Self-Refine, VLM-driven
  spatial reasoning loops.
- **Evaluation metrics for 3D generation.** Voxel-IoU, Chamfer Distance,
  F1 at fixed thresholds. Trade-offs documented in §5.

---

## 3. Method

### 3.1 CRAFT v3 architecture (one-paragraph overview)

Six-stage pipeline: Understanding → Planning → Compilation → Rendering →
v3 single-pass gap refinement → Component Verification. Reasoning-intensive
stages use GPT-5.2 (or Gemini). Deterministic translation uses GPT-4o.
JSON IR preserves symbolic parametric expressions throughout.

### 3.2 Image-only stage 1 — 8-view topology extraction

**Why this is novel.** Existing CRAFT (and most supervised CAD systems)
takes a text prompt as the canonical intent. For comparison against
Zero-to-CAD we operate in image-only mode: 8 unlabeled rendered views
are the entire input.

We introduce `analyze_zerotocad_8view()` (in `pipeline/core/vision.py`)
which prompts the VLM for a CAD-focused topology JSON: primary form,
primitives needed, component list with positions, features (holes, slots,
chamfers, ribs), curved-surface flag, estimated complexity, estimated
B-Rep face count. This output flows through the same reasoner → planner
→ compiler path as a text prompt would.

### 3.3 Visually-grounded gap refinement

The v3 gap-refinement stage (in `pipeline/core/gap_refiner.py`) compares
six orthographic renders of the current OpenSCAD model against the input
8 reference views, identifies actionable deltas (`add` / `remove` /
`fix_connectivity` / `adjust_proportions`), and applies one minimal code
patch. A single pass — not an iterative loop — keeps the cost bounded and
mirrors how a human reviewer would do a final pass.

### 3.4 NURBS / smooth-surface routing

Zero-to-CAD's dataset is rich in lofts, sweeps, and revolves —
operations that produce smooth curved surfaces, which OpenSCAD's
CSG-on-primitives renders poorly. We extend the planner with
`smooth_surface_optimizer.detect_curved_surface_need()` which, when
triggered, routes the compiler to NURBS-approximation modules
(`nurbs_surfaces.py`) that emit polyhedron-based smooth surfaces via
explicit control-point interpolation.

### 3.5 Implementation

All LLM calls via the OpenAI API or Gemini API. No local model. No fine-tuning.
OpenSCAD CLI for rendering. Standard CPU. Code released at TODO-URL.

---

## 4. Experimental Setup

### 4.1 Benchmarks

- **Zero-to-CAD test split** (in-distribution for Their model):
  - 10,000 samples from `ADSKAILab/Zero-To-CAD-1m`, split `test`.
  - We evaluate on 1,000 samples for headline numbers and (TODO if Phase 7
    triggers) the full 10K for variance reduction.
- **ABC out-of-distribution** (THE HEADLINE BENCHMARK):
  - 1,000 ABC shapes filtered to 7-100 B-Rep faces, matching Z2C's protocol.
  - Source: TODO — exact IDs from Z2C's HF page if released; otherwise
    replicated filter + seed for reproducibility.

### 4.2 Inputs

8 PNG views per shape, 256×256, 4 front-facing + 4 rear-facing camera angles,
embedded as raw bytes in the parquet — exactly as published by Zero-to-CAD.
No text prompt.

### 4.3 Methods

| Method | Source | Output |
|---|---|---|
| Zero-to-CAD (Their model) | `ADSKAILab/Zero-To-CAD-Qwen3-VL-2B` | CadQuery |
| GPT-5.2 zero-shot CadQuery | OpenAI API | CadQuery |
| GPT-5.2 zero-shot OpenSCAD | OpenAI API | OpenSCAD |
| **CRAFT v3 (this paper)** | OpenAI / Gemini API | OpenSCAD |

We **re-run** all baselines on the *same* samples we feed CRAFT — we do
not rely on the paper's published numbers alone — to eliminate sampling
drift from the comparison.

### 4.4 Metrics

- **Voxel IoU @ 64³** with 24-cube-rotation alignment — Z2C's primary
  metric, replicated faithfully. Implementation in
  `Experimentation/zerotocad_eval/voxel_iou/score.py`; sanity tests in the
  same module.
- **Success Rate** — generated code executes AND produced STL has positive
  volume AND at least one connected component.
- **Aligned Chamfer Distance (cross-check)** — CRAFT's existing scorer:
  10K surface samples + PCA + 24 cube rotations + ICP refinement. Strictly
  more discriminative than 64³ IoU.
- **Editability** — fraction of dimensional argument positions bound to
  named parameters vs. numeric literals. Quantifies the JSON-IR advantage.

Discussion of metric trade-offs: see `CRAFT_zerotocad_eval_plan.md` §5.

---

## 5. Results

### 5.1 Headline tables

See `results_tables.md` for the populated tables (filled after Phase 5).

### 5.2 Per-tier breakdown (simple / medium / complex by `num_faces`)

TODO: bucket by B-Rep face count to show whether CRAFT's win is uniform or
concentrated on complex shapes.

### 5.3 Failure mode analysis

TODO: hand-annotate 30 failure cases per method per benchmark; report
qualitative categories (missing features, mis-proportioned, wrong topology,
non-renderable code).

### 5.4 Ablations

TODO four rows from `run_ablations.sh`:

- CRAFT v3 — VLM correction disabled
- CRAFT v3 — KB disabled  *(no-op for image-only mode, reported for completeness)*
- CRAFT v3 — NURBS modules disabled  *(largest expected delta on curved shapes)*
- CRAFT v3 — Gemini backbone (vs. GPT-5.2)

### 5.5 Cost

Headline run: 1K samples × {CRAFT, GPT-5.2 CadQuery, GPT-5.2 OpenSCAD} ≈
~$2K API spend total. Their model: free local inference (~5 GB VRAM).
Full Zero-to-CAD training: ~1 week × 80 GPUs (their report).

---

## 6. Discussion

- **Why this comparison is fair.** Same evaluation harness, same metric,
  same input format, same samples. Different methods. We control for the
  one substantive confound (target language: OpenSCAD vs. CadQuery) by
  including GPT-5.2 in both targets.
- **Why CRAFT wins (or loses).** TODO: depends on numbers. If we win on
  ABC OOD: agentic refinement + visual grounding generalize better than
  supervised pattern matching. If we win on ZTC: NURBS modules + iterative
  correction compensate for the data-distribution disadvantage.
- **Editability.** CRAFT preserves named parameters because the IR is
  symbolic; the fine-tuned model bakes literals. We report the gap.
- **OpenSCAD vs. CadQuery.** OpenSCAD is the right target language for CRAFT
  because its declarative scope-based composition aligns with the IR.
  CadQuery's procedural API is harder for an agentic loop to patch reliably.

---

## 7. Limitations

- **Synthetic inputs.** Z2C views are noise-free renders, not real photos.
  Generalization to camera-captured imagery remains future work.
- **64³ voxel resolution.** Coarse — features below ~0.016 normalized
  units smooth out. We report aligned-CD as a cross-check.
- **45° rotation alignment.** A shape mis-rotated by 22.5° is penalized
  for that misalignment alone. We report aligned-CD (PCA + ICP) for the
  same reason.
- **OpenSCAD's CSG-on-primitives weakness.** Partially mitigated by NURBS
  modules but lofts/sweeps with high feature density are still hard.
- **API cost as variable.** We report per-sample cost so readers can
  estimate budget for replication.

---

## 8. Conclusion

TODO — restate the contribution and headline result.

---

## References

- Ataei et al., *Zero-to-CAD: Agentic Synthesis of Interpretable CAD
  Programs at Million-Scale Without Real Data*, arXiv:2604.24479, 2026.
- Earlier CRAFT paper (IEEE LAD 2026, in repo `paper/ieee_lad_2026/`).
- DeepCAD, CAD-Recode, Text2CAD references TODO.
- ABC dataset reference TODO.
