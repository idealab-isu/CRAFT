# CRAFT: Corrective and Robust Multi-Agent Framework for Text-to-Parametric CAD

CRAFT is a corrective and robust multi-agent framework for text-to-parametric CAD generation. It produces executable and editable OpenSCAD programs from natural language without task-specific training through three core mechanisms: a JSON-based intermediate representation that preserves symbolic parametric expressions, multi-view visual feedback to detect and correct geometric errors, and a layered recovery strategy to handle failures at every stage of the pipeline.

<p align="center">
  <img src="paper/figures/png/CAD_Pipeline.png" alt="CRAFT Pipeline Overview" width="90%"/>
</p>


## Key Idea

Supervised methods that fine-tune models on paired text-CAD datasets can produce geometrically plausible outputs within their training distribution, but generalize poorly to novel shapes and require substantial curated data to train. Zero-shot prompting strategies avoid this data dependency but are prone to generating syntactically invalid code, non-renderable geometry, and outputs that fail to faithfully reflect the original prompt. Critically, both families of approaches tend to produce hard-coded numeric geometry rather than editable parametric models, limiting their utility for downstream engineering and customization tasks.

CRAFT addresses these limitations by decomposing CAD generation into six discrete stages — understanding, planning, compilation, rendering, self-correction, and verification — each of which can be independently validated and repaired. This staged architecture allows errors to be detected and corrected locally rather than propagating silently into the final output.

## Pipeline

CRAFT transforms natural language descriptions and optional reference images into parametric OpenSCAD code through six sequential stages. Reasoning-intensive stages (understanding, planning, VLM self-correction, and component verification) are handled by GPT-5.2, while deterministic translation and repair steps are handled by GPT-4o.

**Stage 1 — Understanding.** Image and text inputs are processed in parallel. The image-analysis path extracts geometric cues from any provided reference images and fuses information across views. The text-reasoning path parses the prompt to identify required components, classify them by importance (essential, secondary, optional), and detect references to standard parts such as motors or fasteners. When such components are recognized, their specifications are retrieved from NopSCADlib using five strategies: exact name matching, fuzzy name matching, category-based lookup, dimensional attribute matching, and semantic embedding retrieval.

**Stage 2 — Planning.** The output of Stage 1 is passed to planning, where the planner produces a JSON CAD plan. This intermediate representation encodes geometry, constructive solid geometry (CSG) operations, and symbolic parametric expressions in a structured format that can be validated before any code is generated. Unlike direct code generation, the IR preserves symbolic parametric expressions rather than evaluating them into constants. Expressions such as `"outer_diameter/2"` are passed directly into the compiled OpenSCAD code, allowing the final model to remain editable and fully parametric.

**Stage 3 — Compilation.** The validated plan is translated into OpenSCAD code that preserves expression strings and generates parameter ranges for the customizer interface.

**Stage 4 — Rendering.** OpenSCAD produces six orthographic views: front, back, left, right, top, and bottom. The renderer applies timeout-aware simplifications for computationally expensive constructs such as `hull()`, which can become slow when computing enclosing geometry over multiple primitives.

**Stage 5 — VLM Self-Correction.** A vision-language model compares the rendered output against the original prompt and iteratively proposes fixes for up to three rounds. The VLM returns a confidence score on a 0–1 scale, a list of identified issues, and suggested corrections. If the confidence falls below 0.95, the system generates targeted fixes for the affected parts rather than regenerating the entire design, with early stopping once the confidence threshold is reached.

**Stage 6 — Component Verification.** Component verification checks whether the expected parts are present using tiered confidence thresholds of 85% for essential parts, 65% for secondary parts, and 50% for optional parts. These thresholds prioritize functionally necessary components over cosmetic details.

### Layered Error Recovery

CRAFT addresses failures through a five-layer strategy that orders repair mechanisms from inexpensive structural fixes to more costly semantic correction:

1. **Schema Auto-Repair** — JSON schema validation and automatic repair (max 2 retries)
2. **SCAD Auto-Fix** — Detects `hull`/`minkowski`/high-`$fn` constructs, simplifies, and extends timeout
3. **VLM Correction** — Six-view render → GPT-5.2 assessment → LLM fix → iterate (max 3)
4. **Component Verification** — Tiered part check → connectivity check → targeted fix (max 3)
5. **Manual Repair** — User hint (e.g., "make wheels bigger") incorporated into prompt

Automatic recovery operates under a fixed retry budget of 10 total attempts across the first four layers, set empirically to balance correction capability against latency and cost.

## Results

CRAFT is evaluated on three datasets totaling 668 components to assess both in-domain performance and cross-dataset generalization:

| Dataset | Samples | Description |
|---------|---------|-------------|
| **NopSCADlib** | 468 | Parametric OpenSCAD mechanical components (primary benchmark) |
| **ABC** | 100 | Shapes from the ABC dataset (cross-dataset generalization) |
| **Slice-100K** | 100 | Extrusion-based 3D printing models (cross-dataset generalization) |

