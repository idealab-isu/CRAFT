#!/usr/bin/env python3
"""
Prepare an external dataset (ABC or Slice-100K) for v4 benchmarking +
aligned-CD scoring.

Steps performed:

  1. Pick N prompt IDs (default 30) from the dataset's existing
     ``results/<dataset>/<method>/results.json``. Sampled deterministically
     by seed; intersection of (a) IDs present in all selected method
     results and (b) IDs that have a ground-truth STL on disk.

  2. Re-export STL files for each of the existing methods (craft / gpt52
     / gpt4o) from their saved SCAD files. The previously published
     numbers were rendered on a different machine; their stl_path
     entries point at non-existent paths. Re-rendering locally fixes
     that and uses the same SCAD code, so the comparison is honest.

  3. Stage everything into a compute_chamfer_v4-compatible layout:

         <stage_dir>/<dataset>/
             ground_truth/<id>.stl
             craft/stl/<id>.stl
             gpt52/stl/<id>.stl
             gpt4o/stl/<id>.stl
             prompts.json     ← list of {id, text} chosen here
             ids.txt           ← bare ID list (one per line)

After this finishes you can:

  a. Run v4 on the same prompts:

         python -m evaluation.run_v4_benchmark --source ext-results \\
             --results-json ../results/<dataset>/craft/results.json \\
             --ids $(cat ../results/<dataset>/eval/ids.txt) \\
             --out-dir ../results/v4 --dataset-name <dataset>

  b. Symlink v4 STLs into the stage dir + run scoring:

         ln -sf $(pwd)/../results/v4/<dataset>/v4/stl ../results/<dataset>/eval/v4/stl

         python -m evaluation.compute_chamfer_v4 \\
             --gt-dir ../results/<dataset>/eval/ground_truth \\
             --results-root ../results/<dataset>/eval \\
             --methods craft gpt52 gpt4o v4 \\
             --dataset <dataset>

Usage examples:

    # ABC, 30 prompts:
    python -m evaluation.prepare_ext_dataset --dataset abc --n-prompts 30

    # Slice-100K:
    python -m evaluation.prepare_ext_dataset --dataset slice100k --n-prompts 30

    # Specific IDs:
    python -m evaluation.prepare_ext_dataset --dataset abc \\
        --ids 0011527_partstudio_181_model_ste_00_512 0011597_partstudio_00_model_ste_00_512
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import shutil
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Dict, List, Optional, Tuple

_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
_REPO_ROOT = _PIPELINE_ROOT.parent
for p in (_REPO_ROOT, _PIPELINE_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))


DATASETS: Dict[str, dict] = {
    "abc": {
        "results_root": _REPO_ROOT / "results" / "abc",
        "gt_dir": _REPO_ROOT / "datasets" / "abc",
    },
    "slice100k": {
        "results_root": _REPO_ROOT / "results" / "slice100k",
        "gt_dir": _REPO_ROOT / "datasets" / "slice100k",
    },
}


def _read_results_json(path: Path) -> List[dict]:
    if not path.exists():
        return []
    data = json.load(open(path))
    return data.get("results", []) if isinstance(data, dict) else data


def _common_ids(method_results: Dict[str, List[dict]]) -> List[str]:
    """Return IDs present in every method's results.json."""
    sets = []
    for method, rows in method_results.items():
        sets.append({r["prompt_id"] for r in rows if "prompt_id" in r})
    if not sets:
        return []
    common = sets[0].intersection(*sets[1:])
    return sorted(common)


def _intersect_with_gt(ids: List[str], gt_dir: Path) -> List[str]:
    gt_ids = {p.stem for p in gt_dir.glob("*.stl")}
    return [i for i in ids if i in gt_ids]


# Pattern for the CRAFT v1 calibration wrapper:
#   scale([x, y, z])
#   {
#       ...code...
#   }
# OpenSCAD rejects this when ...code... contains module definitions
# (modules must be at top level, not inside a transform's child block).
# The CD scorer normalises to unit bounding sphere, so removing this
# wrapper has no effect on the final Chamfer score.
_CRAFT_SCALE_WRAPPER_RE = re.compile(
    r"^(\s*//[^\n]*\n)*"            # optional leading comments
    r"\s*scale\s*\([^)]*\)\s*\n"    # scale([...])
    r"\s*\{\s*\n",                   # opening brace on its own line
    re.MULTILINE,
)


