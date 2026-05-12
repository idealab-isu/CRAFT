# Results tables for the CAD-journal manuscript

Drop-in tables once Phase 5 (headline) and Phase 6 (ablations) finish.
Numbers come from `results/zerotocad_eval/metrics/{benchmark}/summary.json`.

## Table 1 — Key Results (matches Z2C's primary table layout)

The Zero-to-CAD paper publishes two rows in this table; we add two CRAFT
rows so reviewers see in-distribution and OOD on one screen.

| Benchmark | Success Rate | Mean IoU | Median IoU | P90 IoU |
|---|---|---|---|---|
| Zero-to-CAD test (their published) | 82.1% | 0.747 | 0.847 | 0.999 |
| ABC OOD (their published) | 61.0% | 0.377 | 0.303 | 0.854 |
| **CRAFT — ZTC test** | **TODO** | **TODO** | **TODO** | **TODO** |
| **CRAFT — ABC OOD** | **TODO** | **TODO** | **TODO** | **TODO** |

## Table 2 — Comparison with Baselines (same-sample re-runs)

Three columns of methods, two pairs of (benchmark × metric) per method.
The fifth row is CRAFT.

| Model | ZTC Success | ZTC Mean IoU | ABC Success | ABC Mean IoU |
|---|---|---|---|---|
| Their fine-tuned Qwen3-VL-2B (their published) | 82.1% | 0.747 | 61.0% | 0.377 |
| GPT-5.2 High zero-shot, CadQuery (their published) | 72.2% | 0.485 | 66.2% | 0.344 |
| GPT-5.2 Medium zero-shot (their published) | 71.1% | 0.495 | 62.6% | 0.346 |
| Qwen-2B base (no fine-tune, their published) | 6.6% | 0.184 | 5.4% | 0.131 |
| **CRAFT (this paper)** | **TODO** | **TODO** | **TODO** | **TODO** |

For the same-sample re-run we report **both** the published numbers and our
re-runs so reviewers can see the published numbers are reproduced.

## Table 3 — Cross-check: Aligned Chamfer Distance

CD as a stricter cross-check on surface fidelity (lower is better).
Only computed on the 1K samples we evaluate.

| Method | ZTC Mean CD ↓ | ABC Mean CD ↓ |
|---|---|---|
| Their Qwen | TODO | TODO |
| GPT-5.2 OpenSCAD | TODO | TODO |
| GPT-5.2 CadQuery | TODO | TODO |
| **CRAFT** | **TODO** | **TODO** |

## Table 4 — Editability (parameter / literal ratio)

How much of the generated code is parametric? Higher = more editable.

| Method | ZTC editability | ABC editability |
|---|---|---|
| Their Qwen (CadQuery) | TODO | TODO |
| GPT-5.2 OpenSCAD | TODO | TODO |
| GPT-5.2 CadQuery | TODO | TODO |
| Z2C ground-truth (reference) | ~0.75 | n/a |
| **CRAFT (OpenSCAD)** | **TODO** | **TODO** |

## Table 5 — Ablations on CRAFT v3 (ZTC test, n=1000)

| Variant | Success | Mean IoU | ΔIoU vs. full CRAFT |
|---|---|---|---|
| CRAFT v3 (full) | TODO | TODO | 0.000 |
| − VLM correction (no v3 gap refinement) | TODO | TODO | TODO |
| − KB (no-op for image-only mode, reported as sanity) | TODO | TODO | TODO |
| − NURBS modules | TODO | TODO | TODO |
| Backbone: Gemini instead of GPT-5.2 | TODO | TODO | TODO |

## Per-tier breakdown — optional Table 6

| Tier (B-Rep faces) | Their Qwen IoU | GPT-5.2 IoU | CRAFT IoU |
|---|---|---|---|
| Simple (7-20) | TODO | TODO | TODO |
| Medium (21-50) | TODO | TODO | TODO |
| Complex (51-100) | TODO | TODO | TODO |
