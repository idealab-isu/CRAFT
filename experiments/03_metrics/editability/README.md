# Editability Metrics

Four metrics quantifying how editable the generated parametric CAD models are.
These metrics were promised in the paper rebuttal and are unique to CRAFT
relative to typical text-to-CAD evaluations, which focus only on geometric
fidelity.

> **Status (Phase 1):** the canonical implementation `compute_editability.py`
> is added in Phase 1. This README documents the formulas and serves as the
> spec.

## The four metrics

### 1. Exposed-parameter count

Number of top-level parameters in the generated `.scad` file that a downstream
user can edit through OpenSCAD's Customizer interface (i.e., parameters with
numeric or option defaults, optionally annotated with `//[min:max]` or
`//[opt1, opt2]` range hints).

Implemented by counting the lines that successfully parse via
`pipeline/utils/parameter_parser.parse_parameters_from_scad`.

### 2. Symbolic-expression preservation rate

The proportion of secondary assignments in the generated `.scad` that depend
symbolically on at least one exposed parameter, e.g.:

```scad
outer_diameter_mm = 12.0;        // exposed parameter
inner_radius = outer_diameter_mm/2 - wall_thickness;   // symbolic — counts
plate_height = 5.0;              // numeric literal — does not count
```

The metric is `n_symbolic / n_secondary_assignments`. Detected via regex over
each `.scad` file: a secondary assignment counts as symbolic if its
right-hand side references at least one other identifier *and* contains an
arithmetic operator (`+`, `-`, `*`, `/`).

### 3. Successful parameter-edit rate

For each exposed parameter, perturb its value by both ±10% and ±50% of its
default, write the modified `.scad`, re-render via OpenSCAD, and record
success/failure. The metric is

    successful_edits / (n_parameters · n_perturbations)

Implemented using `pipeline/utils/parameter_parser.update_multiple_parameters`
followed by `pipeline/utils/openscad_runner.OpenScadRunner`.

### 4. Post-edit render validity

The fraction of edits in (3) whose resulting render is non-empty and well-formed:

- OpenSCAD exit code 0.
- Output PNG exists and is non-trivial (size > 0, foreground pixel coverage
  above a small threshold).
- No ERROR or WARNING in OpenSCAD stderr beyond an allowlist.

A failed render that produced empty output, or a crash, does not count.

## Inputs / outputs

- Inputs: `.scad` files at `results/<dataset>/<method>/scad/<prompt_id>.scad`.
- Outputs in `metrics/<dataset>/editability/`:
  - `editability_detailed.json` — per-sample, all four metrics.
  - `editability_summaries.json` — per-method and per-tier means.
  - `editability_comparison_table.md`.

## Command

```bash
python experiments/03_metrics/editability/compute_editability.py \
    --scad-dirs craft=results/nopscadlib/craft/scad \
                gpt4o=results/nopscadlib/baselines/gpt4o/scad \
                gpt52=results/nopscadlib/baselines/gpt52/scad \
    --benchmark-json ground_truth/nopscadlib/benchmark_ground_truth.json \
    --perturbations 10 50 \
    --output-dir metrics/nopscadlib/editability
```

## Why this matters for the paper

Direct LLM generation typically emits hardcoded numeric geometry. CRAFT's
JSON-IR explicitly preserves symbolic parametric expressions through to
OpenSCAD (see `pipeline/core/compiler.py:format_value`). These four metrics
quantify that contribution and directly address reviewer R-Awu5's editability
concern.

## Dependencies

`pipeline/utils/parameter_parser`, `pipeline/utils/openscad_runner`, `pillow`.
Requires OpenSCAD installed on the system path.