def _strip_scale_wrapper(scad_text: str) -> Optional[str]:
    """If ``scad_text`` opens with the CRAFT v1 ``scale(...) { ... }``
    calibration wrapper, return the text with that wrapper removed.

    Returns None when no such wrapper is detected (caller should leave
    the file alone).
    """
    m = _CRAFT_SCALE_WRAPPER_RE.match(scad_text)
    if not m:
        return None

    # Walk forward from the opening brace, finding its matching close.
    open_brace_idx = scad_text.find("{", m.end() - 1)  # safety
    # m.end() points right after the matching `\n` after `{`. Find the
    # exact `{` itself for depth tracking.
    open_brace_idx = scad_text.find("{", m.start())
    if open_brace_idx < 0:
        return None

    depth = 0
    close_idx = -1
    in_line_comment = False
    in_block_comment = False
    in_string = False
    i = open_brace_idx
    while i < len(scad_text):
        c = scad_text[i]
        nxt = scad_text[i + 1] if i + 1 < len(scad_text) else ""
        if in_line_comment:
            if c == "\n":
                in_line_comment = False
        elif in_block_comment:
            if c == "*" and nxt == "/":
                in_block_comment = False
                i += 1
        elif in_string:
            if c == "\\":
                i += 1
            elif c == '"':
                in_string = False
        else:
            if c == "/" and nxt == "/":
                in_line_comment = True
                i += 1
            elif c == "/" and nxt == "*":
                in_block_comment = True
                i += 1
            elif c == '"':
                in_string = True
            elif c == "{":
                depth += 1
            elif c == "}":
                depth -= 1
                if depth == 0:
                    close_idx = i
                    break
        i += 1

    if close_idx < 0:
        return None

    inner = scad_text[open_brace_idx + 1:close_idx]
    suffix = scad_text[close_idx + 1:]
    # Re-emit: leading comments (preserved by m.group()'s comment block)
    # + inner contents + anything after the close brace.
    leading_comments = ""
    cm = re.match(r"^((?:\s*//[^\n]*\n)+)", scad_text)
    if cm:
        leading_comments = cm.group(1)
    return leading_comments + inner.strip() + "\n" + suffix.strip() + "\n"


