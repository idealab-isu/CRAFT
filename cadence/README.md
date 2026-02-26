# CADence

**Multi-Agent Text-to-CAD Pipeline**

CADence is a modular, transparent system for generating parametric CAD models from natural language descriptions or multi-view images. Unlike monolithic neural approaches, CADence uses a multi-agent architecture with explicit intermediate representations, enabling error recovery, iterative refinement, and human-in-the-loop improvement.

## Key Features

- **Parametric Intermediate Representation**: JSON-based CAD plan schema that preserves design intent
- **Multi-Modal Input**: Text descriptions OR multi-view images (6 ortho + 4 iso views)
- **Transparent Pipeline**: Each stage is inspectable and debuggable
- **Automatic Validation & Repair**: Deterministic validation with targeted repair
- **Human-in-the-Loop**: Manual refinement with natural language hints

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CADence Pipeline                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   INPUT                  UNDERSTANDING              PLANNING         │
│   ─────                  ────────────              ────────         │
│   ┌──────────┐          ┌─────────────┐          ┌──────────────┐  │
│   │   Text   │───────►  │    Text     │          │              │  │
│   │  Prompt  │          │  Reasoner   │──────►   │   Planner    │  │
│   └──────────┘          └─────────────┘          │              │  │
│                                │                  │   (JSON IR)  │  │
│   ┌──────────┐          ┌─────────────┐          │              │  │
│   │  10-View │───────►  │   Vision    │──────►   └──────┬───────┘  │
│   │  Images  │          │  Analyzer   │                 │          │
│   └──────────┘          └─────────────┘                 │          │
│                                                         ▼          │
│   COMPILATION            VALIDATION                  OUTPUT        │
│   ───────────            ──────────                  ──────        │
│   ┌──────────────┐      ┌──────────────┐          ┌──────────┐   │
│   │   Compiler   │──►   │  Validator   │──────►   │  OpenSCAD │   │
│   │              │      │ (Deterministic)│          │   + PNG   │   │
│   │ JSON→OpenSCAD│      └──────┬───────┘          └──────────┘   │
│   └──────────────┘             │                                  │
│          ▲                     │ if failed                        │
│          │              ┌──────▼───────┐                          │
│          └──────────────┤   Repairer   │                          │
│                         │ (Targeted Fix)│                          │
│                         └──────────────┘                          │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

## Installation

### Prerequisites

- Python 3.10+
- OpenSCAD (for rendering)
- OpenAI API key (for GPT models)
- Google Gemini API key (optional, for Gemini models)

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/cadence.git
cd cadence

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Install OpenSCAD
# Ubuntu: sudo apt install openscad
# macOS: brew install openscad
# Windows: Download from https://openscad.org/downloads.html

# Set up API keys
echo "OPENAI_API_KEY=your-openai-key-here" > .env
echo "GEMINI_API_KEY=your-gemini-key-here" >> .env
# OR create keys.json: {"gpt": "your-openai-key", "gemini": "your-gemini-key"}
```

## Usage

### Web Interface

```bash
python app.py
```

Open http://localhost:5000 in your browser.

### Programmatic Usage

```python
from openai import OpenAI
from core import TextReasoner, Planner, Compiler, Validator
from utils import render_scad_code

# Initialize
client = OpenAI()

# Create design brief from text
reasoner = TextReasoner(client)
brief = reasoner.analyze("A coffee mug with a handle on the right side")

# Generate CAD plan
planner = Planner(client)
plan_result = planner.create_plan(brief)

if plan_result.valid:
    # Compile to OpenSCAD
    compiler = Compiler(client)
    scad_code = compiler.compile(plan_result.plan)
    
    # Validate
    validator = Validator()
    validation = validator.validate(
        scad_code,
        brief.expected_parts,
        brief.description
    )
    
    print(f"Validation Score: {validation.score}/100")
    print(f"Passed: {validation.passed}")
```

### Batch Evaluation

```bash
# Evaluate on Slice 100k dataset
python evaluate.py --data_dir /path/to/slice100k --samples 100

# With caption ablation study
python evaluate.py --data_dir /path/to/slice100k --caption_ablation

# Custom dataset
python evaluate.py --data_dir /path/to/custom --custom_views
```

## JSON CAD Plan Schema

The intermediate representation is a JSON schema that captures:

```json
{
  "metadata": {
    "version": "1.0",
    "units": "mm",
    "description": "Coffee mug with handle"
  },
  "parameters": {
    "W": 80,
    "H": 100,
    "wall_t": 3,
    "handle_r": 15
  },
  "geometry": {
    "base_shapes": [
      {
        "id": "outer_cylinder",
        "type": "cylinder",
        "radius": "W/2",
        "height": "H",
        "center": true
      },
      {
        "id": "inner_cylinder",
        "type": "cylinder",
        "radius": "W/2 - wall_t",
        "height": "H - wall_t",
        "position": [0, 0, "wall_t"]
      }
    ],
    "operations": [
      {
        "id": "hollow_body",
        "type": "difference",
        "target": "outer_cylinder",
        "with": ["inner_cylinder"]
      }
    ]
  },
  "final_output": "hollow_body"
}
```

## Validation Checks

The validator performs four deterministic checks:

| Check | Weight | Description |
|-------|--------|-------------|
| Syntax | 35% | OpenSCAD syntax validity, balanced brackets |
| Renders | 35% | Image contains visible geometry (not blank) |
| Geometry | 15% | No degenerate dimensions, has 3D primitives |
| Coverage | 15% | Expected parts are present in the code |

**Pass threshold**: 80/100

## Project Structure

```
cadence/
├── app.py                 # Flask web application
├── evaluate.py            # Batch evaluation script
├── requirements.txt
├── core/
│   ├── __init__.py
│   ├── schema.py          # JSON CAD Plan schema
│   ├── reasoner.py        # Text understanding
│   ├── vision.py          # Multi-view image analysis
│   ├── planner.py         # Design brief → JSON plan
│   ├── compiler.py        # JSON plan → OpenSCAD
│   ├── validator.py       # Deterministic validation
│   └── repair.py          # Targeted code repair
├── utils/
│   ├── __init__.py
│   ├── openscad_runner.py # OpenSCAD execution
│   ├── rendering.py       # Multi-view rendering
│   └── metrics.py         # SSIM, IoU computation
├── templates/
│   └── index.html         # Web UI
├── static/images/         # Generated renders
├── scad_scripts/          # Generated .scad files
├── plans/                 # Generated JSON plans
└── evaluation/
    └── results/           # Evaluation outputs
```

## Configuration

Environment variables (in `.env`):

```bash
OPENAI_API_KEY=sk-...
MODEL_PRIMARY=gpt-4o        # Main model
MODEL_SECONDARY=gpt-4o      # Fallback model
MAX_PLAN_ATTEMPTS=2         # Planning retries
MAX_REPAIR_ATTEMPTS=2       # Repair retries
AUTO_REPAIR=true            # Enable auto-repair
PASS_THRESHOLD=0.80         # Validation threshold
PORT=5000                   # Server port
DEBUG=false                 # Debug mode
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `python -m pytest tests/`
5. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Citation

If you use CADence in your research, please cite:

```bibtex
@article{cadence2025,
  title={CADence: A Multi-Agent Framework for Text-to-CAD Generation},
  author={Your Name},
  journal={Geometric Modeling and Processing},
  year={2025}
}
```

## Acknowledgments

- OpenSCAD project for the rendering engine
- OpenAI for the language models
- Slice 100k dataset contributors
