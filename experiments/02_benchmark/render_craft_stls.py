#!/usr/bin/env python3
"""
Render existing CRAFT .scad files to .stl — no LLM, no API calls.

Use case: you have valid SCAD outputs at results/nopscadlib/craft/scad/ from a
prior `run_craft.py` run, and you just need a clean, complete set of STLs.

Defaults:
  IN  : results/nopscadlib/craft/scad/*.scad
  OUT : results/nopscadlib/craft/stl/<id>.stl

Usage:
  # Render all 468, parallel, fresh start (deletes existing STLs first)
  python experiments/02_benchmark/render_craft_stls.py --clean --workers 8

  # Render only the missing ones (incremental — skip if STL already exists)
  python experiments/02_benchmark/render_craft_stls.py --skip-existing --workers 8

  # Smoke-test on 5 files
  python experiments/02_benchmark/render_craft_stls.py --max 5
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
SCAD_DIR  = REPO_ROOT / "results" / "nopscadlib" / "craft" / "scad"
STL_DIR   = REPO_ROOT / "results" / "nopscadlib" / "craft" / "stl"
OPENSCADPATH = REPO_ROOT / "pipeline" / "kb_data"   # so `use <NopSCADlib/...>` resolves
OPENSCAD_BIN = os.environ.get("OPENSCAD_BIN", "openscad")
USE_XVFB = os.environ.get("USE_XVFB", "0") == "1"   # Linux servers without DISPLAY


def openscad_cmd(args: list) -> list:
    return (["xvfb-run", "-a"] + args) if USE_XVFB else args


def render_one(scad_path: Path, timeout_sec: int) -> dict:
    stem = scad_path.stem
    stl_path = STL_DIR / f"{stem}.stl"
    env = os.environ.copy()
    env["OPENSCADPATH"] = str(OPENSCADPATH)

    t0 = time.time()
    out = {"name": stem, "ok": False, "error": "", "size": 0, "elapsed": 0.0}
    try:
        proc = subprocess.run(
            openscad_cmd([OPENSCAD_BIN, "-o", str(stl_path), str(scad_path)]),
            capture_output=True, text=True, timeout=timeout_sec, env=env,
        )
        if stl_path.exists() and stl_path.stat().st_size > 0:
            out["ok"] = True
            out["size"] = stl_path.stat().st_size
        else:
            out["error"] = (proc.stderr[-500:] if proc.stderr else "Empty output")
    except subprocess.TimeoutExpired:
        out["error"] = f"Timeout ({timeout_sec}s)"
    except Exception as e:
        out["error"] = str(e)
    out["elapsed"] = round(time.time() - t0, 1)
    return out


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--workers", type=int, default=4, help="Parallel render workers (default 4)")
    p.add_argument("--timeout", type=int, default=120, help="Render timeout per file in sec (default 120)")
    p.add_argument("--clean", action="store_true", help="Delete existing STLs before rendering (fresh 1/468 start)")
    p.add_argument("--skip-existing", action="store_true", help="Skip files whose STL already exists")
    p.add_argument("--family", type=str, help="Only render one family (e.g. 'fan', 'ball_bearing')")
    p.add_argument("--max", type=int, help="Smoke-test on first N files")
    p.add_argument("--scad-dir", type=str, help="Override input SCAD dir (default: results/nopscadlib/craft/scad)")
    p.add_argument("--stl-dir", type=str, help="Override output STL dir (default: results/nopscadlib/craft/stl)")
    args = p.parse_args()

    global SCAD_DIR, STL_DIR
    if args.scad_dir:
        SCAD_DIR = Path(args.scad_dir)
    if args.stl_dir:
        STL_DIR = Path(args.stl_dir)

    if not SCAD_DIR.is_dir():
        print(f"ERROR: SCAD_DIR does not exist: {SCAD_DIR}", file=sys.stderr)
        return 1
    STL_DIR.mkdir(parents=True, exist_ok=True)

    if args.clean:
        existing = list(STL_DIR.glob("*.stl"))
        for f in existing:
            f.unlink()
        print(f"  --clean: removed {len(existing)} existing STL files")

    scad_files = sorted(SCAD_DIR.glob("*.scad"))
    if args.family:
        scad_files = [f for f in scad_files if f.stem.startswith(f"{args.family}__")]
    if args.skip_existing:
        existing_stems = {f.stem for f in STL_DIR.glob("*.stl") if f.stat().st_size > 0}
        before = len(scad_files)
        scad_files = [f for f in scad_files if f.stem not in existing_stems]
        print(f"  --skip-existing: {before - len(scad_files)} already done, {len(scad_files)} remaining")
    if args.max:
        scad_files = scad_files[: args.max]

    total = len(scad_files)
    if total == 0:
        print("Nothing to render.")
        return 0

    print("=" * 70)
    print(f"CRAFT STL renderer  |  files={total}  workers={args.workers}  timeout={args.timeout}s")
    print(f"  SCAD: {SCAD_DIR}")
    print(f"  STL : {STL_DIR}")
    print(f"  OPENSCADPATH: {OPENSCADPATH}")
    print("=" * 70)

    success = 0
    failed = []
    t_start = time.time()

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futures = {ex.submit(render_one, f, args.timeout): f for f in scad_files}
        for i, fut in enumerate(as_completed(futures), 1):
            r = fut.result()
            tag = "✓" if r["ok"] else "✗"
            print(f"[{i:3d}/{total}] {tag} {r['name']:35s} {r['elapsed']:5.1f}s "
                  f"{'(' + str(r['size']) + ' B)' if r['ok'] else r['error'][:60]}")
            if r["ok"]:
                success += 1
            else:
                failed.append(r["name"])

    elapsed = time.time() - t_start
    print("=" * 70)
    print(f"Done in {elapsed/60:.1f} min  |  ok={success}/{total}  failed={len(failed)}")
    if failed:
        print("\nFailed:")
        for name in failed:
            print(f"  - {name}")
    return 0 if not failed else 2


if __name__ == "__main__":
    raise SystemExit(main())
