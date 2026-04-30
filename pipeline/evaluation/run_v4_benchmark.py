#!/usr/bin/env python3
"""
CRAFT v4 Benchmark Runner.

Runs CRAFT v4 over a prompt set and writes per-prompt artifacts that match
the layout used by other CRAFT benchmark scripts (so downstream metric
scripts pick the outputs up automatically):

    <out_dir>/<dataset>/v4/scad/<id>.scad
    <out_dir>/<dataset>/v4/stl/<id>.stl
    <out_dir>/<dataset>/v4/png/<id>.png             ← isometric view (for SSIM/CLIP/FID)
    <out_dir>/<dataset>/v4/runs/<id>/audit.json     ← full v4 audit trail
    <out_dir>/<dataset>/v4/results.json             ← summary across the dataset

Supports two prompt sources:

  1. NopSCADlib in-pipeline benchmark (the one in
     pipeline/evaluation/run_nopscadlib_benchmark.py). Use:

        --source nopscadlib

  2. External-dataset ground-truth JSON (the one produced by
     evaluation/ext_step2_generate_ground_truth.py). Use:

        --source ext --benchmark-json /path/to/abc_ground_truth.json \
                     --dataset-name abc

Resume support: rerunning the same command will skip prompts whose
``audit.json`` already exists. Pass ``--force`` to redo them.

This script does NOT compute Chamfer / F1 / IoU itself — it only generates
v4 outputs in the standard layout. Use the existing metric scripts (e.g.
pipeline/evaluation/compute_chamfer_with_judge.py or
evaluation/ext_step4_evaluate.py) afterward.
"""

from __future__ import annotations

import argparse
import json
import os
import shutil
import sys
import time
from pathlib import Path
from typing import Dict, Iterable, List, Optional

