# CRAFT Rebuttal — Handoff for Paper Writing (read this first)

**To the assistant picking this up (e.g., Cowork on Mac):** all experiments and computation for the CRAFT paper rebuttal are **finished, verified, committed, and pushed**. No more runs, metrics, or API calls are needed. The remaining work is **writing only** — the reviewer-response letter and the paper revisions. This file is your context loader.

## Read these three files for full context
1. **`RESULTS_SUMMARY.md`** — every final number, all 8 tables, significance, and the honest framing. The source of truth for results.
2. **`REBUTTAL_EXPERIMENTS.md`** — methodology: why each experiment was run, the dataset comparison, the metric definitions, and the exact code flags used to isolate each ablation agent.
3. **`RESULTS_SUMMARY.md` → "Honest narrative"** and this file's "Writing plan" below.

(Also present: `RUNBOOK.md` = the execution log of how the runs were done — only needed if a number must be re-derived.)

## Where things stand
- **Done:** main benchmark (NopSCADlib + ABC + Slice-100K), 5-variant ablation, editability, recovery statistics, paired-Wilcoxon significance, and 3 matched-effort baselines. All 8 LaTeX tables in `paper/ieee_lad_2026/tables/` are populated and verified.
- **Left:** (1) reviewer-response letter, (2) paper text edits (move ablation to main paper, FID-overall explanation, typos), (3) the honest-framing rewrites of the results discussion.

## The honest narrative (do NOT overclaim — all 3 reviewers flagged "overstating," and reviewer GyxV re-runs code)
**Lead with the significant wins:** editability (most exposed parameters at every compute level), perceptual (CLIP/FID), retrieval-is-the-engine (ablation significant on all metrics), generalization (wins both external datasets), robustness quantified (recovery stats).
**Concede precisely:** geometry is "competitive, tied-or-better, never significantly worse" — not dominant (F1 "loss" is p=0.94, a tie); at matched compute, geometry is a statistical tie (geometry is compute-bound; CRAFT's value is structural); editability gap narrows at matched compute (claim "~2× more params," not "baselines can't edit"); `no_verification` improves CD (frame verification as completeness); `no_json_ir` weak on geometry (argue via editability).

## Per-reviewer response map (each concern → the result that answers it)
- **Awu5** (weak ablation / unfair baselines / qualitative editability): Table III (ablation), Table VII (matched-effort, incl. "is it just more LLM calls?"), Table VIII (editability quantified). Also: explain "Overall FID < per-tier FID" = FID is a pooled distribution distance, not a weighted mean; fix typos (orthographic, OpenSCAD, FID, GitHub); move ablation into the main paper.
- **UJGD** (no recovery stats / overstating): Table VI (per-layer recovery), and the honest "tied-not-dominant" geometry framing.
- **GyxV** (no significance / why direct generation wins F1 / why CD only on medium-complex): significance everywhere; F1 gap is a tie (p=0.94); matched-effort shows compute drives geometry while structure gives editability; per-tier CD/F1 are in the EVALUATION SUMMARY.

## Writing plan (suggested order)
1. **Reviewer-response letter** — one section per reviewer, each point answered with the exact number + table + p-value. Highest leverage; do this first.
2. **Updated table captions + 1–2 sentence interpretations** with the honest framing baked in.
3. **Ablation + editability subsections** for the main paper (Awu5 wants ablation out of the appendix).

## Key numbers to quote (so you don't have to re-open the tables)
- FID: CRAFT 95.11 vs 119.42 / 106.22. CLIP: 0.2226 vs 0.2033 / 0.2145.
- Geometry (NopSCADlib): CRAFT CD 0.0654 (best), F1@1% 0.2530 (tie), IoU 0.2356 (best). F1@1% vs GPT-5.2 p=0.94.
- Ablation: no_retrieval significantly worse on all 3 (the headline). no_verification CD p=0.012 (caveat).
- Matched-effort: all CRAFT-vs-direct comparisons non-significant (geometry tie).
- Editability: 13.1 params (CRAFT) vs 4.2 / 0.1 (single-shot) vs 6.0–8.8 (matched compute).

## Next action for the Mac session
The user will describe their idea for how to structure the rebuttal/paper. Use the honest narrative above — propose precise, defensible claims; flag any place the user's draft overclaims relative to the significance results.