Baselines are single-stage direct generation using GPT-4o and GPT-5.2, receiving the same text prompt with a system prompt instructing the model to output valid OpenSCAD code. Generation uses temperature 0.0 in a single API call, with no intermediate JSON planning, no component retrieval, no visual feedback, and no error recovery.

### Perceptual Alignment (NopSCADlib)

| Metric | CRAFT | GPT-4o | GPT-5.2 | Ground Truth |
|--------|-------|--------|---------|-------------|
| CLIP Score ↑ | **0.2223** | 0.2033 | 0.2145 | 0.2333 |
| FID ↓ | **94.47** | 118.01 | 104.63 | — |

### Geometric Accuracy (ABC)

| Metric | CRAFT | GPT-4o | GPT-5.2 |
|--------|-------|--------|---------|
| Chamfer Distance ↓ | **0.0804** | 0.1009 | 0.0950 |
| F1 ↑ | **0.1303** | 0.0847 | 0.0880 |
| Voxel IoU ↑ | **0.0401** | 0.0211 | 0.0187 |

### Geometric Accuracy (Slice-100K)

| Metric | CRAFT | GPT-4o | GPT-5.2 |
|--------|-------|--------|---------|
| Chamfer Distance ↓ | **0.0617** | 0.0743 | **0.0607** |
| F1 ↑ | **0.2831** | 0.2146 | 0.2828 |
| Voxel IoU ↑ | 0.0633 | **0.0718** | 0.0627 |

On ABC, CRAFT achieves the strongest overall performance across all three metrics, with especially pronounced margins on complex components, indicating consistent generalization across prompt difficulty on previously unseen geometry. On Slice-100K, results are more comparable: GPT-5.2 achieves the lowest CD, CRAFT achieves the highest F1, and GPT-4o attains the highest voxel IoU. Structured planning and layered recovery offer limited advantage on simple targets, but become increasingly useful when prompts require multiple relations, reusable dimensions, coordinated part composition, and recovery from intermediate errors.

### Geometric Accuracy (NopSCADlib)

| Metric | CRAFT | GPT-4o | GPT-5.2 |
|--------|-------|--------|---------|
| Chamfer Distance ↓ | **0.0704** | 0.0742 | **0.0671** |
| F1 ↑ | 0.2369 | 0.2467 | **0.2585** |
| Voxel IoU ↑ | **0.2242** | 0.2182 | 0.1870 |

On NopSCADlib, GPT-5.2 leads on CD and F1 while CRAFT achieves the highest voxel IoU, indicating that direct generation can yield slightly better average surface proximity on in-distribution examples, whereas CRAFT produces stronger volumetric consistency.

## Repository Structure

```
CRAFT/
├── pipeline/              # Core 6-stage CRAFT pipeline
│   ├── core/              #   Reasoner, Planner, Compiler, Visual Corrector, etc.
│   ├── kb/                #   NopSCADlib knowledge base (RAG)
│   ├── utils/             #   OpenSCAD runner, rendering, parameter parsing
│   └── app.py             #   Web interface
│
├── evaluation/            # Evaluation framework
│   ├── evaluate_*.py      #   CLIP, FID, Hausdorff, Normal Consistency
│   ├── run_*.py           #   Benchmark runners (CRAFT + baselines)
│   ├── ext_step*.py       #   External dataset evaluation pipeline
│   └── ground_truth/      #   Reference data and renders
│
├── results/               # Generated outputs (scad + stl + png per method)
│   ├── craft/             #   CRAFT pipeline outputs
│   ├── gpt4o/             #   GPT-4o baseline outputs
│   ├── gpt52/             #   GPT-5.2 baseline outputs
│   ├── abc/               #   ABC dataset results (craft/ gpt4o/ gpt52/)
│   └── slice100k/         #   Slice-100K dataset results
│
├── metrics/               # Computed evaluation metric results
│   ├── clip/
│   ├── fid/
│   ├── hausdorff/
│   ├── lpips/
│   └── normal_consistency/
│
├── datasets/              # External dataset samples (ABC, Slice-100K)
└── paper/                 # LaTeX sources and figures
```

## Setup

### Requirements

- Python 3.10+
- [OpenSCAD](https://openscad.org/) (for rendering and STL export)
- OpenAI API key (GPT-4o and GPT-5.2)

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
export OPENAI_API_KEY=your_key_here
python pipeline/app.py
```

### Running Evaluations

```bash
# Run CRAFT benchmark on NopSCADlib
python evaluation/run_craft_benchmark.py

# Run GPT baselines for comparison
python evaluation/run_gpt_baselines.py

# Compute metrics
python evaluation/evaluate_clip_score.py
python evaluation/evaluate_fid.py
python evaluation/evaluate_hausdorff.py
python evaluation/evaluate_normal_consistency.py
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
