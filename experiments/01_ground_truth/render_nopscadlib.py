#!/usr/bin/env python3
"""
Render all .scad ground truth files to .stl and .png (transparent background).

Prerequisites:
  - OpenSCAD installed:  sudo apt-get install openscad
  - xvfb installed:      sudo apt-get install xvfb   (Linux only, skip on macOS)
  - Pillow installed:    pip install Pillow           (for transparent PNGs)
  - NopSCADlib present:  llm_to_cad/craft/kb_data/nopscadlib/
  - .scad files present: llm_to_cad/Text2CAD_SPM_2026/ground_truth/scad/

Usage:
    python render_ground_truth.py                  # Render all
    python render_ground_truth.py --family fan     # Only one family
    python render_ground_truth.py --workers 8      # More parallelism
    python render_ground_truth.py --stl-only       # Skip PNG rendering
    python render_ground_truth.py --png-only       # Skip STL (re-render PNGs only)

Run order (full pipeline):
    1. python render_ground_truth.py       # This script — produces STL + transparent PNG
    2. python compute_complexity.py        # Scores components → benchmark_ground_truth.json
    3. python generate_prompts.py          # Adds anonymized prompts → updates benchmark_ground_truth.json
                                           #                         → writes benchmark_prompts.txt
"""

import os
import sys
import json
import shutil
import subprocess
import argparse
import time
import platform
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# ── paths ──────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).parent
REPO_ROOT = SCRIPT_DIR.parent.parent
GROUND_TRUTH_DIR = REPO_ROOT / "ground_truth" / "nopscadlib"
SCAD_DIR = GROUND_TRUTH_DIR / "scad"
STL_DIR = GROUND_TRUTH_DIR / "stl"
PNG_DIR = GROUND_TRUTH_DIR / "png"

CRAFT_DIR = REPO_ROOT / "pipeline"
NOPSCADLIB_PARENT = CRAFT_DIR / "kb_data"

# OpenSCAD settings
OPENSCAD_BIN = "openscad"
PNG_SIZE = "512,512"
# Isometric camera: translateX,Y,Z, rotX,rotY,rotZ, distance (0 = autofit)
CAMERA_ISO = "0,0,0,55,0,25,0"

# Background removal tolerance (0-255).
# Pixels within this distance of the background color become transparent.
BG_TOLERANCE = 30

# Try to import Pillow for transparent PNG post-processing
try:
    from PIL import Image
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False


def needs_xvfb() -> bool:
    """Check if xvfb-run is needed (Linux without display) and available."""
    if platform.system() != "Linux":
        return False
    if os.environ.get("DISPLAY"):
        return False
    return shutil.which("xvfb-run") is not None


USE_XVFB = needs_xvfb()


def openscad_cmd(args: list) -> list:
    """Wrap an OpenSCAD command with xvfb-run if needed."""
    if USE_XVFB:
        return ["xvfb-run", "-a"] + args
    return args


