#!/usr/bin/env python3
"""
Full CRAFT v2 pipeline runner for the Chamfer-distance benchmark.

Runs the complete CRAFT stack on each bench prompt:
    prompt enhancement (KB)
    understanding (GPT-5.2, KB-augmented)
    sketch generation (Stage 1.5)
    planning (GPT-5.2, sketch-grounded)
    compilation (GPT-4o)
    render-quality gate
    VLM self-correction (GPT-5.2)
    component verification (GPT-5.2)
    STL export

For each of the N prompts we copy the resulting artifacts into
`runs/craft/<id>/` (prompt.txt, model.scad, model.stl, sketch.png,
final_render.png, state.json) and drop the STL into `stls/craft/<id>.stl`
so `run_eval.py` can pair it with the GT directly.

Usage
-----
    cd Experimentation/Chamfer_distance
    python benchmark/run_craft.py              # 10 prompts (default)
    python benchmark/run_craft.py -n 3         # smaller smoke test
    python benchmark/run_craft.py --no-sketch  # ablate Stage 1.5

Important
---------
The CRAFT pipeline expects to run from `pipeline/` (it writes to
`scad_scripts/`, `plans/`, `static/`). This script cd's there before each
run and restores the original cwd when done.
"""

from __future__ import annotations

import argparse
import contextlib
import json
import os
import shutil
import sys
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
CD_ROOT = HERE.parent
REPO_ROOT = CD_ROOT.parent.parent
PIPELINE_DIR = REPO_ROOT / "pipeline"

sys.path.insert(0, str(PIPELINE_DIR))
sys.path.insert(0, str(HERE))

from bench_utils import (                  # noqa: E402
    load_bench_items,
    ensure_ground_truth_copied,
    method_run_dir,
    method_stl_path,
    write_prompt_record,
    print_items,
    BenchItem,
)


@contextlib.contextmanager
def cd(path: Path):
    """Temporarily chdir into `path`, restoring the original cwd on exit."""
    prev = Path.cwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(prev)


def _verify_kb_ready_or_die() -> None:
    """
    Fail loudly if the knowledge base isn't actually populated.

    This catches the silent-degradation footgun where ``use_kb=True`` looks
    fine in code but `kb_data/component_index.json` (and/or the chroma_db
    vector store) doesn't exist on disk, in which case every "KB-augmented"
    run is effectively running with KB=off. That bug invalidates any
    KB-vs-no-KB ablation.
    """
    try:
        from kb import get_kb_status
    except Exception as exc:
        print(f"[run_craft] KB import failed: {exc}")
        print("Re-run with --no-kb if you intentionally want KB disabled.")
        sys.exit(2)

    s = get_kb_status()
    n_comp = s.get("components_indexed", 0)
    n_imgs = s.get("reference_images_count", 0)
    chroma_ok = s.get("chroma_db_exists", False)
    retr_total = s.get("retriever_stats", {}).get("total_components", 0)

    print(
        f"[KB STATUS] components_indexed={n_comp}  reference_images={n_imgs}  "
        f"chromadb_ready={chroma_ok}  retriever_components={retr_total}"
    )

    if n_comp == 0:
        print(
            "\n[FATAL] use_kb=True was requested but the KB is empty.\n"
            "        Build it once with:\n"
            "          cd pipeline && python scripts/build_knowledge_base.py\n"
            "        Or pass --no-kb if you want to run the ablation w/o KB.\n"
        )
        sys.exit(2)
    if not chroma_ok:
        print(
            "\n[WARN] ChromaDB vector store missing — semantic retrieval will\n"
            "       be disabled (only keyword/exact/alias detection will run).\n"
            "       Build vectors with:\n"
            "         cd pipeline && python scripts/build_knowledge_base.py\n"
        )


def init_pipeline(use_sketch: bool, use_kb: bool):
    """Import pipeline/app.py once and build a CRAFTPipeline.

    Importing `app` initializes the Flask app, OpenAI client, and KB — we
    ignore the Flask part and just use the pipeline class it exposes.

    When ``use_kb=True`` we verify the KB is actually populated first so
    that 'silent KB-off' runs (the bug we shipped before) cannot recur.
    """
    if use_kb:
        _verify_kb_ready_or_die()
    import app  # noqa: F401 — initializes client + KB side effects
    from app import CRAFTPipeline, client, MODEL_PIPELINE, MODEL_VLM
    return CRAFTPipeline(
        client=client,
        model_pipeline=MODEL_PIPELINE,
        model_vlm=MODEL_VLM,
        use_kb=use_kb,
        use_sketch=use_sketch,
    )


