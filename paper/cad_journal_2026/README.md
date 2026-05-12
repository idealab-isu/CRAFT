# CRAFT vs. Zero-to-CAD — CAD Journal 2026 submission

Source files for the journal-version submission described in
`CRAFT_zerotocad_eval_plan.md` at the repo root.

## What's here

```
paper/cad_journal_2026/
├── README.md                  ← this file
├── draft.md                   ← outline + prose skeleton with explicit TODOs
├── results_tables.md          ← headline tables to drop into the manuscript
                                 once Phase 5 numbers are in
└── (figures/, bib/ — to be added during writing)
```

## Workflow

1. Run the eval (see plan §10 + `Experimentation/zerotocad_eval/run_eval.py`).
2. Aggregated metrics will be in `results/zerotocad_eval/metrics/{benchmark}/summary.{md,json}`.
3. Fill in the TODOs in `results_tables.md` from those summary JSONs.
4. Then expand `draft.md` section-by-section using the populated tables.

Do not begin writing prose for the Results section until the headline
numbers (Phase 5) are in — the *shape* of the story depends on whether
CRAFT wins on ABC OOD by a small or large margin.
