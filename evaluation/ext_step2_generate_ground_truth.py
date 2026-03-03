#!/usr/bin/env python3
"""
Step 2: Generate captions from rendered views and create ground truth JSON.

For each sample:
  1. Quality-gate the 6 rendered views (reject blank/corrupt images)
  2. Call VisionAnalyzer (GPT-4o) to generate captions + structured features
  3. Generate 3 prompt variants from vision output:
       - descriptive:     natural language caption
       - reconstructable: structured, parametric wording (primitives, symmetry, constraints)
       - program_hint:    pseudo-CSG construction steps
  4. Compute rich mesh statistics (face count, hull ratio, compactness, etc.)
  5. Assign complexity tiers via composite score (not just face count)
  6. Write ground truth JSON (compatible with evaluate_benchmark.py)

Prerequisites:
    - Step 1 completed (PNG views rendered)
    - pip install trimesh numpy openai python-dotenv pillow
    - OPENAI_API_KEY set in environment or .env file

Usage:
    # Slice100K dataset
    python ext_step2_generate_ground_truth.py \
        --stl-dir "/path/to/Slice100k 100 samples/stl" \
        --png-dir "/path/to/Slice100k 100 samples/png" \
        --dataset-name slice100k

    # ABC dataset
    python ext_step2_generate_ground_truth.py \
        --stl-dir "/path/to/ABC dataset 100 samples/stl" \
        --png-dir "/path/to/ABC dataset 100 samples/png" \
        --dataset-name abc

    # Resume after interruption (skips samples already in JSON)
    python ext_step2_generate_ground_truth.py \
        --stl-dir <...> --dataset-name abc --resume

Output:
    <script_dir>/<dataset_name>_ground_truth.json
    <script_dir>/<dataset_name>_prompts.json

Run order:
    1. python ext_step1_render_views.py   --stl-dir <...>
    2. python ext_step2_generate_ground_truth.py --stl-dir <...> --dataset-name <...>  # This
    3. python ext_step3_run_benchmark.py  --benchmark-json <...>
    4. python ext_step4_evaluate.py       --benchmark-json <...> --results-dir <...>
"""

import os
import sys
import json
import time
import hashlib
import argparse
import traceback
from pathlib import Path
from typing import Dict, List, Any, Optional

import numpy as np

SCRIPT_DIR = Path(__file__).parent
CADENCE_DIR = SCRIPT_DIR.parent / "cadence"
sys.path.insert(0, str(CADENCE_DIR))

from dotenv import load_dotenv
load_dotenv()

# View names matching VisionAnalyzer's expected order
VIEW_NAMES = ["front", "back", "left", "right", "top", "bottom"]

# Vision model for captioning
VISION_MODEL = "gpt-5.2"
VISION_TEMPERATURE = 0.3

# Quality gate thresholds
MIN_NON_BG_PIXEL_RATIO = 0.01   # At least 1% of pixels must be non-background
MIN_IMAGE_SIZE = (64, 64)        # Minimum image dimensions
MIN_VALID_VIEWS = 3              # Need at least 3 valid views to proceed


# =============================================================================
# QUALITY GATES
# =============================================================================

def check_view_quality(image_path: str) -> Dict[str, Any]:
    """
    Check a single rendered view for quality issues.

    Returns dict with:
        valid: bool
        issues: list of strings
        non_bg_ratio: float (fraction of non-background pixels)
        width, height: int
    """
    from PIL import Image

    result = {"valid": True, "issues": [], "non_bg_ratio": 0.0, "width": 0, "height": 0}

    try:
        img = Image.open(image_path)
        w, h = img.size
        result["width"] = w
        result["height"] = h

        # Check minimum size
        if w < MIN_IMAGE_SIZE[0] or h < MIN_IMAGE_SIZE[1]:
            result["valid"] = False
            result["issues"].append(f"too_small({w}x{h})")
            return result

        # Check non-background pixel ratio
        # Convert to grayscale, count pixels that differ from corners (background)
        gray = np.array(img.convert("L"), dtype=np.float32)
        corners = [gray[0, 0], gray[0, -1], gray[-1, 0], gray[-1, -1]]
        bg_val = np.median(corners)
        non_bg = np.abs(gray - bg_val) > 15  # 15/255 tolerance
        ratio = float(non_bg.sum()) / gray.size
        result["non_bg_ratio"] = round(ratio, 4)

        if ratio < MIN_NON_BG_PIXEL_RATIO:
            result["valid"] = False
            result["issues"].append(f"blank({ratio:.3f})")

    except Exception as e:
        result["valid"] = False
        result["issues"].append(f"load_error({e})")

    return result


