#!/usr/bin/env python3
"""
Debug script to test CAD-Coder pipeline components individually.
"""

import sys
from pathlib import Path

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

def test_loader(dataset_path: str):
    """Test loading samples from dataset."""
    print("\n=== Testing Loader ===")
    from cadence.cad_coder.loader import GenCADLoader

    try:
        loader = GenCADLoader(dataset_path)
        info = loader.info()
        print(f"Dataset info: {info}")

        # Load one sample
        samples = loader.load_samples(split="train", n=1)
        if samples:
            sample = samples[0]
            print(f"\nSample 0:")
            print(f"  deepcad_id: {sample.deepcad_id}")
            print(f"  image: {type(sample.image)} - {sample.image}")
            print(f"  code length: {len(sample.cadquery_code)} chars")
            print(f"  code preview: {sample.cadquery_code[:200]}...")
            return sample
    except Exception as e:
        print(f"Loader error: {e}")
        import traceback
        traceback.print_exc()
    return None


def test_translator(cadquery_code: str):
    """Test translation."""
    print("\n=== Testing Translator ===")
    import os
    if not os.getenv("OPENAI_API_KEY"):
        print("OPENAI_API_KEY not set, skipping translator test")
        return None

    from cadence.cad_coder.llm_translator import LLMTranslator
    from cadence.cad_coder.config import Config

    try:
        config = Config()
        translator = LLMTranslator(config=config)

        print(f"Translating {len(cadquery_code)} chars of CadQuery code...")
        result = translator.translate(cadquery_code)

        print(f"  Success: {result.success}")
        print(f"  Error: {result.error}")
        print(f"  OpenSCAD length: {len(result.openscad_code)} chars")
        if result.openscad_code:
            print(f"  OpenSCAD preview:\n{result.openscad_code[:500]}...")
        return result.openscad_code if result.success else None
    except Exception as e:
        print(f"Translator error: {e}")
        import traceback
        traceback.print_exc()
    return None


def test_render(openscad_code: str):
    """Test OpenSCAD rendering."""
    print("\n=== Testing Render ===")
    import tempfile
    import subprocess

    # Check if OpenSCAD is installed
    try:
        result = subprocess.run(["openscad", "--version"], capture_output=True, text=True)
        print(f"OpenSCAD version: {result.stdout.strip() or result.stderr.strip()}")
    except FileNotFoundError:
        print("ERROR: OpenSCAD not found! Please install it.")
        return None

    from cadence.utils.openscad_runner import render_scad_code, export_stl_from_code

    try:
        with tempfile.TemporaryDirectory() as tmpdir:
            render_path = f"{tmpdir}/test.png"
            stl_path = f"{tmpdir}/test.stl"

            # Test render
            print(f"Rendering to {render_path}...")
            success, scad_path = render_scad_code(openscad_code, render_path, imgsize=(448, 448))
            print(f"  Render success: {success}")
            print(f"  Scad path: {scad_path}")

            if success:
                import os
                size = os.path.getsize(render_path)
                print(f"  PNG size: {size} bytes")

            # Test STL export
            print(f"\nExporting STL to {stl_path}...")
            stl_success, stl_error = export_stl_from_code(openscad_code, stl_path)
            print(f"  STL success: {stl_success}")
            print(f"  STL error: {stl_error}")

            if stl_success:
                size = os.path.getsize(stl_path)
                print(f"  STL size: {size} bytes")

                # Check watertight
                try:
                    import trimesh
                    mesh = trimesh.load_mesh(stl_path)
                    print(f"  Watertight: {mesh.is_watertight}")
                    print(f"  Volume: {mesh.volume if mesh.is_volume else 'N/A'}")
                except ImportError:
                    print("  trimesh not installed, skipping watertight check")

            return success
    except Exception as e:
        print(f"Render error: {e}")
        import traceback
        traceback.print_exc()
    return None


def test_image_comparison(original_image, render_path: str):
    """Test image comparison."""
    print("\n=== Testing Image Comparison ===")

    if original_image is None:
        print("No original image to compare")
        return

    from cadence.utils.metrics import compute_ssim, compute_silhouette_iou
    import tempfile
    from PIL import Image

    try:
        # Save original to temp file
        with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
            original_path = f.name
            if hasattr(original_image, "save"):
                original_image.save(original_path)
                print(f"Original image: {original_image.size}, mode={original_image.mode}")
            else:
                print(f"Original image type: {type(original_image)}")
                return

        # Load rendered
        rendered = Image.open(render_path)
        print(f"Rendered image: {rendered.size}, mode={rendered.mode}")

        # Compute metrics
        ssim = compute_ssim(original_path, render_path)
        iou = compute_silhouette_iou(original_path, render_path)

        print(f"  SSIM: {ssim:.3f}")
        print(f"  IoU: {iou:.3f}")

        import os
        os.unlink(original_path)

    except Exception as e:
        print(f"Comparison error: {e}")
        import traceback
        traceback.print_exc()


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Debug CAD-Coder pipeline")
    parser.add_argument("--dataset", "-d", required=True, help="Path to GenCAD-Code/data")
    parser.add_argument("--skip-translate", action="store_true", help="Skip translation (use test code)")
    args = parser.parse_args()

    # Test loader
    sample = test_loader(args.dataset)
    if not sample:
        print("\nLoader failed, cannot continue")
        return

    # Test translator
    if args.skip_translate:
        # Use simple test code
        openscad_code = """
$fn = 32;
difference() {
    cube([10, 10, 10], center=true);
    cylinder(h=12, r=3, center=true);
}
"""
        print("\n=== Using test OpenSCAD code (skipping translation) ===")
    else:
        openscad_code = test_translator(sample.cadquery_code)
        if not openscad_code:
            print("\nTranslator failed, using test code instead")
            openscad_code = """
$fn = 32;
cube([10, 10, 10], center=true);
"""

    # Test render
    import tempfile
    with tempfile.TemporaryDirectory() as tmpdir:
        render_path = f"{tmpdir}/render.png"

        from cadence.utils.openscad_runner import render_scad_code
        success, _ = render_scad_code(openscad_code, render_path, imgsize=(448, 448))

        if success:
            test_render(openscad_code)
            test_image_comparison(sample.image, render_path)
        else:
            print("\nRender failed!")
            test_render(openscad_code)


if __name__ == "__main__":
    main()
