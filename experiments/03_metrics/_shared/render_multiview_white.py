"""
Render multi-view images (6 ortho + isometric) with WHITE background.

Usage:
    python render_multiview_white.py <scad_file> <output_dir> [--prefix NAME]

Example:
    python render_multiview_white.py Coffee_mug.scad figures/png/Coffee_mug --prefix Coffee_mug
    python render_multiview_white.py Dc_motor.scad figures/png/Dc_motor --prefix Dc_motor

This generates 7 images:
    {prefix}_front.png, {prefix}_back.png, {prefix}_left.png,
    {prefix}_right.png, {prefix}_top.png, {prefix}_bottom.png,
    {prefix}_iso.png
"""

import os
import sys
import subprocess
import argparse


# ── Camera configurations ────────────────────────────────────────────────────
# Format: translate_x, translate_y, translate_z, rot_x, rot_y, rot_z, distance
VIEWS = {
    "front":  "0,0,0,0,0,0,{D}",
    "back":   "0,0,0,0,0,180,{D}",
    "left":   "0,0,0,0,0,90,{D}",
    "right":  "0,0,0,0,0,-90,{D}",
    "top":    "0,0,0,90,0,0,{D}",
    "bottom": "0,0,0,-90,0,0,{D}",
    "iso":    "0,0,0,55,0,45,{D}",
}

# ── Defaults ─────────────────────────────────────────────────────────────────
COLORSCHEME = "Tomorrow"       # White background (was "Tomorrow Night")
IMGSIZE = (400, 400)
DISTANCE = 200
TIMEOUT = 60


def render_view(scad_path, output_path, camera_string):
    """Render a single view using OpenSCAD."""
    cmd = [
        "openscad",
        "-o", output_path,
        f"--imgsize={IMGSIZE[0]},{IMGSIZE[1]}",
        "--preview",
        "--colorscheme", COLORSCHEME,
        "--autocenter",
        "--viewall",
        "--camera", camera_string,
        scad_path
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=TIMEOUT)
        success = (
            result.returncode == 0
            and os.path.exists(output_path)
            and os.path.getsize(output_path) > 0
        )
        if not success:
            print(f"  FAILED: {result.stderr[:200]}")
        return success
    except subprocess.TimeoutExpired:
        print(f"  TIMEOUT after {TIMEOUT}s")
        return False
    except FileNotFoundError:
        print("  ERROR: OpenSCAD not found. Make sure it's installed and in PATH.")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(description="Render multi-view PNGs with white background")
    parser.add_argument("scad_file", help="Path to the .scad file")
    parser.add_argument("output_dir", help="Output directory for PNG images")
    parser.add_argument("--prefix", default=None, help="Filename prefix (default: scad filename without extension)")
    parser.add_argument("--size", type=int, nargs=2, default=[400, 400], help="Image size (width height)")
    parser.add_argument("--distance", type=int, default=200, help="Camera distance factor")
    args = parser.parse_args()

    if not os.path.exists(args.scad_file):
        print(f"Error: {args.scad_file} not found")
        sys.exit(1)

    global IMGSIZE, DISTANCE
    IMGSIZE = tuple(args.size)
    DISTANCE = args.distance

    prefix = args.prefix or os.path.splitext(os.path.basename(args.scad_file))[0]
    os.makedirs(args.output_dir, exist_ok=True)

    print(f"Rendering: {args.scad_file}")
    print(f"Output:    {args.output_dir}/{prefix}_*.png")
    print(f"Scheme:    {COLORSCHEME} (white background)")
    print(f"Size:      {IMGSIZE[0]}x{IMGSIZE[1]}")
    print()

    success_count = 0
    for view_name, camera_template in VIEWS.items():
        camera_str = camera_template.format(D=DISTANCE)
        out_path = os.path.join(args.output_dir, f"{prefix}_{view_name}.png")
        print(f"  [{view_name:6s}] -> {out_path} ... ", end="", flush=True)

        if render_view(args.scad_file, out_path, camera_str):
            print("OK")
            success_count += 1
        else:
            print("FAIL")

    print(f"\nDone: {success_count}/{len(VIEWS)} views rendered successfully.")


if __name__ == "__main__":
    main()