def _export_stl(scad_path: Path, stl_path: Path, timeout: int = 300,
                allow_repair: bool = True) -> bool:
    """OpenSCAD CLI export. Returns True iff a non-empty STL was produced.

    On parser-error failure, optionally attempts a single repair:
        - strip the CRAFT v1 ``scale([...]) { ... }`` calibration wrapper
        - re-render from a temp file
    The repaired SCAD is also written back to ``scad_path`` so subsequent
    runs (and v4's external-baseline reader) see the fixed version.
    """
    stl_path.parent.mkdir(parents=True, exist_ok=True)

    def _run_openscad(target_scad: Path) -> Tuple[bool, str]:
        try:
            result = subprocess.run(
                ["openscad", "-o", str(stl_path), str(target_scad)],
                capture_output=True, text=True, timeout=timeout,
            )
            ok = (
                result.returncode == 0
                and stl_path.exists()
                and stl_path.stat().st_size > 0
            )
            tail = ""
            if not ok and result.stderr:
                tail = result.stderr.strip().splitlines()[-1] if result.stderr.strip() else ""
            return ok, tail
        except subprocess.TimeoutExpired:
            return False, f"timeout after {timeout}s"
        except Exception as e:
            return False, str(e)

    # First try as-is.
    ok, tail = _run_openscad(scad_path)
    if ok:
        return True

    parser_error = "parse" in tail.lower() or "syntax" in tail.lower() or "can't parse" in tail.lower()
    if not allow_repair or not parser_error:
        if tail:
            print(f"    [stl-fail] {scad_path.name}: {tail[:160]}")
        return False

    # Try the CRAFT-v1 calibration-wrapper strip.
    try:
        scad_text = scad_path.read_text()
    except Exception:
        print(f"    [stl-fail] {scad_path.name}: {tail[:160]}")
        return False

    repaired = _strip_scale_wrapper(scad_text)
    if repaired is None or repaired == scad_text:
        print(f"    [stl-fail] {scad_path.name}: {tail[:160]}")
        return False

    # Write repaired file alongside the original. We persist it so v4's
    # external-baseline reader picks up the fixed version too.
    backup_path = scad_path.with_suffix(scad_path.suffix + ".orig")
    try:
        if not backup_path.exists():
            shutil.copyfile(scad_path, backup_path)
        scad_path.write_text(repaired)
    except Exception as e:
        print(f"    [stl-fail] {scad_path.name}: repair-write failed: {e}")
        return False

    ok2, tail2 = _run_openscad(scad_path)
    if ok2:
        print(f"    [repaired+stl-ok] {scad_path.name} (stripped scale-wrapper)")
        return True
    print(f"    [stl-fail] {scad_path.name}: still broken after repair: {tail2[:120]}")
    return False


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dataset", required=True, choices=list(DATASETS.keys()))
    ap.add_argument("--methods", nargs="+", default=["craft", "gpt52", "gpt4o"],
                    help="Methods whose existing scad/ files to re-render.")
    ap.add_argument("--n-prompts", type=int, default=30)
    ap.add_argument("--ids", nargs="*", default=None,
                    help="Specific IDs to use (overrides --n-prompts).")
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--results-root", default=None,
                    help="Override the dataset's results root.")
    ap.add_argument("--gt-dir", default=None,
                    help="Override the dataset's ground-truth STL directory.")
    ap.add_argument("--out-root", default=None,
                    help="Where to stage the prepared layout. "
                         "Defaults to <results-root>/eval.")
    ap.add_argument("--force", action="store_true",
                    help="Re-render STLs even if they already exist.")
    args = ap.parse_args()

    cfg = DATASETS[args.dataset]
    results_root = Path(args.results_root) if args.results_root else cfg["results_root"]
    gt_dir = Path(args.gt_dir) if args.gt_dir else cfg["gt_dir"]
    out_root = Path(args.out_root) if args.out_root else results_root / "eval"

    if not results_root.is_dir():
        print(f"ERROR: results root not found: {results_root}")
        return 2
    if not gt_dir.is_dir():
        print(f"ERROR: ground-truth dir not found: {gt_dir}")
        return 2

    # Read all method results.
    method_results: Dict[str, List[dict]] = {}
    for m in args.methods:
        rj = results_root / m / "results.json"
        rows = _read_results_json(rj)
        if not rows:
            print(f"WARN: no rows for {m} ({rj}) — skipping in intersection")
            continue
        method_results[m] = rows

    # ID selection.
    if args.ids:
        chosen_ids = list(args.ids)
    else:
        common = _common_ids(method_results)
        with_gt = _intersect_with_gt(common, gt_dir)
        if len(with_gt) < args.n_prompts:
            print(f"WARN: only {len(with_gt)} IDs satisfy intersect-with-GT "
                  f"(asked {args.n_prompts})")
        rng = random.Random(args.seed)
        chosen_ids = sorted(
            rng.sample(with_gt, k=min(args.n_prompts, len(with_gt)))
        )

    print(f"[prep] dataset={args.dataset}  methods={args.methods}  "
          f"chosen={len(chosen_ids)} ids  out={out_root}")

    # Out layout.
    out_root.mkdir(parents=True, exist_ok=True)
    (out_root / "ground_truth").mkdir(parents=True, exist_ok=True)
    for m in args.methods:
        (out_root / m / "stl").mkdir(parents=True, exist_ok=True)

    # Stage GT STLs.
    for pid in chosen_ids:
        src = gt_dir / f"{pid}.stl"
        if not src.exists():
            print(f"  [gt-miss] {pid}")
            continue
        shutil.copyfile(src, out_root / "ground_truth" / f"{pid}.stl")

    # Re-export method STLs from existing scad files.
    rerender_summary: Dict[str, Dict[str, int]] = {}
    for m in args.methods:
        scad_dir = results_root / m / "scad"
        if not scad_dir.is_dir():
            print(f"  [{m}] no scad dir at {scad_dir}; skipping")
            rerender_summary[m] = {"ok": 0, "missing_scad": len(chosen_ids), "fail": 0}
            continue
        ok = miss = fail = 0
        t0 = time.time()
        print(f"\n[{m}] re-rendering STLs...")
        for i, pid in enumerate(chosen_ids, 1):
            scad = scad_dir / f"{pid}.scad"
            stl = out_root / m / "stl" / f"{pid}.stl"
            if stl.exists() and stl.stat().st_size > 0 and not args.force:
                ok += 1
                continue
            if not scad.exists():
                miss += 1
                continue
            success = _export_stl(scad, stl)
            if success:
                ok += 1
            else:
                fail += 1
            if i % 5 == 0:
                print(f"  [{m}] {i}/{len(chosen_ids)} ({time.time()-t0:.1f}s)")
        rerender_summary[m] = {"ok": ok, "missing_scad": miss, "fail": fail}
        print(f"[{m}] done: ok={ok}  missing_scad={miss}  fail={fail}  "
              f"({time.time()-t0:.1f}s)")

    # Save prompt list (id + text) for v4 to consume.
    prompts: List[dict] = []
    if method_results:
        any_method = next(iter(method_results.values()))
        text_by_id = {r["prompt_id"]: r.get("prompt_text", "") for r in any_method}
        for pid in chosen_ids:
            prompts.append({"id": pid, "text": text_by_id.get(pid, "")})
    with open(out_root / "prompts.json", "w") as f:
        json.dump(prompts, f, indent=2)
    with open(out_root / "ids.txt", "w") as f:
        for pid in chosen_ids:
            f.write(pid + "\n")

    # Summary
    print(f"\n[prep] staged at {out_root}")
    print(f"  ground_truth: {sum(1 for _ in (out_root / 'ground_truth').glob('*.stl'))} STLs")
    for m in args.methods:
        cnt = sum(1 for _ in (out_root / m / 'stl').glob('*.stl'))
        print(f"  {m:<6} : {cnt} STLs")
    print(f"\n[prep] next:")
    print(f"  python -m evaluation.run_v4_benchmark --source ext-results \\")
    print(f"      --results-json {results_root}/{args.methods[0]}/results.json \\")
    print(f"      --ids $(cat {out_root}/ids.txt) \\")
    print(f"      --out-dir ../results/v4 --dataset-name {args.dataset} \\")
    print(f"      --external-baseline craft-v1={results_root}/craft \\")
    print(f"      --min-patch-gain 2")
    return 0


if __name__ == "__main__":
    sys.exit(main())