def quality_gate_views(
    sample_png_dir: Path,
) -> tuple:
    """
    Check all views for a sample and return valid paths + quality report.

    Returns:
        (valid_image_paths, valid_view_names, quality_report)
    """
    image_paths = []
    view_names_found = []
    quality_report = {"views_checked": 0, "views_valid": 0, "views_rejected": [], "issues": []}

    for vn in VIEW_NAMES:
        img_path = sample_png_dir / f"{vn}.png"
        if not img_path.exists():
            quality_report["issues"].append(f"{vn}: missing")
            continue

        quality_report["views_checked"] += 1
        check = check_view_quality(str(img_path))

        if check["valid"]:
            image_paths.append(str(img_path))
            view_names_found.append(vn)
            quality_report["views_valid"] += 1
        else:
            quality_report["views_rejected"].append(vn)
            quality_report["issues"].append(f"{vn}: {', '.join(check['issues'])}")

    return image_paths, view_names_found, quality_report


# =============================================================================
# MESH STATISTICS (Enhanced)
# =============================================================================

def compute_mesh_stats(stl_path: str) -> Dict[str, Any]:
    """
    Compute rich mesh statistics from an STL file using trimesh.

    Returns dict with:
        - vertex_count, face_count, edge_count
        - bbox_x, bbox_y, bbox_z
        - surface_area, volume (if watertight)
        - is_watertight, connected_components, euler_number
        - convex_hull_ratio (volume / hull_volume)
        - compactness (volume^(2/3) / surface_area)
        - bbox_volume, surface_to_bbox_ratio
    """
    import trimesh

    try:
        mesh = trimesh.load(stl_path)

        if isinstance(mesh, trimesh.Scene):
            meshes = [
                g for g in mesh.geometry.values()
                if isinstance(g, trimesh.Trimesh)
            ]
            if not meshes:
                return {"error": "Empty scene"}
            mesh = trimesh.util.concatenate(meshes)

        if not isinstance(mesh, trimesh.Trimesh):
            return {"error": "Not a valid mesh"}

        bbox = mesh.bounding_box.extents
        bbox_vol = float(bbox[0] * bbox[1] * bbox[2])

        stats = {
            "vertex_count": int(mesh.vertices.shape[0]),
            "face_count": int(mesh.faces.shape[0]),
            "bbox_x": round(float(bbox[0]), 3),
            "bbox_y": round(float(bbox[1]), 3),
            "bbox_z": round(float(bbox[2]), 3),
            "bbox_volume": round(bbox_vol, 3),
        }

        # Edge count
        try:
            stats["edge_count"] = int(len(mesh.edges_unique))
        except Exception:
            stats["edge_count"] = 0

        # Topology
        stats["is_watertight"] = bool(mesh.is_watertight)

        try:
            stats["euler_number"] = int(mesh.euler_number)
        except Exception:
            stats["euler_number"] = 0

        # Connected components
        try:
            body_count = mesh.body_count if hasattr(mesh, 'body_count') else 1
            stats["connected_components"] = int(body_count)
        except Exception:
            stats["connected_components"] = 1

        # Surface area
        try:
            stats["surface_area"] = round(float(mesh.area), 3)
            if bbox_vol > 1e-10:
                bbox_surface = 2 * (bbox[0]*bbox[1] + bbox[1]*bbox[2] + bbox[0]*bbox[2])
                stats["surface_to_bbox_ratio"] = round(
                    float(mesh.area / bbox_surface), 4
                )
        except Exception:
            pass

        # Volume + derived metrics (only for watertight)
        try:
            if mesh.is_watertight:
                vol = float(mesh.volume)
                stats["volume"] = round(vol, 3)

                # Compactness: volume^(2/3) / surface_area
                # Higher = more sphere-like, lower = more complex surface
                if mesh.area > 1e-10:
                    stats["compactness"] = round(
                        float((vol ** (2.0/3.0)) / mesh.area), 6
                    )

                # Convex hull ratio: volume / hull_volume
                # 1.0 = fully convex, lower = more concavities/holes
                try:
                    hull = mesh.convex_hull
                    hull_vol = float(hull.volume)
                    if hull_vol > 1e-10:
                        stats["convex_hull_ratio"] = round(vol / hull_vol, 4)
                except Exception:
                    pass
        except Exception:
            pass

        return stats

    except Exception as e:
        return {"error": str(e)}