def run_one(pipeline, item: BenchItem, method: str) -> dict:
    """Run CRAFT on a single prompt and collect artifacts."""
    from utils.openscad_runner import export_stl

    run_dir = method_run_dir(method, item.id)
    write_prompt_record(run_dir, item)

    entry: dict = {"id": item.id, "tier": item.tier}

    # Pipeline writes into pipeline/scad_scripts, pipeline/plans, pipeline/static/*.
    # Running from PIPELINE_DIR so relative paths in app.py resolve correctly.
    with cd(PIPELINE_DIR):
        t0 = time.time()
        try:
            state = pipeline.run_text(item.prompt)
        except Exception as exc:
            entry["error"] = f"pipeline raised: {exc}"
            print(f"     PIPELINE ERROR: {exc}")
            return entry
        entry["pipeline_seconds"] = time.time() - t0
        entry["timestamp"] = state.timestamp
        entry["plan_valid"] = bool(getattr(state, "plan_valid", False))
        entry["prompt_enhanced"] = bool(getattr(state, "prompt_enhanced", False))
        entry["sketch_used"] = bool(getattr(state, "sketch_used", False))
        entry["vlm_correction_used"] = bool(getattr(state, "vlm_correction_used", False))
        entry["vlm_iterations"] = int(getattr(state, "vlm_iterations", 0) or 0)
        entry["component_verification_used"] = bool(getattr(state, "component_verification_used", False))
        entry["kb_augmented"] = bool(getattr(state, "kb_augmented", False))

        scad_src = Path(state.scad_path) if state.scad_path else None
        if not scad_src or not scad_src.exists():
            entry["error"] = "pipeline produced no SCAD"
            print("     PIPELINE ERROR: no SCAD produced")
            return entry

        # Copy artifacts into run_dir
        shutil.copy2(scad_src, run_dir / "model.scad")
        if state.image_path and Path(state.image_path).exists():
            shutil.copy2(state.image_path, run_dir / "final_render.png")
        if getattr(state, "sketch_path", None) and Path(state.sketch_path).exists():
            shutil.copy2(state.sketch_path, run_dir / "sketch.png")

        # Dump a lightweight state snapshot for traceability
        try:
            (run_dir / "state.json").write_text(json.dumps(state.to_dict(), indent=2, default=str))
        except Exception:
            pass

        # Export STL
        stl_dst = run_dir / "model.stl"
        t0 = time.time()
        ok, err = export_stl(str(scad_src), str(stl_dst), timeout=240)
        entry["export_seconds"] = time.time() - t0
        entry["export_ok"] = ok
        if not ok:
            entry["export_error"] = (err or "")[:500]
            print(f"     STL EXPORT FAILED: {(err or '')[:120]}")
            return entry

    # Copy final STL to the flat stls/<method>/<id>.stl layout for run_eval
    final_stl = method_stl_path(method, item.id)
    final_stl.write_bytes(stl_dst.read_bytes())
    entry["final_stl"] = str(final_stl.relative_to(CD_ROOT))
    print(
        f"     STL  -> {final_stl.relative_to(CD_ROOT)}  "
        f"({stl_dst.stat().st_size // 1024} KB, "
        f"pipeline {entry['pipeline_seconds']:.1f}s, export {entry['export_seconds']:.1f}s)"
    )
    return entry


def run(n: int, method: str, use_sketch: bool, use_kb: bool, stratified: bool) -> None:
    items = load_bench_items(n=n, stratified=stratified)
    ensure_ground_truth_copied(items)
    print_items(items)

    print(f"Initializing CRAFT pipeline (use_kb={use_kb}, use_sketch={use_sketch})...")
    pipeline = init_pipeline(use_sketch=use_sketch, use_kb=use_kb)
    print("Pipeline ready.\n")

    summary = {
        "method": method,
        "n": n,
        "use_kb": use_kb,
        "use_sketch": use_sketch,
        "items": [],
    }
    ok = 0
    for i, item in enumerate(items, 1):
        print(f"[{i:2d}/{n}] {item.id}  ({item.tier})")
        entry = run_one(pipeline, item, method)
        summary["items"].append(entry)
        if entry.get("export_ok"):
            ok += 1

    summary["ok"] = ok
    out_json = CD_ROOT / "runs" / method / "summary.json"
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_json.write_text(json.dumps(summary, indent=2))

    print()
    print(f"Done. {ok}/{n} STLs produced for {method}.")
    print(f"Summary: {out_json.relative_to(CD_ROOT)}")
    print(f"Final STLs for run_eval: stls/{method}/*.stl")


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("-n", "--num-examples", type=int, default=30)
    ap.add_argument("--method", default="craft", help="Output subdir name (default: craft)")
    ap.add_argument("--no-sketch", action="store_true", help="Disable Stage 1.5 sketch grounding")
    ap.add_argument("--no-kb", action="store_true", help="Disable RAG / knowledge base")
    ap.add_argument("--stratified", action="store_true",
                    help="Round-robin across component families for shape diversity.")
    return ap.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run(
        n=args.num_examples,
        method=args.method,
        use_sketch=not args.no_sketch,
        use_kb=not args.no_kb,
        stratified=args.stratified,
    )
