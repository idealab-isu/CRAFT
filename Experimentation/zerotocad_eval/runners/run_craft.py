"""Run CRAFT v3 image-only over a directory of Z2C-style samples.

Inputs come from `Experimentation/zerotocad_eval/data/{benchmark}/{uuid}/`
in the layout produced by `fetch_ztc_test.py`. Outputs land at:

    results/zerotocad_eval/{benchmark}/craft_v3/{uuid}/
        output.scad      generated OpenSCAD source
        output.stl       rendered STL (via the OpenSCAD CLI)
        audit.json       timings + success flags + pipeline state subset

This runner does NOT score — pass the resulting folder to
`Experimentation/zerotocad_eval/score_sample.py` (or `run_eval.py` which
calls it batch-style).
"""

from __future__ import annotations

import argparse
import json
import sys
import traceback
from pathlib import Path
from typing import Optional


_HERE = Path(__file__).resolve()
_REPO_ROOT = _HERE.parents[3]
# pipeline/ is structured as a top-level package on the user's machine when
# they run `python pipeline/app.py`. We add it to sys.path so we can import
# CRAFTPipeline from the runner without modifying their existing layout.
sys.path.insert(0, str(_REPO_ROOT / "pipeline"))

from ._common import (  # noqa: E402  -- sys.path mutation above
    SampleDirs,
    RunAudit,
    iter_sample_dirs,
    openscad_to_stl,
    stopwatch,
)


def _maybe_load_pipeline():
    """Import the CRAFT pipeline lazily so this module imports cleanly even
    when optional CRAFT deps (chromadb, openai, etc.) are missing.

    Returns a constructed CRAFTPipeline instance — uses get_pipeline() from
    app.py which wires the module-level OpenAI client created from
    OPENAI_API_KEY / keys.json.

    We disable KB (Z2C shapes aren't NopSCADlib catalog parts; KB retrieval
    would be inert overhead) and the sketch step (the input views ARE the
    spec; a generated sketch is redundant and costs an extra image-gen call).
    """
    try:
        from app import get_pipeline  # type: ignore  -- pipeline/app.py
    except ImportError as e:
        sys.stderr.write(
            f"Failed to import CRAFT pipeline (pipeline/app.py): {e}\n"
            "Make sure CRAFT's runtime deps are installed in the active env "
            "(see pipeline/requirements.txt). Also set OPENAI_API_KEY / "
            "GEMINI_API_KEY in your shell or pipeline/keys.json.\n"
        )
        raise
    return get_pipeline(use_kb=False, use_sketch=False)


def run_one(pipeline, sample: SampleDirs) -> RunAudit:
    """Run CRAFT v3 on one sample. Always writes audit.json; STL only on success."""
    sample.method_out_dir.mkdir(parents=True, exist_ok=True)
    lap = stopwatch()
    audit = RunAudit(method="craft_v3", uuid=sample.uuid, output_lang="openscad",
                     success_code=False, success_stl=False)

    try:
        state = pipeline.run_zerotocad_vision([str(p) for p in sample.view_paths])
        audit.timing_seconds["craft_pipeline"] = lap()

        scad_code = getattr(state, "scad_code", None)
        if not scad_code or len(scad_code.strip()) < 20:
            audit.error = "no_scad_code_produced"
            audit.write(sample.method_out_dir)
            return audit

        scad_path = sample.method_out_dir / "output.scad"
        scad_path.write_text(scad_code)
        audit.success_code = True

        stl_path = openscad_to_stl(scad_code, sample.method_out_dir / "output.stl")
        audit.timing_seconds["openscad_render"] = lap()
        audit.success_stl = stl_path is not None and stl_path.exists()
        if not audit.success_stl:
            audit.error = "openscad_render_failed"

        # Capture a small slice of pipeline state for downstream debugging.
        audit.extra = {
            "design_brief_description": (
                getattr(state.design_brief, "description", None)[:600]
                if getattr(state, "design_brief", None) is not None else None
            ),
            "v3_gap_refinement": getattr(state, "v3_gap_refinement", None),
            "vlm_approved": getattr(state, "vlm_approved", None),
            "input_view_count": len(sample.view_paths),
        }

    except Exception as e:
        audit.error = f"{type(e).__name__}: {e}"
        audit.extra["traceback"] = traceback.format_exc(limit=10)

    audit.write(sample.method_out_dir)
    return audit


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--data-root",
        default=str(_REPO_ROOT / "Experimentation/zerotocad_eval/data/ztc_test"),
        help="Per-sample input folder root.",
    )
    parser.add_argument(
        "--out-root",
        default=str(_REPO_ROOT / "results/zerotocad_eval/ztc_test/craft_v3"),
        help="Method output root (one subfolder per UUID).",
    )
    parser.add_argument("--limit", type=int, default=None,
                        help="Stop after N samples (default: all).")
    parser.add_argument("--force", action="store_true",
                        help="Re-run samples that already have output.")
    args = parser.parse_args()

    data_root = Path(args.data_root).resolve()
    out_root = Path(args.out_root).resolve()
    out_root.mkdir(parents=True, exist_ok=True)

    samples = iter_sample_dirs(
        data_root, out_root, limit=args.limit, skip_existing=not args.force
    )
    print(f"CRAFT v3 image-only run: {len(samples)} samples → {out_root}")

    if not samples:
        return 0

    pipeline = _maybe_load_pipeline()

    n_code = n_stl = 0
    for i, s in enumerate(samples, 1):
        print(f"[{i}/{len(samples)}] {s.uuid} …", flush=True)
        audit = run_one(pipeline, s)
        n_code += int(audit.success_code)
        n_stl += int(audit.success_stl)
        print(f"      code={audit.success_code} stl={audit.success_stl} err={audit.error}")

    print(f"\nDone. {n_stl}/{len(samples)} produced an STL, "
          f"{n_code}/{len(samples)} produced source.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
