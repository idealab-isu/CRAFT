#!/usr/bin/env python3
"""
Generate ground truth .scad files for all NopSCADlib components,
then render each to .stl and .png via OpenSCAD CLI.

Reads the component catalog from enumerate_nopscadlib.py output,
generates a .scad file per component, and batch-renders them.

Usage:
    python generate_ground_truth.py              # Generate all
    python generate_ground_truth.py --scad-only  # Only generate .scad (no render)
    python generate_ground_truth.py --family ball_bearing  # Only one family
"""

import os
import sys
import json
import subprocess
import argparse
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# ── paths ──────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).parent
CATALOG_PATH = SCRIPT_DIR / "nopscadlib_component_catalog.json"
GROUND_TRUTH_DIR = SCRIPT_DIR / "ground_truth"
SCAD_DIR = GROUND_TRUTH_DIR / "scad"
STL_DIR = GROUND_TRUTH_DIR / "stl"
PNG_DIR = GROUND_TRUTH_DIR / "png"

CRAFT_DIR = SCRIPT_DIR.parent / "craft"
NOPSCADLIB_PARENT = CRAFT_DIR / "kb_data"

# OpenSCAD settings
OPENSCAD_BIN = "openscad"
PNG_SIZE = "512,512"
# Isometric camera: translateX,Y,Z, rotX,rotY,rotZ, distance
CAMERA_ISO = "0,0,0,55,0,25,0"  # autofit with distance=0

# ── modules needing extra params ──────────────────────────────────
# module_function -> extra args to append after the type constant
EXTRA_PARAMS = {
    "screw": ", 10",             # length=10mm
    "rail": ", 100",             # length=100mm
    "extrusion": ", 100",        # length=100mm
    "hot_end": ", 1.75",         # filament=1.75mm
    "sbr_rail": ", 100",         # l=100mm
    "box_section": ", 100",      # length=100mm
}

# Families to skip entirely (not useful for visual CAD benchmarking)
SKIP_FAMILIES = {
    # Too many near-identical variants or not visually interesting
    # User will do final manual filtering, but these are clearly junk
}

# Belt is special - needs complex path, skip for now
SKIP_MODULES = {"belt"}


def load_catalog() -> dict:
    if not CATALOG_PATH.exists():
        print(f"ERROR: Catalog not found at {CATALOG_PATH}")
        print("Run enumerate_nopscadlib.py first.")
        sys.exit(1)
    with open(CATALOG_PATH) as f:
        return json.load(f)


def generate_scad(component: dict) -> Path:
    """Generate a .scad file for one component."""
    type_const = component["type_constant"]
    module_func = component["module_function"]
    family = component["component_family"]
    display_name = component.get("display_name", type_const)
    description = component.get("description", "")

    # Build the module call
    extra = EXTRA_PARAMS.get(module_func, "")
    scad_call = f"{module_func}({type_const}{extra});"

    # Build the .scad content
    lines = [
        f"// Ground truth: {display_name}",
        f"// Family: {family}",
        f"// Type constant: {type_const}",
        f"// Module call: {scad_call}",
    ]
    if description:
        lines.append(f"// Description: {description}")
    lines += [
        "",
        "include <nopscadlib/lib.scad>",
        "",
        scad_call,
        "",
    ]

    scad_content = "\n".join(lines)

    # File naming: family__type_constant.scad (double underscore separates)
    filename = f"{family}__{type_const}.scad"
    scad_path = SCAD_DIR / filename
    scad_path.write_text(scad_content)
    return scad_path


