#!/usr/bin/env python3
"""
Step 1: Render 6 orthographic views from STL files using OpenSCAD.

For each STL file, creates a temporary .scad wrapper that imports the STL,
then renders 6 views (front, back, left, right, top, bottom) with white
background and transparent post-processing.

Prerequisites:
    - OpenSCAD installed:  sudo apt-get install openscad
    - xvfb (headless):     sudo apt-get install xvfb   (Linux only)
    - Pillow:              pip install Pillow

Usage:
    # Render views for Slice100K dataset
    python ext_step1_render_views.py \
        --stl-dir "/path/to/Slice100k 100 samples/stl"

    # Render views for ABC dataset
    python ext_step1_render_views.py \
        --stl-dir "/path/to/ABC dataset 100 samples/stl"

    # Custom output directory and image size
    python ext_step1_render_views.py \
        --stl-dir "/path/to/stl" \
        --png-dir "/path/to/png" \
        --size 512 512 \
        --workers 4

Output:
    <png-dir>/<sample_id>/front.png
    <png-dir>/<sample_id>/back.png
    <png-dir>/<sample_id>/left.png
    <png-dir>/<sample_id>/right.png
    <png-dir>/<sample_id>/top.png
    <png-dir>/<sample_id>/bottom.png

Run order (full pipeline):
    1. python ext_step1_render_views.py   --stl-dir <...>     # This script
    2. python ext_step2_generate_ground_truth.py --stl-dir <...> --dataset-name <...>
    3. python ext_step3_run_benchmark.py  --benchmark-json <...>
    4. python ext_step4_evaluate.py       --benchmark-json <...> --results-dir <...>
"""

import os
import sys
import shutil
import subprocess
import argparse
import platform
import tempfile
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    from PIL import Image
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False

# ── Camera configurations ────────────────────────────────────────────────────
# Format: translate_x, translate_y, translate_z, rot_x, rot_y, rot_z, distance
# Distance=0 means use --viewall to auto-fit
VIEWS = {
    "front":  "0,0,0,0,0,0,0",
    "back":   "0,0,0,0,0,180,0",
    "left":   "0,0,0,0,0,90,0",
    "right":  "0,0,0,0,0,-90,0",
    "top":    "0,0,0,90,0,0,0",
    "bottom": "0,0,0,-90,0,0,0",
}

OPENSCAD_BIN = "openscad"
COLORSCHEME = "Tomorrow"  # White background
BG_TOLERANCE = 30


def needs_xvfb() -> bool:
    """Check if xvfb-run is needed (Linux without display)."""
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