# =============================================================================
# COMPOSITE COMPLEXITY SCORE & TIERING
# =============================================================================

def compute_complexity_score(stats: Dict[str, Any]) -> float:
    """
    Compute a composite complexity score from mesh stats.

    Factors (normalized to [0, 1] range, then weighted):
        - face_count (log-scaled)         weight=0.25
        - connected_components            weight=0.15
        - 1 - convex_hull_ratio           weight=0.25 (more concavities = more complex)
        - surface_to_bbox_ratio           weight=0.20 (higher surface detail = more complex)
        - 1 - compactness (normalized)    weight=0.15

    Returns score in [0, 100].
    """
    if stats.get("error"):
        return 0.0

    score = 0.0

    # Face count (log-scaled, typical range: 100 to 1M)
    fc = stats.get("face_count", 0)
    if fc > 0:
        # log10(100)=2, log10(1M)=6 -> normalize to [0,1]
        fc_norm = min(1.0, max(0.0, (np.log10(fc) - 2.0) / 4.0))
        score += 0.25 * fc_norm

    # Connected components (1=simple, 5+=complex)
    cc = stats.get("connected_components", 1)
    cc_norm = min(1.0, (cc - 1) / 4.0)
    score += 0.15 * cc_norm

    # Convex hull ratio (1.0=convex=simple, 0.3=very concave=complex)
    chr_val = stats.get("convex_hull_ratio", 1.0)
    chr_norm = min(1.0, max(0.0, 1.0 - chr_val))
    score += 0.25 * chr_norm

    # Surface to bbox ratio (1.0=box-like=simple, 3.0+=detailed=complex)
    sbr = stats.get("surface_to_bbox_ratio", 1.0)
    sbr_norm = min(1.0, max(0.0, (sbr - 1.0) / 2.0))
    score += 0.20 * sbr_norm

    # Compactness (higher=sphere-like=simple, lower=complex surface)
    comp = stats.get("compactness", 0.1)
    # Typical range: 0.01 (complex) to 0.2 (sphere)
    comp_norm = min(1.0, max(0.0, 1.0 - comp / 0.2))
    score += 0.15 * comp_norm

    return round(score * 100, 2)


def assign_tiers(components: List[Dict]) -> List[Dict]:
    """
    Assign Simple/Medium/Complex tiers based on composite complexity score.

    Bottom 33% by score = Simple
    Middle 34%           = Medium
    Top 33%              = Complex
    """
    scores = []
    for c in components:
        stats = c.get("mesh_stats", {})
        score = compute_complexity_score(stats)
        c["complexity_score"] = score
        scores.append(score)

    if not scores:
        return components

    scores_arr = np.array(scores)
    p33 = float(np.percentile(scores_arr, 33))
    p66 = float(np.percentile(scores_arr, 66))

    for c in components:
        s = c.get("complexity_score", 0)
        if s <= p33:
            c["tier"] = "Simple"
        elif s <= p66:
            c["tier"] = "Medium"
        else:
            c["tier"] = "Complex"

    return components


# =============================================================================
# PROMPT VARIANT GENERATION
# =============================================================================

