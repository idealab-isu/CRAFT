#!/usr/bin/env python3
"""
Render Knowledge Base Reference Images

This script pre-renders reference images for all KB components.
These images are used in VLM correction and component verification.

Usage:
    python scripts/render_kb_references.py [options]

Options:
    --skip-existing    Skip components that already have images
    --views VIEWS      Comma-separated list of views (default: front,back,left,right,top,bottom)
    --max-workers N    Number of parallel workers (default: 4)
"""

import sys
import os
import argparse
from pathlib import Path

# Add cadence to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from kb.indexer import load_component_index
from kb.renderer import ComponentRenderer, STANDARD_VIEWS
from kb.config import KB_CONFIG, REFERENCE_IMAGES_DIR


def main():
    parser = argparse.ArgumentParser(
        description="Render reference images for KB components"
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip components that already have images"
    )
    parser.add_argument(
        "--views",
        type=str,
        default="front,back,left,right,top,bottom",
        help="Comma-separated list of views to render"
    )
    parser.add_argument(
        "--max-workers",
        type=int,
        default=4,
        help="Number of parallel workers (not used in current implementation)"
    )
    parser.add_argument(
        "--component-id",
        type=str,
        help="Render only a specific component ID"
    )

    args = parser.parse_args()

    # Parse views
    view_names = [v.strip() for v in args.views.split(",")]
    
    # Validate views
    invalid_views = [v for v in view_names if v not in STANDARD_VIEWS]
    if invalid_views:
        print(f"Error: Invalid view names: {invalid_views}")
        print(f"Valid views: {', '.join(STANDARD_VIEWS.keys())}")
        return 1

    # Load components
    print("Loading component index...")
    components = load_component_index()
    
    if not components:
        print("Error: No components found. Run build_knowledge_base.py first.")
        return 1

    print(f"Loaded {len(components)} components")

    # Filter to specific component if requested
    if args.component_id:
        if args.component_id not in components:
            print(f"Error: Component '{args.component_id}' not found")
            return 1
        components = {args.component_id: components[args.component_id]}

    # Initialize renderer
    renderer = ComponentRenderer(
        nopscadlib_dir=KB_CONFIG.nopscadlib_dir,
        output_dir=REFERENCE_IMAGES_DIR
    )

    # Render all components
    print(f"\nRendering {len(view_names)} views for {len(components)} components...")
    print(f"Output directory: {REFERENCE_IMAGES_DIR}")
    print(f"Views: {', '.join(view_names)}\n")

    results = renderer.render_all_components(
        components,
        views=view_names,
        max_workers=args.max_workers,
        skip_existing=args.skip_existing
    )

    # Print statistics
    total_rendered = 0
    total_failed = 0
    for comp_id, view_results in results.items():
        rendered = sum(1 for v in view_results.values() if v is not None)
        failed = len(view_results) - rendered
        total_rendered += rendered
        total_failed += failed

    print(f"\n{'='*60}")
    print(f"RENDERING COMPLETE")
    print(f"{'='*60}")
    print(f"Total views rendered: {total_rendered}")
    print(f"Total views failed: {total_failed}")
    print(f"Components processed: {len(results)}")

    # Get final statistics
    stats = renderer.get_render_statistics()
    print(f"\nReference image statistics:")
    print(f"  Component directories: {stats['total_component_dirs']}")
    print(f"  Components with images: {stats['rendered_components']}")
    print(f"  Total images: {stats['total_images']}")
    print(f"  Avg views per component: {stats['avg_views_per_component']:.1f}")

    return 0 if total_failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())

