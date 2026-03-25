# CRAFT: Corrective and Robust Multi-Agent Framework for Text-to-Parametric CAD

CRAFT is a multi-agent pipeline that generates parametric [OpenSCAD](https://openscad.org/) programs from natural language descriptions. Unlike direct code generation approaches, CRAFT preserves symbolic parametric relationships throughout generation, producing CAD models that are executable, editable, and reusable.

<p align="center">
  <img src="paper/figures/png/CAD_Pipeline.png" alt="CRAFT Pipeline Overview" width="90%"/>
</p>


## Key Idea

Existing text-to-CAD methods either fine-tune on paired datasets (limiting generalization) or prompt LLMs directly (producing brittle, non-parametric code). CRAFT takes a different approach: it decomposes CAD generation into six specialized stages connected by a JSON intermediate representation that keeps dimensions as symbolic expressions rather than collapsing them into hard-coded numbers. A layered error recovery strategy handles failures at every stage, from malformed JSON to geometrically incorrect renders.

## Pipeline

CRAFT maps a text prompt (and optional reference images) to a parametric OpenSCAD program through six sequential stages:

**Stage 1 — Understanding.** A reasoning LLM parses the prompt to extract a structured design brief: required components classified by importance (essential, secondary, optional), geometric relationships, and material properties. When standard parts like motors or bearings are mentioned, their specifications are retrieved from NopSCADlib via five matching strategies (exact name, fuzzy, category, dimensional, and semantic embedding).

**Stage 2 — Planning.** The design brief is converted into a JSON CAD plan — an intermediate representation that encodes geometry, CSG operations, and parametric expressions in a structured, validatable format. Dimensions are stored as symbolic strings (e.g., `"outer_diameter/2"`) rather than evaluated constants, so the final code remains fully editable.

**Stage 3 — Compilation.** The validated JSON plan is translated into OpenSCAD code. The compiler preserves expression strings from the IR, generates top-level parameter declarations with meaningful ranges, and maps primitives to OpenSCAD functions.

**Stage 4 — Rendering.** OpenSCAD compiles the program and produces six orthographic views (front, back, left, right, top, bottom) at 512x512 resolution, with timeout-aware handling of expensive CSG operations like `hull()`.

**Stage 5 — VLM Self-Correction.** A vision-language model compares the six rendered views against the original prompt, returning a confidence score and a list of geometric issues. If confidence falls below 0.95, the system generates targeted fixes for affected parts and re-renders. This loop runs for up to three iterations.

**Stage 6 — Component Verification.** A final check verifies that expected parts are geometrically present using tiered confidence thresholds: 85% for essential parts, 65% for secondary, and 50% for optional. Missing or malformed components trigger targeted repair for up to three iterations.

### Layered Error Recovery

Failures can occur at any stage. CRAFT addresses this through five recovery layers, ordered from cheap structural fixes to expensive semantic corrections:

1. **Schema Auto-Repair** — JSON validation + LLM repair (max 2 retries)
2. **SCAD Auto-Fix** — Detects expensive constructs (`hull`, `minkowski`), simplifies, extends timeout
3. **VLM Correction** — Six-view render + VLM feedback + LLM fix (max 3 iterations)
4. **Component Verification** — Tiered part check + connectivity check + targeted fix (max 3 iterations)
5. **Manual Repair** — User hint incorporated into prompt for re-generation

All recovery operates under a fixed budget of 10 total attempts across the first four layers.

## Results

CRAFT is evaluated on three datasets totaling 668 components:

| Dataset | Samples | Description |
|---------|---------|-------------|
| **NopSCADlib** | 468 | Parametric OpenSCAD mechanical components (primary benchmark) |
| **ABC** | 100 | Geometric shapes from the ABC dataset (out-of-distribution) |
| **Slice-100K** | 100 | Extrusion-based 3D printing models (out-of-distribution) |

### Perceptual Alignment (NopSCADlib)

| Metric | CRAFT | GPT-4o | GPT-5.2 | Ground Truth |
|--------|-------|--------|---------|-------------|
| CLIP Score | **0.2223** | 0.2033 | 0.2145 | 0.2333 |
| FID | **94.47** | 118.01 | 104.63 | — |

### Geometric Accuracy (ABC)

| Metric | CRAFT | GPT-4o | GPT-5.2 |
|--------|-------|--------|---------|
| Chamfer Distance ↓ | **0.0804** | 0.1009 | 0.0950 |
| F1 ↑ | **0.1303** | 0.0847 | 0.0880 |
| Voxel IoU ↑ | **0.0401** | 0.0211 | 0.0187 |

CRAFT consistently outperforms direct generation baselines, with the advantage becoming more pronounced on medium and complex designs where structured planning and iterative correction matter most.

## Repository Structure

```
CRAFT/
├── pipeline/              # Core 6-stage CRAFT pipeline
│   ├── core/              #   Reasoner, Planner, Compiler, Visual Corrector, etc.
│   ├── kb/                #   NopSCADlib knowledge base (RAG)
│   ├── utils/             #   OpenSCAD runner, rendering, parameter parsing
│   └── app.py             #   Web interface
│
├── evaluation/
│   ├── metrics/           #   CLIP, FID, Hausdorff, LPIPS, Normal Consistency
│   ├── benchmarks/        #   Benchmark runners (CRAFT + baselines)
│   ├── prompts/           #   NopSCADlib, ABC, Slice-100K prompt sets
│   ├── ground_truth/      #   Reference data and renders
│   └── utils/             #   Data preparation and rendering helpers
│
├── results/               # Generated outputs (scad + stl + png per method)
│   ├── nopscadlib/        #   craft/ gpt4o/ gpt52/
│   ├── abc/               #   craft/ gpt4o/ gpt52/
│   └── slice100k/         #   craft/ gpt4o/ gpt52/
│
├── metrics/               # Computed evaluation metric results
│   ├── clip/
│   ├── fid/
│   ├── hausdorff/
│   ├── lpips/
│   └── normal_consistency/
│
├── datasets/              # External dataset samples (ABC, Slice-100K)
├── examples/              # Qualitative examples (scad files + renders)
├── paper/                 # LaTeX sources and figures
└── docs/                  # Pipeline documentation
```

## Setup

### Requirements

- Python 3.10+
- [OpenSCAD](https://openscad.org/) (for rendering and STL export)
- OpenAI API key (GPT-4o and/or GPT-5.2)

### Installation

```bash
git clone https://github.com/itsMustafamr/CRAFT.git
cd CRAFT
pip install -r requirements.txt
```

### Knowledge Base Setup

The NopSCADlib knowledge base requires a local clone of the [NopSCADlib](https://github.com/nophead/NopSCADlib) repository:

```bash
git clone https://github.com/nophead/NopSCADlib.git
python pipeline/kb/indexer.py --nopscadlib-path ./NopSCADlib
```

### Running the Pipeline

```bash
# Set your API key
export OPENAI_API_KEY=your_key_here

# Launch the web interface
python pipeline/app.py
```

### Running Evaluations

```bash
# Run CRAFT benchmark on NopSCADlib (55 prompts)
python evaluation/benchmarks/run_craft_benchmark.py

# Run GPT baselines for comparison
python evaluation/benchmarks/run_gpt_baselines.py

# Compute metrics
python evaluation/metrics/evaluate_clip_score.py
python evaluation/metrics/evaluate_fid.py
python evaluation/metrics/evaluate_hausdorff.py
python evaluation/metrics/evaluate_lpips.py
python evaluation/metrics/evaluate_normal_consistency.py
```

## Citation

```bibtex
@inproceedings{craft2026,
  title     = {CRAFT: Corrective and Robust Multi-Agent Framework for Text-to-Parametric CAD},
  author    = {Anonymous},
  booktitle = {IEEE International Conference on Learning and Automated Design (LAD)},
  year      = {2026}
}
```

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.