def make_transparent(png_path: Path, tolerance: int = BG_TOLERANCE):
    """Post-process a PNG to make the background transparent."""
    if not HAS_PILLOW:
        return

    try:
        img = Image.open(png_path).convert("RGBA")
    except Exception:
        return

    pixels = img.load()
    w, h = img.size

    # Sample background color from corners
    corner_samples = []
    for cx, cy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                x = max(0, min(w - 1, cx + dx))
                y = max(0, min(h - 1, cy + dy))
                r, g, b, a = pixels[x, y]
                corner_samples.append((r, g, b))

    bg_r = sorted(s[0] for s in corner_samples)[len(corner_samples) // 2]
    bg_g = sorted(s[1] for s in corner_samples)[len(corner_samples) // 2]
    bg_b = sorted(s[2] for s in corner_samples)[len(corner_samples) // 2]

    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            dist = abs(r - bg_r) + abs(g - bg_g) + abs(b - bg_b)
            if dist < tolerance:
                pixels[x, y] = (r, g, b, 0)
            elif dist < tolerance * 2:
                alpha = int(255 * (dist - tolerance) / tolerance)
                pixels[x, y] = (r, g, b, min(255, alpha))

    img.save(png_path, "PNG")


def render_stl_views(
    stl_path: Path,
    output_dir: Path,
    img_size: tuple = (512, 512),
    timeout_sec: int = 120,
) -> dict:
    """
    Render 6 orthographic views of an STL file using OpenSCAD.

    Creates a temp .scad file that imports the STL, then renders
    from each camera angle.
    """
    sample_id = stl_path.stem
    sample_dir = output_dir / sample_id
    sample_dir.mkdir(parents=True, exist_ok=True)

    result = {
        "id": sample_id,
        "stl": str(stl_path),
        "views_rendered": 0,
        "views_failed": [],
        "render_time": 0,
    }

    t0 = time.time()

    # Create temporary SCAD file that imports the STL
    # Use absolute path and forward slashes for OpenSCAD compatibility
    stl_abs = str(stl_path.resolve()).replace("\\", "/")
    scad_content = f'import("{stl_abs}");\n'

    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".scad", delete=False
    ) as tmp:
        tmp.write(scad_content)
        tmp_scad = tmp.name

    try:
        for view_name, camera_str in VIEWS.items():
            png_path = sample_dir / f"{view_name}.png"

            try:
                proc = subprocess.run(
                    openscad_cmd([
                        OPENSCAD_BIN,
                        "-o", str(png_path),
                        f"--imgsize={img_size[0]},{img_size[1]}",
                        "--preview",
                        "--colorscheme", COLORSCHEME,
                        "--autocenter",
                        "--viewall",
                        "--camera", camera_str,
                        tmp_scad,
                    ]),
                    capture_output=True,
                    text=True,
                    timeout=timeout_sec,
                )

                if png_path.exists() and png_path.stat().st_size > 0:
                    make_transparent(png_path)
                    result["views_rendered"] += 1
                else:
                    result["views_failed"].append(view_name)

            except subprocess.TimeoutExpired:
                result["views_failed"].append(f"{view_name}(timeout)")
            except Exception as e:
                result["views_failed"].append(f"{view_name}({e})")

    finally:
        os.unlink(tmp_scad)

    result["render_time"] = round(time.time() - t0, 1)
    return result


def check_prerequisites():
    """Verify OpenSCAD is available."""
    errors = []

    try:
        proc = subprocess.run(
            openscad_cmd([OPENSCAD_BIN, "--version"]),
            capture_output=True, text=True, timeout=10,
        )
        version = (proc.stdout + proc.stderr).strip()
        print(f"  OpenSCAD: {version}")
    except FileNotFoundError:
        errors.append("OpenSCAD not found. Install with: sudo apt-get install openscad")

    if platform.system() == "Linux" and not os.environ.get("DISPLAY"):
        if shutil.which("xvfb-run"):
            print("  xvfb-run: OK (headless mode)")
        else:
            errors.append("No DISPLAY and xvfb-run not found. Install: sudo apt-get install xvfb")

    if HAS_PILLOW:
        print("  Pillow: OK (transparent background enabled)")
    else:
        print("  Pillow: NOT FOUND (pip install Pillow for transparent backgrounds)")

    if errors:
        print("\nERRORS:")
        for e in errors:
            print(f"  - {e}")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description="Render 6 orthographic views from STL files using OpenSCAD",
        epilog="Next: python ext_step2_generate_ground_truth.py --stl-dir <...> --dataset-name <...>",
    )
    parser.add_argument("--stl-dir", type=str, required=True,
                        help="Directory containing STL files")
    parser.add_argument("--png-dir", type=str, default=None,
                        help="Output directory for PNG views (default: <stl-dir>/../png)")
    parser.add_argument("--size", type=int, nargs=2, default=[512, 512],
                        help="Image size (width height), default: 512 512")
    parser.add_argument("--workers", type=int, default=4,
                        help="Parallel render workers (default: 4)")
    parser.add_argument("--timeout", type=int, default=120,
                        help="Render timeout per STL in seconds (default: 120)")
    args = parser.parse_args()

    stl_dir = Path(args.stl_dir)
    if not stl_dir.exists():
        print(f"Error: STL directory not found: {stl_dir}")
        sys.exit(1)

    # Default PNG dir is sibling of STL dir
    if args.png_dir:
        png_dir = Path(args.png_dir)
    else:
        png_dir = stl_dir.parent / "png"

    png_dir.mkdir(parents=True, exist_ok=True)

    # Find STL files
    stl_files = sorted(stl_dir.glob("*.stl"))
    if not stl_files:
        # Also check for .STL (uppercase)
        stl_files = sorted(stl_dir.glob("*.STL"))

    if not stl_files:
        print(f"Error: No STL files found in {stl_dir}")
        sys.exit(1)

    print("=" * 70)
    print("External Dataset: Render STL Views")
    print("=" * 70)
    print(f"  STL directory: {stl_dir}")
    print(f"  PNG directory: {png_dir}")
    print(f"  STL files:     {len(stl_files)}")
    print(f"  Image size:    {args.size[0]}x{args.size[1]}")
    print(f"  Workers:       {args.workers}")
    print()

    # Check prerequisites
    print("Checking prerequisites...")
    check_prerequisites()
    print()

    # Render all STL files
    total = len(stl_files)
    success_count = 0
    failed = []

    print(f"Rendering {total} STL files (6 views each)...")
    print("-" * 70)

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        future_to_stl = {
            executor.submit(
                render_stl_views,
                f,
                png_dir,
                tuple(args.size),
                args.timeout,
            ): f
            for f in stl_files
        }

        for i, future in enumerate(as_completed(future_to_stl), 1):
            stl_path = future_to_stl[future]
            try:
                result = future.result()
            except Exception as e:
                result = {
                    "id": stl_path.stem,
                    "views_rendered": 0,
                    "views_failed": [str(e)],
                    "render_time": 0,
                }

            rendered = result["views_rendered"]
            total_views = len(VIEWS)

            if rendered == total_views:
                success_count += 1
                status = "OK"
            else:
                failed.append(result)
                status = f"PARTIAL ({rendered}/{total_views})"

            print(
                f"  [{i:3d}/{total}] {status:12s} "
                f"{result['id'][:45]:45s} "
                f"{result['render_time']:5.1f}s"
            )

    # Summary
    print(f"\n{'=' * 70}")
    print("RESULTS:")
    print(f"  Total STL files:    {total}")
    print(f"  Fully rendered:     {success_count}")
    print(f"  Partially/failed:   {len(failed)}")

    if failed:
        print(f"\nFAILED/PARTIAL:")
        for r in sorted(failed, key=lambda x: x["id"]):
            print(f"  {r['id']}: failed views = {r['views_failed']}")

    print(f"""
{'=' * 70}
NEXT STEP:
  python ext_step2_generate_ground_truth.py \\
      --stl-dir "{stl_dir}" \\
      --png-dir "{png_dir}" \\
      --dataset-name <slice100k|abc>
{'=' * 70}""")


if __name__ == "__main__":
    main()