def generate_prompt_variants(
    caption_data: Dict[str, Any],
    mesh_stats: Dict[str, Any],
) -> Dict[str, str]:
    """
    Generate 3 prompt variants from vision output + mesh stats.

    1. descriptive:     Natural language caption with bounding box
    2. reconstructable: Structured parametric spec with exact dimensions,
                        proportional constraints, primitives, symmetry
    3. program_hint:    Pseudo-OpenSCAD construction steps with actual
                        dimension values and CSG operations

    All generated deterministically from VisionAnalyzer output — no extra
    API calls needed.
    """
    best = caption_data.get("best_caption", "A 3D object")
    features = caption_data.get("identified_features", {})

    # Extract structured fields from vision features
    primary_shape = features.get("primary_shape", "complex")
    primitives = features.get("primitives", [])
    feat_list = features.get("features", [])
    symmetry = features.get("symmetry", "unknown")
    complexity = features.get("estimated_complexity", "medium")

    # Get bounding box for dimension hints
    bx = mesh_stats.get("bbox_x", 0)
    by = mesh_stats.get("bbox_y", 0)
    bz = mesh_stats.get("bbox_z", 0)
    has_dims = bx > 0 and by > 0 and bz > 0

    # Compute proportional relationships
    dims_sorted = sorted([bx, by, bz], reverse=True)
    aspect_ratios = {}
    if has_dims and dims_sorted[2] > 0.01:
        aspect_ratios["longest_to_shortest"] = round(dims_sorted[0] / dims_sorted[2], 2)
        aspect_ratios["longest_to_mid"] = round(dims_sorted[0] / dims_sorted[1], 2) if dims_sorted[1] > 0.01 else 1.0

    # Determine dominant axis and shape heuristics
    is_tall = has_dims and bz > max(bx, by) * 1.3
    is_flat = has_dims and bz < min(bx, by) * 0.5
    is_elongated = has_dims and max(bx, by) > min(bx, by) * 1.5
    is_roughly_square_xy = has_dims and abs(bx - by) / max(bx, by, 0.01) < 0.15

    # ── Variant 1: descriptive (caption + dimensions + proportions) ──
    descriptive = best
    if has_dims:
        descriptive += f" Bounding box: {bx:.1f} x {by:.1f} x {bz:.1f} mm."
        if is_roughly_square_xy and is_tall:
            descriptive += f" The object is upright with a roughly circular/square cross-section."
        elif is_flat:
            descriptive += f" The object is flat/plate-like."
        elif is_elongated:
            descriptive += f" The object is elongated along one axis."

    # ── Variant 2: reconstructable (precise geometric spec) ──
    recon_lines = []
    recon_lines.append(f"OBJECT: {primary_shape} 3D solid")

    if has_dims:
        recon_lines.append(f"DIMENSIONS: {bx:.2f} x {by:.2f} x {bz:.2f} mm (X x Y x Z)")
        if is_roughly_square_xy:
            avg_xy = (bx + by) / 2
            recon_lines.append(f"CROSS-SECTION: approximately square/circular, ~{avg_xy:.1f} mm")
        if aspect_ratios.get("longest_to_shortest", 1) > 1.5:
            recon_lines.append(
                f"ASPECT RATIO: {aspect_ratios['longest_to_shortest']:.1f}:1 "
                f"(longest to shortest)"
            )

    if primitives:
        recon_lines.append(f"PRIMITIVES: {', '.join(primitives[:6])}")

    if feat_list:
        # Classify features as additive or subtractive
        subtractive_kw = {"hole", "holes", "slot", "slots", "groove", "grooves",
                          "cut", "cuts", "notch", "notches", "channel", "channels",
                          "countersink", "counterbore", "bore", "pocket"}
        additive = []
        subtractive = []
        for f in feat_list[:6]:
            if any(kw in f.lower() for kw in subtractive_kw):
                subtractive.append(f)
            else:
                additive.append(f)
        if additive:
            recon_lines.append(f"ADDITIVE FEATURES: {', '.join(additive)}")
        if subtractive:
            recon_lines.append(f"SUBTRACTIVE FEATURES: {', '.join(subtractive)}")

    if symmetry and symmetry not in ("unknown", "none"):
        recon_lines.append(f"SYMMETRY: {symmetry}")

    hull_ratio = mesh_stats.get("convex_hull_ratio")
    if hull_ratio is not None:
        if hull_ratio > 0.85:
            recon_lines.append("TOPOLOGY: mostly convex, few or no internal cavities")
        elif hull_ratio > 0.5:
            recon_lines.append("TOPOLOGY: moderate concavities or internal features")
        else:
            recon_lines.append("TOPOLOGY: highly non-convex, significant internal features")

    recon_lines.append(f"COMPLEXITY: {complexity}")

    if has_dims:
        recon_lines.append(
            f"CONSTRAINT: The final model MUST fit within a {bx:.1f} x {by:.1f} x {bz:.1f} mm "
            f"bounding box, centered at origin."
        )

    reconstructable = "\n".join(recon_lines)

    # ── Variant 3: program_hint (pseudo-OpenSCAD with real dimensions) ──
    shape_to_prim = {
        "cylindrical": "cylinder",
        "rectangular": "cube",
        "spherical": "sphere",
        "cubic": "cube",
        "flat": "cube",
        "conical": "cylinder",  # cone via cylinder with r1/r2
        "complex": "cube",
    }
    base_prim = shape_to_prim.get(primary_shape, "cube")

    prog_lines = []
    prog_lines.append(f"// Target: {best[:80]}")
    prog_lines.append(f"// Bounding box: {bx:.1f} x {by:.1f} x {bz:.1f} mm")
    prog_lines.append("")

    # Generate pseudo-OpenSCAD based on shape type
    if base_prim == "cylinder" and has_dims:
        r = max(bx, by) / 2
        h = bz if is_tall else max(bx, by)
        prog_lines.append(f"// Step 1: Base cylinder")
        prog_lines.append(f"cylinder(r={r:.1f}, h={h:.1f}, center=true, $fn=64);")
    elif base_prim == "sphere" and has_dims:
        r = max(bx, by, bz) / 2
        prog_lines.append(f"// Step 1: Base sphere")
        prog_lines.append(f"sphere(r={r:.1f}, $fn=64);")
    elif has_dims:
        prog_lines.append(f"// Step 1: Base cube")
        prog_lines.append(f"cube([{bx:.1f}, {by:.1f}, {bz:.1f}], center=true);")
    else:
        prog_lines.append(f"// Step 1: Base {base_prim}")
        prog_lines.append(f"{base_prim}();")

    # Add features as CSG operations
    step = 2
    subtractive_kw = {"hole", "holes", "slot", "slots", "groove", "grooves",
                      "cut", "cuts", "notch", "notches", "channel", "channels",
                      "countersink", "counterbore", "bore", "pocket", "chamfer"}

    for feat in feat_list[:5]:
        feat_lower = feat.lower()
        is_cut = any(kw in feat_lower for kw in subtractive_kw)

        if is_cut:
            prog_lines.append(f"")
            prog_lines.append(f"// Step {step}: Subtract {feat}")
            prog_lines.append(f"difference() {{")
            prog_lines.append(f"  // previous solid")
            if "hole" in feat_lower and has_dims:
                hole_r = min(bx, by) * 0.15  # estimate hole as 15% of cross-section
                prog_lines.append(f"  cylinder(r={hole_r:.1f}, h={bz + 1:.1f}, center=true, $fn=64);")
            else:
                prog_lines.append(f"  // cut geometry for {feat}")
            prog_lines.append(f"}}")
        else:
            prog_lines.append(f"")
            prog_lines.append(f"// Step {step}: Add {feat}")
            prog_lines.append(f"union() {{")
            prog_lines.append(f"  // previous solid")
            prog_lines.append(f"  // geometry for {feat}")
            prog_lines.append(f"}}")
        step += 1

    if has_dims:
        prog_lines.append(f"")
        prog_lines.append(f"// CRITICAL: Final bounding box must be ~{bx:.1f} x {by:.1f} x {bz:.1f} mm")

    program_hint = "\n".join(prog_lines)

    return {
        "descriptive": descriptive,
        "reconstructable": reconstructable,
        "program_hint": program_hint,
    }


