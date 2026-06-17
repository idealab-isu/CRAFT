# CRAFT — Final Results (verified, June 2026 re-run)

All numbers read from the per-sample metric JSONs in `metrics/`. Significance = paired Wilcoxon, Benjamini–Hochberg corrected, CRAFT as reference. **All experiments are complete; only paper writing remains.** Git: committed & pushed (commit `21f679ec`).

---

## Table I — Perceptual (NopSCADlib)
| Method | CLIP ↑ | FID ↓ |
|---|---|---|
| **CRAFT** | **0.2226** | **95.11** |
| GPT-4o | 0.2033 | 119.42 |
| GPT-5.2 | 0.2145 | 106.22 |
CRAFT wins both (FID by a wide margin).

## Table II — Geometric (NopSCADlib, n≈465)
| Method | CD ↓ | F1@1% ↑ | F1@5% ↑ | Voxel IoU ↑ |
|---|---|---|---|---|
| **CRAFT** | **0.0654** | 0.2530 | **0.6260** | **0.2356** |
| GPT-4o | 0.0733 | 0.2467 | 0.5713 | 0.2135 |
| GPT-5.2 | 0.0662 | **0.2587** | 0.6055 | 0.1890 |

**Significance vs CRAFT:** vs GPT-4o — CRAFT sig-better on CD, F1@5%, IoU (F1@1% tie). vs GPT-5.2 — CRAFT sig-better on IoU; CD/F1@1%/F1@5% are **ties** (F1@1% p=0.94). **CRAFT is never significantly worse than any baseline on any geometric metric.**

## Table III — Ablation (NopSCADlib)
| Variant | CD ↓ | F1@1% ↑ | F1@5% ↑ | IoU ↑ | vs CRAFT (sig) |
|---|---|---|---|---|---|
| **CRAFT (full)** | 0.0654 | 0.2530 | 0.6260 | 0.2356 | — |
| no_retrieval | 0.0764 | 0.2030 | 0.5774 | 0.1545 | **CRAFT better, all 3 sig** |
| no_multiview | 0.0738 | 0.1907 | 0.5627 | 0.2272 | CRAFT better; CD & F1 sig |
| no_recovery | 0.0773 | 0.1878 | 0.5407 | 0.2289 | CRAFT better; CD & F1 sig |
| no_json_ir | 0.0643 | 0.2383 | 0.6206 | 0.1999 | only IoU sig for CRAFT |
| no_verification | 0.0637 | 0.2574 | 0.6400 | 0.2411 | verification removal *improves* CD (sig, p=0.012) |

**Headline:** removing the knowledge base (retrieval) significantly hurts every metric → retrieval is the dominant component.

## Tables IV–V — External geometric (KB disabled; tests generalization)
**ABC** (n 88/83/96): CRAFT best on all three — CD **0.0841**, F1 **0.1233**, IoU **0.0433** (vs GPT-4o 0.1008/0.0857/0.0212, GPT-5.2 0.0969/0.0875/0.0192).
**Slice-100K** (n 85/93/96): CRAFT best CD **0.0612** & F1 **0.2924**; GPT-4o edges IoU 0.0711 (CRAFT 0.0616).

## Table VI — Per-stage recovery (NopSCADlib, CRAFT-only)
| Layer | Trigger rate | Mean retries | Post-recovery success |
|---|---|---|---|
| schema_repair | 0.072 | 1.00 | 1.000 |
| scad_autofix | 0.007 | 1.00 | 1.000 |
| vlm_correction | 0.804 | 1.62 | 0.503 |
| component_verification | 0.173 | 1.61 | 0.000 |
| manual_repair | 0.000 | — | — |

## Table VII — Matched-effort baselines (equal LLM-call budget)
| Method | CD ↓ | F1@1% ↑ | Voxel IoU ↑ | LLM calls |
|---|---|---|---|---|
| CRAFT | 0.0654 | 0.2530 | 0.2356 | ~4.7 |
| direct_repair | 0.0684 | 0.2576 | 0.2217 | 1 + repair |
| direct_vlm | 0.0684 | 0.2612 | 0.2285 | 1 + VLM (success 317/468) |
| direct_matched_calls | 0.0678 | 0.2651 | 0.2262 | 5 (matched) |
| GPT-5.2 | 0.0662 | 0.2587 | 0.1890 | 1 |

**Every CRAFT-vs-matched-effort comparison is statistically NON-significant** (all p_adj > 0.24). → At equal compute, geometric quality is a **statistical tie**; geometry is largely compute-bound.

## Table VIII — Editability (NopSCADlib)
| Method | Exposed params | Symbolic % | Edit success | Post-edit valid |
|---|---|---|---|---|
| **CRAFT** | **13.1** | **66.8%** | 99.9% | 99.1% |
| GPT-5.2 | 4.2 | 47.7% | 99.2% | 97.7% |
| GPT-4o | 0.1 | 3.0% | 95.0% | 95.0% |
Per-tier symbolic (CRAFT): Simple 59.2% → Medium 63.9% → Complex 78.1%.

### Editability at matched compute (`metrics/nopscadlib/editability_matched/`)
| Method | Exposed params | Symbolic % |
|---|---|---|
| **CRAFT** | **13.1** | 66.8% |
| direct_vlm | 8.8 | 69.1% |
| direct_repair | 6.0 | 57.3% |
| direct_matched_calls | 6.0 | 59.4% |

**Honest read:** CRAFT exposes ~1.5–2× more parameters even at matched compute, but the *symbolic-preservation* gap closes (a strong model with effort produces parametric SCAD too). Claim = "more exposed parameters," **not** "only CRAFT is editable."

---

## Honest narrative for the paper (write to this — it survives reviewer re-runs)

**Significant, defensible wins (lead here):**
1. **Editability** — most exposed parameters at every compute level (13.1 vs 0.1/4.2 single-shot, vs 6–8.8 matched).
2. **Perceptual** — CLIP + FID.
3. **Retrieval is the engine** — ablation significant on all 3 metrics.
4. **Generalization** — wins both external datasets with retrieval *off*.
5. **Robustness quantified** — recovery stats (Table VI).

**Concede precisely (don't overclaim — all three reviewers flagged "overstating"):**
- Geometry: "competitive, tied-or-better, never significantly worse" — not dominant. F1 "loss" is p=0.94 (tie).
- Matched-effort: geometry is a statistical tie → "geometry is compute-bound; CRAFT's value is structural (editability + retrieval), not raw geometry."
- Editability at matched compute: "~2× more params," not "baselines can't edit."
- `no_verification` improves CD (p=0.012) → frame verification as **completeness**, not geometry; state the trade-off.
- `no_json_ir` weak on geometry → argue it via **editability**, not geometry.