# Pipeline-root + repo-root import shims.
_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
_REPO_ROOT = _PIPELINE_ROOT.parent
for p in (_REPO_ROOT, _PIPELINE_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from v4.runner import V4Config, V4Result, V4Runner  # noqa: E402


# =============================================================================
# Prompt loaders
# =============================================================================

def load_nopscadlib_prompts(quick: bool = False) -> List[dict]:
    """Pull the in-pipeline NopSCADlib benchmark prompts."""
    from evaluation.run_nopscadlib_benchmark import BENCHMARK_PROMPTS  # type: ignore
    prompts = []
    for bp in BENCHMARK_PROMPTS:
        prompts.append({
            "id": bp.id,
            "text": bp.text,
            "category": bp.category,
        })
    if quick:
        prompts = prompts[:3]
    return prompts


def load_ext_results_prompts(
    results_json: str,
    ids: Optional[List[str]] = None,
    n_prompts: Optional[int] = None,
    seed: int = 42,
) -> List[dict]:
    """Load prompts from a CRAFT results.json (the kind written by the
    existing ABC / Slice-100K benchmark runs at
    ``results/<dataset>/<method>/results.json``).

    Each row of that file already contains ``prompt_id`` + ``prompt_text``,
    so we can extract the prompt set without going back to the original
    benchmark JSON.
    """
    with open(results_json) as f:
        data = json.load(f)
    rows = data.get("results", []) if isinstance(data, dict) else data
    prompts = []
    for r in rows:
        pid = r.get("prompt_id")
        text = r.get("prompt_text") or r.get("text")
        if not (pid and text):
            continue
        prompts.append({"id": pid, "text": text, "family": "ext"})

    if ids:
        wanted = set(ids)
        prompts = [p for p in prompts if p["id"] in wanted]
    elif n_prompts is not None and n_prompts < len(prompts):
        import random
        rng = random.Random(seed)
        prompts = rng.sample(prompts, n_prompts)
        prompts.sort(key=lambda p: p["id"])
    return prompts


def load_external_prompts(
    benchmark_json: str,
    prompt_type: str = "descriptive",
    ids: Optional[List[str]] = None,
) -> List[dict]:
    """Load prompts from an ext_step2-generated ground-truth JSON."""
    with open(benchmark_json) as f:
        data = json.load(f)

    out = []
    for comp in data.get("components", []):
        variants = comp.get("prompt_variants", {})
        text = variants.get(prompt_type) or comp.get("prompt") or ""
        if not text:
            continue
        out.append({
            "id": comp["id"],
            "text": text,
            "family": comp.get("component_family", "external"),
        })

    if ids:
        out = [p for p in out if p["id"] in ids]
    return out


# Default canonical subset: the 30 IDs that produced the existing
# Experimentation/Chamfer_distance/results/cd_summary.md. v4 numbers
# computed on this subset slot directly into that comparison table.
_DEFAULT_V2_GT_DIR = (
    Path(__file__).resolve().parent.parent.parent
    / "Experimentation" / "Chamfer_distance" / "stls" / "ground_truth"
)
_DEFAULT_V2_JSON = (
    Path(__file__).resolve().parent.parent.parent
    / "Experimentation" / "GroundTruth" / "benchmark_ground_truth_v2.json"
)


def _discover_canonical_ids(gt_dir: Path) -> List[str]:
    """Read the canonical 30-prompt subset from the existing CD eval directory."""
    if not gt_dir.is_dir():
        return []
    return sorted(p.stem for p in gt_dir.glob("*.stl"))


def load_v2_prompts(
    benchmark_json: Optional[str] = None,
    ids: Optional[List[str]] = None,
    use_canonical_30: bool = True,
    tier: Optional[str] = None,
    n_prompts: Optional[int] = None,
    seed: int = 42,
) -> List[dict]:
    """Load prompts from ``benchmark_ground_truth_v2.json``.

    Selection precedence:
        1. Explicit ``ids``         → exact set, in v2 JSON order.
        2. ``use_canonical_30``     → the 30 IDs already present in
           ``Experimentation/Chamfer_distance/stls/ground_truth/`` (so v4
           numbers compare apples-to-apples with the existing
           cd_summary.md).
        3. ``tier`` + ``n_prompts`` → stratified random sample from the
           given tier(s); ``tier=None`` means all tiers.

    Each returned dict has ``id``, ``text``, ``tier``, ``family``, and
    ``stl_path`` fields. ``stl_path`` points at the v2 ground-truth STL
    on disk so downstream eval scripts can use it directly.
    """
    json_path = Path(benchmark_json) if benchmark_json else _DEFAULT_V2_JSON
    with open(json_path) as f:
        data = json.load(f)

    json_dir = Path(json_path).parent
    pool: List[dict] = []
    for comp in data.get("components", []):
        text = comp.get("prompt") or ""
        if not text:
            continue
        stl_rel = comp.get("stl_file", f"stl/{comp['id']}.stl")
        pool.append({
            "id": comp["id"],
            "text": text,
            "tier": comp.get("tier", "Unknown"),
            "family": comp.get("component_family", "v2"),
            "stl_path": str((json_dir / stl_rel).resolve()),
        })

    if ids:
        wanted = set(ids)
        return [p for p in pool if p["id"] in wanted]

    if use_canonical_30:
        canon = _discover_canonical_ids(_DEFAULT_V2_GT_DIR)
        if canon:
            canon_set = set(canon)
            picked = [p for p in pool if p["id"] in canon_set]
            if picked:
                return picked
            print(
                f"[v2] canonical-30 IDs not present in v2 JSON; falling back to "
                f"tier={tier} n={n_prompts} sampling"
            )

    # Tier filter.
    filtered = pool
    if tier:
        wanted_tiers = {t.strip().lower() for t in tier.split(",")}
        filtered = [p for p in filtered if p["tier"].lower() in wanted_tiers]

    if n_prompts is not None and n_prompts < len(filtered):
        import random
        rng = random.Random(seed)
        filtered = rng.sample(filtered, n_prompts)
        filtered.sort(key=lambda p: p["id"])

    return filtered


# =============================================================================
# Output layout helpers
# =============================================================================

def materialise_dataset_outputs(out_dataset_dir: Path, prompt_id: str, run_dir: Path) -> Dict[str, str]:
    """Copy the chosen final.scad/final.stl/final_views into the standard
    benchmark directory layout (scad/, stl/, png/).

    Returns a dict of paths actually emitted.
    """
    paths: Dict[str, str] = {}

    # SCAD
    final_scad = run_dir / "final.scad"
    if final_scad.exists():
        dst = out_dataset_dir / "scad" / f"{prompt_id}.scad"
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(final_scad, dst)
        paths["scad"] = str(dst)

    # STL
    final_stl = run_dir / "final.stl"
    if final_stl.exists() and final_stl.stat().st_size > 0:
        dst = out_dataset_dir / "stl" / f"{prompt_id}.stl"
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(final_stl, dst)
        paths["stl"] = str(dst)

    # PNG (use iso1 if present, else front)
    final_views = run_dir / "final_views"
    candidate_png = None
    if final_views.is_dir():
        for name in ("iso1", "front", "iso3", "right"):
            for f in final_views.glob(f"*_{name}.png"):
                candidate_png = f
                break
            if candidate_png:
                break
    if candidate_png and candidate_png.exists():
        dst = out_dataset_dir / "png" / f"{prompt_id}.png"
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(candidate_png, dst)
        paths["png"] = str(dst)

    return paths


# =============================================================================
# Main runner
# =============================================================================

def run_dataset(
    prompts: Iterable[dict],
    out_dataset_dir: Path,
    config: V4Config,
    force: bool,
) -> List[dict]:
    """Run v4 over a prompt set; write per-prompt artifacts + summary."""
    out_dataset_dir.mkdir(parents=True, exist_ok=True)
    runs_dir = out_dataset_dir / "runs"
    runs_dir.mkdir(exist_ok=True)
    summary: List[dict] = []

    runner = V4Runner(config=config)

    prompts = list(prompts)
    n_total = len(prompts)
    print(f"[v4-bench] {n_total} prompts → {out_dataset_dir}")

    for idx, p in enumerate(prompts, 1):
        prompt_id = p["id"]
        prompt_text = p["text"]
        run_dir = runs_dir / prompt_id
        audit_path = run_dir / "audit.json"

        if audit_path.exists() and not force:
            try:
                summary.append(json.loads(audit_path.read_text()))
            except Exception:
                pass
            print(f"[{idx}/{n_total}] {prompt_id}: skip (audit exists)")
            continue

        print(f"[{idx}/{n_total}] {prompt_id}: {prompt_text[:60]}...")
        t0 = time.time()
        try:
            result: V4Result = runner.run(
                prompt_id=prompt_id,
                prompt_text=prompt_text,
                out_dir=str(run_dir),
            )
        except Exception as e:
            print(f"  ERROR: {e}")
            continue

        materialise_dataset_outputs(out_dataset_dir, prompt_id, run_dir)
        elapsed = time.time() - t0

        summary.append({
            "prompt_id": prompt_id,
            "chosen": result.chosen,
            "chosen_baseline_model": result.chosen_baseline_model,
            "chosen_baseline_reason": result.chosen_baseline_reason,
            "baselines": result.baselines,
            "baseline_pass": result.baseline_criteria_pass,
            "baseline_total": result.baseline_criteria_total,
            "patched_pass": result.patched_criteria_pass,
            "patched_total": result.patched_criteria_total,
            "patch_attempted": result.patch_attempted,
            "patch_is_noop": result.patch_is_noop,
            "kb_fired": result.kb_fired,
            "gate_reason": result.gate_reason,
            "errors": result.errors,
            "elapsed_s": elapsed,
        })
        print(
            f"  → chose {result.chosen} | "
            f"baseline {result.baseline_criteria_pass}/{result.baseline_criteria_total} | "
            f"patched {result.patched_criteria_pass}/{result.patched_criteria_total} | "
            f"{elapsed:.1f}s"
        )

    summary_path = out_dataset_dir / "results.json"
    with open(summary_path, "w") as f:
        json.dump(summary, f, indent=2, default=str)
    print(f"[v4-bench] wrote summary → {summary_path}")

    # Per-baseline-model win tally (which baseline got picked at the
    # multi-baseline selection step, before any patch).
    win_counts: Dict[str, int] = {}
    final_counts = {"baseline": 0, "patched": 0}
    for row in summary:
        m = row.get("chosen_baseline_model") or "unknown"
        win_counts[m] = win_counts.get(m, 0) + 1
        final_counts[row.get("chosen", "baseline")] = (
            final_counts.get(row.get("chosen", "baseline"), 0) + 1
        )

    print("\n[v4-bench] baseline-model win tally (pre-patch):")
    for model, count in sorted(win_counts.items(), key=lambda kv: -kv[1]):
        print(f"  {model:<14} {count}")
    print(f"\n[v4-bench] final selection: {final_counts}")
    return summary


# =============================================================================
# CLI
# =============================================================================

def main() -> int:
    ap = argparse.ArgumentParser(description="Run CRAFT v4 over a benchmark.")
    ap.add_argument(
        "--source",
        choices=["v2", "nopscadlib", "ext", "ext-results"],
        default="v2",
        help=(
            "Prompt source. 'v2' = canonical 30 from the v2 benchmark; "
            "'ext-results' = read prompts from an existing CRAFT results.json "
            "(use for ABC / Slice-100K, which already have benchmark runs "
            "saved as results/<dataset>/<method>/results.json)."
        ),
    )
    ap.add_argument("--benchmark-json",
                    help="(v2 / ext) ground-truth JSON path. v2 default: "
                         "Experimentation/GroundTruth/benchmark_ground_truth_v2.json")
    ap.add_argument("--results-json",
                    help="(ext-results) Path to an existing CRAFT results.json "
                         "with prompt_id + prompt_text rows.")
    ap.add_argument("--dataset-name", default="v2",
                    help="Subdirectory name under --out-dir.")
    ap.add_argument("--prompt-type", default="descriptive",
                    help="(ext) prompt variant key.")
    ap.add_argument("--ids", nargs="*", default=None, help="Restrict to these prompt IDs.")
    ap.add_argument("--all", action="store_true",
                    help="(v2) skip the canonical-30 default and use every component.")
    ap.add_argument("--tier", default=None,
                    help="(v2) restrict to one or more tiers (e.g. 'Simple,Medium').")
    ap.add_argument("--n-prompts", type=int, default=None,
                    help="(v2) random-sample N prompts after tier filter "
                         "(only used when --all is set or no canonical IDs match).")
    ap.add_argument("--seed", type=int, default=42,
                    help="(v2) sampling seed.")
    ap.add_argument("--out-dir", default="./results/v4",
                    help="Top-level output directory.")
    ap.add_argument(
        "--baseline-models", nargs="+", default=["gpt-5.2", "gpt-4o"],
        help="Stage-0 generators raced in parallel; first is tie-break preference.",
    )
    ap.add_argument("--baseline-model", default=None,
                    help="(legacy) single baseline model; overrides --baseline-models.")
    ap.add_argument("--assessor-model", default="gpt-5.2")
    ap.add_argument("--patcher-model", default="gpt-5.2")
    ap.add_argument("--no-kb", action="store_true")
    ap.add_argument("--no-patch", action="store_true",
                    help="Run baseline + assess only (skip patch + gate).")
    ap.add_argument("--min-patch-gain", type=int, default=2,
                    help="Patch must add this many criteria to be kept (default 2).")
    ap.add_argument("--external-baseline", action="append", default=[],
                    metavar="NAME=DIR",
                    help="Add a pre-generated SCAD baseline as a candidate "
                         "(e.g. craft-v1=../results/v4/v2/craft_v1). Repeatable.")
    ap.add_argument("--quick", action="store_true",
                    help="(nopscadlib) only first 3 prompts.")
    ap.add_argument("--force", action="store_true",
                    help="Re-run prompts even if audit.json exists.")
    args = ap.parse_args()

    if args.source == "v2":
        prompts = load_v2_prompts(
            benchmark_json=args.benchmark_json,
            ids=args.ids,
            use_canonical_30=not args.all,
            tier=args.tier,
            n_prompts=args.n_prompts,
            seed=args.seed,
        )
    elif args.source == "ext-results":
        if not args.results_json:
            ap.error("--results-json is required for --source ext-results")
        prompts = load_ext_results_prompts(
            results_json=args.results_json,
            ids=args.ids,
            n_prompts=args.n_prompts,
            seed=args.seed,
        )
    elif args.source == "nopscadlib":
        prompts = load_nopscadlib_prompts(quick=args.quick)
    else:
        if not args.benchmark_json:
            ap.error("--benchmark-json is required for --source ext")
        prompts = load_external_prompts(
            benchmark_json=args.benchmark_json,
            prompt_type=args.prompt_type,
            ids=args.ids,
        )

    if args.ids and args.source != "v2":
        # v2 already filtered above; this only applies to other sources.
        prompts = [p for p in prompts if p["id"] in args.ids]

    if not prompts:
        print("No prompts loaded. Check --source / --benchmark-json / --ids.")
        return 2

    print(f"[v4-bench] {len(prompts)} prompt(s) selected from --source {args.source}")
    if args.source == "v2":
        from collections import Counter
        tiers = Counter(p.get("tier", "?") for p in prompts)
        print(f"[v4-bench] tier mix: {dict(tiers)}")

    external_baselines = {}
    for spec in args.external_baseline:
        if "=" not in spec:
            ap.error(f"--external-baseline expects NAME=DIR (got {spec!r})")
        name, path = spec.split("=", 1)
        external_baselines[name.strip()] = path.strip()

    cfg = V4Config(
        baseline_models=list(args.baseline_models),
        baseline_model=args.baseline_model,
        external_baselines=external_baselines,
        assessor_model=args.assessor_model,
        patcher_model=args.patcher_model,
        use_kb=not args.no_kb,
        enable_patch=not args.no_patch,
        min_patch_gain=args.min_patch_gain,
    )

    out_dataset_dir = Path(args.out_dir) / args.dataset_name / "v4"
    run_dataset(prompts, out_dataset_dir, cfg, args.force)
    return 0


if __name__ == "__main__":
    sys.exit(main())