# =============================================================================
# CAPTION GENERATION
# =============================================================================

def generate_caption(
    client,
    image_paths: List[str],
    view_names: List[str],
) -> Dict[str, Any]:
    """
    Generate caption for a 3D object using VisionAnalyzer.

    Returns dict with best_caption, alternatives, identified_features.
    """
    from core.vision import VisionAnalyzer

    analyzer = VisionAnalyzer(client, VISION_MODEL)
    result = analyzer.analyze(image_paths, view_names)

    return {
        "best_caption": result.best_caption,
        "alternatives": result.alternatives,
        "identified_features": result.identified_features,
    }


# =============================================================================
# SINGLE SAMPLE PROCESSING
# =============================================================================

def process_single_sample(
    sample_id: str,
    stl_path: Path,
    png_dir: Path,
    client,
    dataset_name: str,
) -> Optional[Dict]:
    """Process a single sample: quality gate -> caption -> stats -> prompts."""
    # Find rendered views directory
    sample_png_dir = png_dir / sample_id
    if not sample_png_dir.exists():
        print(f"\n    WARNING: No PNG directory for {sample_id}, skipping")
        return None

    # Quality gate
    image_paths, view_names_found, quality_report = quality_gate_views(sample_png_dir)

    if quality_report["views_valid"] < MIN_VALID_VIEWS:
        issues = "; ".join(quality_report["issues"][:3])
        print(f"\n    WARNING: Only {quality_report['views_valid']} valid views "
              f"for {sample_id} ({issues}), skipping")
        return None

    # Compute mesh stats
    mesh_stats = compute_mesh_stats(str(stl_path))

    # Generate caption via VisionAnalyzer
    caption_data = generate_caption(client, image_paths, view_names_found)

    # Generate 3 prompt variants
    prompts = generate_prompt_variants(caption_data, mesh_stats)

    # Compute caption hash for reproducibility tracking
    caption_hash = hashlib.sha256(
        caption_data["best_caption"].encode()
    ).hexdigest()[:12]

    # Build component entry (compatible with evaluate_benchmark.py)
    component = {
        "id": sample_id,
        "stl_file": str(stl_path),
        "png_file": str(sample_png_dir / "front.png"),
        "views_dir": str(sample_png_dir),
        # Default prompt is descriptive (step 3 can select variant)
        "prompt": prompts["descriptive"],
        "prompt_variants": prompts,
        "component_family": dataset_name,
        "tier": "",  # Assigned later by composite score
        "complexity_score": 0.0,  # Assigned later
        "mesh_stats": mesh_stats,
        "caption_data": caption_data,
        "quality_report": quality_report,
        "reproducibility": {
            "vision_model": VISION_MODEL,
            "temperature": VISION_TEMPERATURE,
            "caption_hash": caption_hash,
            "views_used": view_names_found,
        },
    }

    return component