def render_one(scad_path: Path, timeout_sec: int = 120) -> dict:
    """Render a single .scad file to .stl and .png.
    Returns a result dict with status info."""
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

    # Render STL
    t0 = time.time()
    try:
        proc = subprocess.run(
            ["xvfb-run", "-a", OPENSCAD_BIN, "-o", str(stl_path), str(scad_path)],
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

    result["render_time"] = round(time.time() - t0, 1)

    # Render PNG (only if STL succeeded)
    if result["stl_ok"]:
        try:
            proc = subprocess.run(
                [
                    "xvfb-run", "-a", OPENSCAD_BIN,
                    "-o", str(png_path),
                    "--imgsize", PNG_SIZE,
                    "--camera", CAMERA_ISO,
                    "--autocenter", "--viewall",
                    str(scad_path),
                ],
                capture_output=True, text=True, timeout=timeout_sec, env=env,
            )
            if png_path.exists() and png_path.stat().st_size > 0:
                result["png_ok"] = True
                result["png"] = str(png_path)
        except subprocess.TimeoutExpired:
            result["png_error"] = f"Timeout ({timeout_sec}s)"
        except Exception as e:
            result["png_error"] = str(e)

    return result


def main():
    parser = argparse.ArgumentParser(description="Generate NopSCADlib ground truth")
    parser.add_argument("--scad-only", action="store_true",
                        help="Only generate .scad files, skip rendering")
    parser.add_argument("--family", type=str, default=None,
                        help="Only process one component family")
    parser.add_argument("--workers", type=int, default=4,
                        help="Parallel render workers")
    parser.add_argument("--timeout", type=int, default=120,
                        help="Render timeout per component (seconds)")
    args = parser.parse_args()

    # Create output dirs
    for d in [SCAD_DIR, STL_DIR, PNG_DIR]:
        d.mkdir(parents=True, exist_ok=True)

    # Load catalog
    catalog = load_catalog()
    components = catalog["components"]
    print(f"Loaded {len(components)} components from catalog")

    # Filter
    filtered = []
    for comp in components:
        family = comp["component_family"]
        module = comp["module_function"]

        if args.family and family != args.family:
            continue
        if family in SKIP_FAMILIES:
            continue
        if module in SKIP_MODULES:
            continue

        filtered.append(comp)

    print(f"Generating .scad for {len(filtered)} components "
          f"(skipped: {len(components) - len(filtered)})")

    # Generate .scad files
    scad_paths = []
    for comp in filtered:
        scad_path = generate_scad(comp)
        scad_paths.append((comp, scad_path))

    print(f"Generated {len(scad_paths)} .scad files in {SCAD_DIR}")

    if args.scad_only:
        print("--scad-only: skipping rendering")
        return

    # Render all
    print(f"\nRendering {len(scad_paths)} components (workers={args.workers}, "
          f"timeout={args.timeout}s)...")
    print("=" * 70)

    results = []
    success_stl = 0
    success_png = 0
    failed = []

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        future_to_comp = {
            executor.submit(render_one, scad_path, args.timeout): (comp, scad_path)
            for comp, scad_path in scad_paths
        }

        for i, future in enumerate(as_completed(future_to_comp), 1):
            comp, scad_path = future_to_comp[future]
            try:
                result = future.result()
            except Exception as e:
                result = {"name": scad_path.stem, "stl_ok": False,
                          "png_ok": False, "stl_error": str(e)}

            results.append(result)

            status = "OK" if result["stl_ok"] else "FAIL"
            if result["stl_ok"]:
                success_stl += 1
            if result.get("png_ok"):
                success_png += 1
            if not result["stl_ok"]:
                failed.append(result)

            # Progress line
            size_kb = result.get("stl_size", 0) / 1024
            time_s = result.get("render_time", 0)
            print(f"  [{i:3d}/{len(scad_paths)}] {status:4s} "
                  f"{result['name'][:50]:50s} "
                  f"{size_kb:7.0f}KB  {time_s:5.1f}s")

    # Summary
    print(f"\n{'=' * 70}")
    print(f"RESULTS: {success_stl}/{len(scad_paths)} STL rendered, "
          f"{success_png}/{len(scad_paths)} PNG rendered")

    if failed:
        print(f"\nFAILED ({len(failed)}):")
        for r in failed:
            err = r.get("stl_error", "unknown")[:80]
            print(f"  {r['name']}: {err}")

    # Save render results
    results_path = GROUND_TRUTH_DIR / "render_results.json"
    with open(results_path, "w") as f:
        json.dump({
            "total": len(scad_paths),
            "stl_success": success_stl,
            "png_success": success_png,
            "failed_count": len(failed),
            "results": results,
        }, f, indent=2)
    print(f"\nRender results saved to: {results_path}")


if __name__ == "__main__":
    main()