def check_prerequisites():
    """Verify OpenSCAD, NopSCADlib, .scad files are available."""
    errors = []

    # Check OpenSCAD
    try:
        proc = subprocess.run(
            openscad_cmd([OPENSCAD_BIN, "--version"]),
            capture_output=True, text=True, timeout=10,
        )
        version = (proc.stdout + proc.stderr).strip()
        print(f"  OpenSCAD: {version}")
    except FileNotFoundError:
        errors.append("OpenSCAD not found. Install with: sudo apt-get install openscad")

    # Check xvfb on Linux
    if platform.system() == "Linux" and not os.environ.get("DISPLAY"):
        if shutil.which("xvfb-run"):
            print("  xvfb-run: OK (headless mode)")
        else:
            errors.append("No DISPLAY and xvfb-run not found. Install: sudo apt-get install xvfb")

    # Check Pillow
    if HAS_PILLOW:
        print("  Pillow: OK (transparent PNG post-processing enabled)")
    else:
        print("  Pillow: NOT FOUND — PNGs will have opaque background")
        print("          Install with: pip install Pillow")

    # Check NopSCADlib
    nopscadlib_dir = NOPSCADLIB_PARENT / "nopscadlib"
    if nopscadlib_dir.exists():
        print(f"  NopSCADlib: {nopscadlib_dir}")
    else:
        errors.append(f"NopSCADlib not found at {nopscadlib_dir}")

    # Check .scad files
    scad_files = sorted(SCAD_DIR.glob("*.scad"))
    if scad_files:
        print(f"  .scad files: {len(scad_files)} found in {SCAD_DIR}")
    else:
        errors.append(f"No .scad files found in {SCAD_DIR}")

    if errors:
        print("\nERRORS:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)

    return scad_files


def make_transparent(png_path: Path, tolerance: int = BG_TOLERANCE):
    """Post-process a PNG to make the background transparent.

    Samples the corner pixels to determine the background color,
    then converts all pixels within `tolerance` of that color to
    fully transparent. Applies a smooth alpha gradient at edges
    for anti-aliasing.
    """
    if not HAS_PILLOW:
        return

    try:
        img = Image.open(png_path).convert("RGBA")
    except Exception:
        return

    pixels = img.load()
    w, h = img.size

    # Sample background color from corners (average of 4 corners, 3x3 patch each)
    corner_samples = []
    for cx, cy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                x = max(0, min(w - 1, cx + dx))
                y = max(0, min(h - 1, cy + dy))
                r, g, b, a = pixels[x, y]
                corner_samples.append((r, g, b))

    # Median background color
    bg_r = sorted(s[0] for s in corner_samples)[len(corner_samples) // 2]
    bg_g = sorted(s[1] for s in corner_samples)[len(corner_samples) // 2]
    bg_b = sorted(s[2] for s in corner_samples)[len(corner_samples) // 2]

    # Make matching pixels transparent
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            dist = abs(r - bg_r) + abs(g - bg_g) + abs(b - bg_b)
            if dist < tolerance:
                # Fully transparent
                pixels[x, y] = (r, g, b, 0)
            elif dist < tolerance * 2:
                # Semi-transparent (anti-aliasing edge)
                alpha = int(255 * (dist - tolerance) / tolerance)
                pixels[x, y] = (r, g, b, min(255, alpha))
            # else: keep fully opaque

    img.save(png_path, "PNG")


def render_one(scad_path: Path, do_stl: bool = True, do_png: bool = True,
               timeout_sec: int = 120) -> dict:
    """Render a single .scad file to .stl and/or .png (transparent bg)."""
    stem = scad_path.stem
    stl_path = STL_DIR / f"{stem}.stl"
    png_path = PNG_DIR / f"{stem}.png"

    env = os.environ.copy()
    env["OPENSCADPATH"] = str(NOPSCADLIB_PARENT)

    result = {
        "name": stem,
        "scad": str(scad_path),
        "stl": None,
        "png": None,
        "stl_ok": False,
        "png_ok": False,
        "stl_error": "",
        "png_error": "",
        "stl_size": 0,
        "render_time": 0,
    }

    t0 = time.time()

    # ── Render STL ──
    if do_stl:
        try:
            proc = subprocess.run(
                openscad_cmd([
                    OPENSCAD_BIN,
                    "-o", str(stl_path),
                    str(scad_path),
                ]),
                capture_output=True, text=True, timeout=timeout_sec, env=env,
            )
            if stl_path.exists() and stl_path.stat().st_size > 0:
                result["stl_ok"] = True
                result["stl"] = str(stl_path)
                result["stl_size"] = stl_path.stat().st_size
            else:
                result["stl_error"] = proc.stderr[-500:] if proc.stderr else "Empty output"
        except subprocess.TimeoutExpired:
            result["stl_error"] = f"Timeout ({timeout_sec}s)"
        except Exception as e:
            result["stl_error"] = str(e)

    # ── Render PNG ──
    # Render if: do_png AND (STL succeeded OR we're in png-only mode)
    can_png = do_png and (result["stl_ok"] or not do_stl)
    if can_png:
        try:
            proc = subprocess.run(
                openscad_cmd([
                    OPENSCAD_BIN,
                    "-o", str(png_path),
                    "--imgsize", PNG_SIZE,
                    "--camera", CAMERA_ISO,
                    "--autocenter", "--viewall",
                    "--render", "",
                    str(scad_path),
                ]),
                capture_output=True, text=True, timeout=timeout_sec, env=env,
            )
            if png_path.exists() and png_path.stat().st_size > 0:
                result["png_ok"] = True
                result["png"] = str(png_path)
                # Post-process for transparent background
                make_transparent(png_path)
            else:
                result["png_error"] = proc.stderr[-500:] if proc.stderr else "Empty output"
        except subprocess.TimeoutExpired:
            result["png_error"] = f"Timeout ({timeout_sec}s)"
        except Exception as e:
            result["png_error"] = str(e)

    result["render_time"] = round(time.time() - t0, 1)
    return result


def main():
    parser = argparse.ArgumentParser(
        description="Render NopSCADlib .scad files to .stl + .png (transparent bg)",
        epilog="After rendering, run: python compute_complexity.py && python generate_prompts.py",
    )
    parser.add_argument("--family", type=str, default=None,
                        help="Only render one component family (e.g. 'fan', 'ball_bearing')")
    parser.add_argument("--workers", type=int, default=4,
                        help="Parallel render workers (default: 4)")
    parser.add_argument("--timeout", type=int, default=120,
                        help="Render timeout per component in seconds (default: 120)")
    parser.add_argument("--stl-only", action="store_true",
                        help="Only render STL files, skip PNG")
    parser.add_argument("--png-only", action="store_true",
                        help="Only render PNG files, skip STL (useful for re-rendering PNGs)")
    args = parser.parse_args()

    do_stl = not args.png_only
    do_png = not args.stl_only

    print("=" * 70)
    print("NopSCADlib Ground Truth Renderer")
    print("=" * 70)
    mode = "STL + PNG (transparent)" if (do_stl and do_png) else ("STL only" if do_stl else "PNG only (transparent)")
    print(f"  Mode: {mode}")
    print()

    # Check prerequisites
    print("Checking prerequisites...")
    scad_files = check_prerequisites()

    # Filter by family
    if args.family:
        scad_files = [f for f in scad_files if f.stem.startswith(f"{args.family}__")]
        print(f"\nFiltered to family '{args.family}': {len(scad_files)} files")

    if not scad_files:
        print("No .scad files to render!")
        sys.exit(1)

    # For png-only mode, only process files that have an existing STL
    if args.png_only:
        existing_stls = {f.stem for f in STL_DIR.glob("*.stl")}
        scad_files = [f for f in scad_files if f.stem in existing_stls]
        print(f"  PNG-only mode: {len(scad_files)} files with existing STLs")

    # Create output dirs
    for d in [STL_DIR, PNG_DIR]:
        d.mkdir(parents=True, exist_ok=True)

    # Render
    total = len(scad_files)
    print(f"\nRendering {total} components (workers={args.workers}, timeout={args.timeout}s)...")
    print("=" * 70)

    results = []
    success_stl = 0
    success_png = 0
    failed = []

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        future_to_scad = {
            executor.submit(render_one, f, do_stl, do_png, args.timeout): f
            for f in scad_files
        }

        for i, future in enumerate(as_completed(future_to_scad), 1):
            scad_path = future_to_scad[future]
            try:
                result = future.result()
            except Exception as e:
                result = {
                    "name": scad_path.stem,
                    "stl_ok": False, "png_ok": False,
                    "stl_error": str(e), "png_error": "",
                    "stl_size": 0, "render_time": 0,
                }

            results.append(result)

            if result.get("stl_ok"):
                success_stl += 1
            if result.get("png_ok"):
                success_png += 1
            if do_stl and not result.get("stl_ok"):
                failed.append(result)

            # Progress
            size_kb = result.get("stl_size", 0) / 1024
            time_s = result.get("render_time", 0)
            stl_s = "STL:OK" if result.get("stl_ok") else ("STL:--" if not do_stl else "STL:FAIL")
            png_s = "PNG:OK" if result.get("png_ok") else ("PNG:--" if not do_png else "PNG:FAIL")
            print(f"  [{i:3d}/{total}] {stl_s} {png_s} "
                  f"{result['name'][:45]:45s} "
                  f"{size_kb:7.0f}KB  {time_s:5.1f}s")

    # Summary
    print(f"\n{'=' * 70}")
    print("RESULTS:")
    if do_stl:
        print(f"  STL: {success_stl}/{total} rendered")
    if do_png:
        print(f"  PNG: {success_png}/{total} rendered (transparent bg: {'YES' if HAS_PILLOW else 'NO — install Pillow'})")

    if failed:
        print(f"\nFAILED ({len(failed)}):")
        for r in sorted(failed, key=lambda x: x["name"]):
            err = r.get("stl_error", "unknown")[:80]
            print(f"  {r['name']}: {err}")

    # Save render results
    results_path = GROUND_TRUTH_DIR / "render_results.json"
    with open(results_path, "w") as f:
        json.dump({
            "total": total,
            "stl_success": success_stl,
            "png_success": success_png,
            "failed_count": len(failed),
            "results": sorted(results, key=lambda r: r["name"]),
        }, f, indent=2)
    print(f"\nRender results saved to: {results_path}")

    # Next steps
    print(f"""
{'=' * 70}
NEXT STEPS:
  1. python compute_complexity.py    # Score components → benchmark_ground_truth.json
  2. python generate_prompts.py      # Add anonymized prompts → benchmark_ground_truth.json
                                     #                        → benchmark_prompts.txt
Output files after all 3 scripts:
  ground_truth/stl/*.stl           — 3D mesh ground truth (for Chamfer Distance eval)
  ground_truth/png/*.png           — Visual reference (transparent background)
  benchmark_ground_truth.json      — Full metadata + scores + prompts (answer key)
  benchmark_prompts.txt            — Anonymized prompts (given to GPT-4o / GPT-5.2 / CRAFT)
{'=' * 70}""")


if __name__ == "__main__":
    main()