# =============================================================================
# MAIN
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description="Generate captions and create ground truth JSON for external datasets",
        epilog="Next: python ext_step3_run_benchmark.py --benchmark-json <output_json>",
    )
    parser.add_argument("--stl-dir", type=str, required=True,
                        help="Directory containing STL files")
    parser.add_argument("--png-dir", type=str, default=None,
                        help="Directory containing rendered PNG views (default: <stl-dir>/../png)")
    parser.add_argument("--dataset-name", type=str, required=True,
                        choices=["slice100k", "abc"],
                        help="Dataset name (slice100k or abc)")
    parser.add_argument("--output", type=str, default=None,
                        help="Output JSON path (default: <dataset_name>_ground_truth.json)")
    parser.add_argument("--vision-model", type=str, default="gpt-5.2",
                        help="Vision model for captioning (default: gpt-5.2)")
    parser.add_argument("--resume", action="store_true",
                        help="Resume from existing JSON (skip already-captioned samples)")
    args = parser.parse_args()

    global VISION_MODEL
    VISION_MODEL = args.vision_model

    stl_dir = Path(args.stl_dir)
    if not stl_dir.exists():
        print(f"Error: STL directory not found: {stl_dir}")
        sys.exit(1)

    png_dir = Path(args.png_dir) if args.png_dir else stl_dir.parent / "png"
    if not png_dir.exists():
        print(f"Error: PNG directory not found: {png_dir}")
        print("Run ext_step1_render_views.py first.")
        sys.exit(1)

    output_path = Path(args.output) if args.output else (
        SCRIPT_DIR / f"{args.dataset_name}_ground_truth.json"
    )

    # Find STL files
    stl_files = sorted(stl_dir.glob("*.stl")) + sorted(stl_dir.glob("*.STL"))
    if not stl_files:
        print(f"Error: No STL files found in {stl_dir}")
        sys.exit(1)

    print("=" * 70)
    print(f"External Dataset: Generate Ground Truth ({args.dataset_name})")
    print("=" * 70)
    print(f"  STL directory:   {stl_dir}")
    print(f"  PNG directory:   {png_dir}")
    print(f"  STL files:       {len(stl_files)}")
    print(f"  Vision model:    {VISION_MODEL}")
    print(f"  Temperature:     {VISION_TEMPERATURE}")
    print(f"  Output:          {output_path}")
    print()

    # Initialize OpenAI client
    from openai import OpenAI
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("Error: OPENAI_API_KEY not set")
        sys.exit(1)
    client = OpenAI(api_key=api_key)

    # Load existing results for resume
    existing_ids = set()
    existing_components = []
    if args.resume and output_path.exists():
        with open(output_path) as f:
            existing_data = json.load(f)
        existing_components = existing_data.get("components", [])
        existing_ids = {c["id"] for c in existing_components}
        print(f"  Resuming: {len(existing_ids)} samples already processed")
        print()

    # Process samples
    components = list(existing_components)
    total = len(stl_files)
    new_count = 0
    fail_count = 0
    quality_issues_count = 0

    print(f"Processing {total} samples...")
    print("-" * 70)

    for i, stl_path in enumerate(stl_files):
        sample_id = stl_path.stem

        if sample_id in existing_ids:
            print(f"  [{i+1:3d}/{total}] SKIP (resume): {sample_id}")
            continue

        print(f"  [{i+1:3d}/{total}] {sample_id[:50]}...", end=" ", flush=True)

        try:
            component = process_single_sample(
                sample_id, stl_path, png_dir, client, args.dataset_name
            )

            if component:
                components.append(component)
                new_count += 1

                # Track quality issues
                qr = component.get("quality_report", {})
                if qr.get("views_rejected"):
                    quality_issues_count += 1

                caption_preview = component["prompt"][:55]
                print(f"OK - \"{caption_preview}...\"")
            else:
                fail_count += 1
                print("SKIP")

        except Exception as e:
            fail_count += 1
            print(f"FAIL: {e}")
            traceback.print_exc()

        # Save checkpoint every 10 samples
        if (i + 1) % 10 == 0:
            _save_checkpoint(components, args.dataset_name, output_path)

        # Rate limiting (API calls)
        time.sleep(0.5)

    # Assign tiers via composite complexity score
    print("\nComputing complexity scores and assigning tiers...")
    components = assign_tiers(components)

    tier_counts = {}
    scores = []
    for c in components:
        tier = c.get("tier", "Unknown")
        tier_counts[tier] = tier_counts.get(tier, 0) + 1
        scores.append(c.get("complexity_score", 0))

    for tier, count in sorted(tier_counts.items()):
        print(f"  {tier}: {count}")

    if scores:
        print(f"  Score range: [{min(scores):.1f}, {max(scores):.1f}], "
              f"median={np.median(scores):.1f}")

    # Save final JSON
    ground_truth = {
        "version": "2.0",
        "dataset": args.dataset_name,
        "total": len(components),
        "vision_model": VISION_MODEL,
        "temperature": VISION_TEMPERATURE,
        "prompt_variants_available": ["descriptive", "reconstructable", "program_hint"],
        "components": components,
    }

    with open(output_path, "w") as f:
        json.dump(ground_truth, f, indent=2)

    # Also generate prompts-only JSON (compatible with benchmark runners)
    # Includes all 3 variants per sample
    prompts_path = output_path.parent / f"{args.dataset_name}_prompts.json"
    prompts_data = {
        "version": "2.0",
        "dataset": args.dataset_name,
        "total": len(components),
        "prompt_variants_available": ["descriptive", "reconstructable", "program_hint"],
        "prompts": [
            {
                "id": c["id"],
                "prompt": c["prompt"],  # default = descriptive
                "prompt_variants": c.get("prompt_variants", {}),
                "family": c["component_family"],
                "tier": c.get("tier", ""),
            }
            for c in components
        ],
    }

    with open(prompts_path, "w") as f:
        json.dump(prompts_data, f, indent=2)

    # Summary
    print(f"\n{'=' * 70}")
    print("RESULTS:")
    print(f"  Total processed:    {len(components)}")
    print(f"  New captions:       {new_count}")
    print(f"  Failed/skipped:     {fail_count}")
    print(f"  Quality warnings:   {quality_issues_count} (had rejected views)")
    print(f"  Prompt variants:    3 per sample (descriptive, reconstructable, program_hint)")
    print(f"  Ground truth:       {output_path}")
    print(f"  Prompts JSON:       {prompts_path}")
    print(f"""
{'=' * 70}
NEXT STEP:
  python ext_step3_run_benchmark.py \\
      --benchmark-json "{output_path}" \\
      --dataset-name {args.dataset_name}

  # Optional: test different prompt variants
  python ext_step3_run_benchmark.py \\
      --benchmark-json "{output_path}" \\
      --dataset-name {args.dataset_name} \\
      --prompt-type reconstructable
{'=' * 70}""")


def _save_checkpoint(components, dataset_name, output_path):
    """Save intermediate checkpoint."""
    data = {
        "version": "2.0",
        "dataset": dataset_name,
        "total": len(components),
        "components": components,
    }
    with open(output_path, "w") as f:
        json.dump(data, f, indent=2)


if __name__ == "__main__":
    main()
