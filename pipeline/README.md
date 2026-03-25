# CRAFT Pipeline

Core implementation of the six-stage CRAFT pipeline for text-to-parametric CAD generation.

See the [main README](../README.md) for an overview of the full system.

## Structure

```
pipeline/
├── core/                   # Pipeline stages
│   ├── reasoner.py         # Stage 1: Understanding (text + vision)
│   ├── planner.py          # Stage 2: Planning (JSON IR generation)
│   ├── compiler.py         # Stage 3: Compilation (JSON → OpenSCAD)
│   ├── visual_corrector.py # Stage 5: VLM Self-Correction
│   ├── component_verifier.py # Stage 6: Component Verification
│   ├── schema.py           # JSON CAD Plan schema & validation
│   ├── validator.py        # Deterministic syntax & render checks
│   ├── repair.py           # Targeted code repair
│   ├── scad_autofix.py     # SCAD auto-fix (Layer 2 recovery)
│   ├── vision.py           # Multi-view image analysis
│   ├── prompt_enhancer.py  # Prompt enhancement
│   └── llm_client.py       # Unified LLM API wrapper
├── kb/                     # Knowledge base (NopSCADlib RAG)
│   ├── detector.py         # Standard component mention detection
│   ├── retriever.py        # Vector-store retrieval
│   ├── indexer.py          # NopSCADlib parser & indexer
│   ├── dimensional_matcher.py # Dimensional attribute matching
│   ├── renderer.py         # Reference component rendering
│   ├── verifier.py         # Component validation
│   └── component_filter.py # Subpart vs assembly filtering
├── utils/
│   ├── openscad_runner.py  # OpenSCAD rendering (Stage 4)
│   ├── rendering.py        # Multi-view render utilities
│   ├── metrics.py          # Inline metric helpers
│   └── parameter_parser.py # Parameter extraction from SCAD
├── app.py                  # Web interface (Flask)
├── requirements.txt
├── static/                 # Web assets
└── templates/              # HTML templates
```

## Quick Start

```bash
# Set your API key
export OPENAI_API_KEY=your_key_here

# Install dependencies
pip install -r requirements.txt

# Launch
python app.py
```

Open http://localhost:5000 in your browser.
