"""
NopSCADlib Component Renderer

Renders reference images for components in the knowledge base.
Generates multiple views (front, top, isometric) for each component.
"""

import os
import subprocess
import tempfile
import shutil
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed

from .config import KB_CONFIG, NOPSCADLIB_DIR, REFERENCE_IMAGES_DIR
from .indexer import ComponentInfo


@dataclass
class CameraConfig:
    """Camera configuration for OpenSCAD rendering."""
    name: str
    translate: Tuple[float, float, float]  # eye position
    rotate: Tuple[float, float, float]     # rotation angles
    distance: float = 500                   # camera distance

    def to_openscad_args(self) -> str:
        """Convert to OpenSCAD camera argument string."""
        tx, ty, tz = self.translate
        rx, ry, rz = self.rotate
        return f"{tx},{ty},{tz},{rx},{ry},{rz},{self.distance}"


# Standard view configurations
STANDARD_VIEWS = {
    "front": CameraConfig(
        name="front",
        translate=(0, 0, 0),
        rotate=(90, 0, 0),
        distance=500
    ),
    "back": CameraConfig(
        name="back",
        translate=(0, 0, 0),
        rotate=(90, 0, 180),
        distance=500
    ),
    "left": CameraConfig(
        name="left",
        translate=(0, 0, 0),
        rotate=(90, 0, 90),
        distance=500
    ),
    "right": CameraConfig(
        name="right",
        translate=(0, 0, 0),
        rotate=(90, 0, -90),
        distance=500
    ),
    "top": CameraConfig(
        name="top",
        translate=(0, 0, 0),
        rotate=(0, 0, 0),
        distance=500
    ),
    "bottom": CameraConfig(
        name="bottom",
        translate=(0, 0, 0),
        rotate=(180, 0, 0),
        distance=500
    ),
    "iso1": CameraConfig(
        name="iso1",
        translate=(0, 0, 0),
        rotate=(55, 0, 45),
        distance=500
    ),
    "iso2": CameraConfig(
        name="iso2",
        translate=(0, 0, 0),
        rotate=(55, 0, 135),
        distance=500
    ),
    "iso3": CameraConfig(
        name="iso3",
        translate=(0, 0, 0),
        rotate=(55, 0, 225),
        distance=500
    ),
    "iso4": CameraConfig(
        name="iso4",
        translate=(0, 0, 0),
        rotate=(55, 0, 315),
        distance=500
    ),
}


class ComponentRenderer:
    """
    Renders reference images for NopSCADlib components.
    """

    def __init__(
        self,
        nopscadlib_dir: Path = None,
        output_dir: Path = None,
        openscad_path: str = "openscad"
    ):
        self.nopscadlib_dir = nopscadlib_dir or NOPSCADLIB_DIR
        self.output_dir = output_dir or REFERENCE_IMAGES_DIR
        self.openscad_path = openscad_path

        # Ensure output directory exists
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def create_render_script(
        self,
        component: ComponentInfo,
        output_path: Path
    ) -> str:
        """
        Create a temporary OpenSCAD script that renders a component.

        This handles the NopSCADlib include structure.
        """
        # Build include paths
        includes = []

        # Add the component's own includes
        for inc in component.includes:
            includes.append(f'include <{inc}>')
        for use in component.uses:
            includes.append(f'use <{use}>')

        # Create the render script
        script = f"""
// Auto-generated render script for {component.name}
// Component ID: {component.id}

// Set library path
$fa = 1;
$fs = 0.4;

// Include the component file
include <{component.source_file}>

// Render the component
{component.module_name}();
"""
        return script

    def render_component_view(
        self,
        component: ComponentInfo,
        view_name: str,
        size: Tuple[int, int] = None
    ) -> Optional[Path]:
        """
        Render a single view of a component.

        Args:
            component: Component to render
            view_name: Name of the view (front, top, iso1, etc.)
            size: Output image size (width, height)

        Returns:
            Path to rendered image, or None if failed
        """
        size = size or KB_CONFIG.render_size
        view_config = STANDARD_VIEWS.get(view_name)
        if not view_config:
            print(f"Unknown view: {view_name}")
            return None

        # Create output path
        component_dir = self.output_dir / component.id
        component_dir.mkdir(parents=True, exist_ok=True)
        output_path = component_dir / f"{view_name}.png"

        # Create temporary script with rotation baked in for the view
        with tempfile.NamedTemporaryFile(
            mode='w',
            suffix='.scad',
            delete=False,
            dir=str(self.nopscadlib_dir)  # Important: run from NopSCADlib dir
        ) as f:
            # Bake rotation into the script instead of using camera args
            rx, ry, rz = view_config.rotate
            script = f"""
// Auto-generated render script for {component.name}
// Component ID: {component.id}
// View: {view_name}

$fa = 1;
$fs = 0.4;

// Include the component file
include <{component.source_file}>

// Apply view rotation
rotate([{rx}, {ry}, {rz}])
    {component.module_name}();
"""
            f.write(script)
            temp_script = f.name

        try:
            # Build OpenSCAD command - use simple args that work across versions
            cmd = [
                self.openscad_path,
                "-o", str(output_path),
                f"--imgsize={size[0]},{size[1]}",
                "--autocenter",  # Auto-center the view
                "--viewall",     # Auto-fit to view
                temp_script
            ]

            # Run OpenSCAD
            # Use longer timeout for complex components (some NopSCADlib components are very complex)
            result = subprocess.run(
                cmd,
                capture_output=True,
                timeout=120,  # 120 second timeout per render (increased for complex components)
                cwd=str(self.nopscadlib_dir)  # Run from NopSCADlib directory
            )

            if result.returncode == 0 and output_path.exists():
                return output_path
            else:
                stderr = result.stderr.decode('utf-8', errors='ignore')
                stdout = result.stdout.decode('utf-8', errors='ignore')
                # Check if it's a usage error (bad args)
                if "Usage:" in stderr or "Usage:" in stdout:
                    print(f"OpenSCAD error for {component.id}/{view_name}: Invalid arguments")
                elif stderr and ("ERROR" in stderr or "error" in stderr.lower()):
                    print(f"OpenSCAD error for {component.id}/{view_name}: {stderr[:200]}")
                else:
                    print(f"OpenSCAD error for {component.id}/{view_name}: Render failed")
                return None

        except subprocess.TimeoutExpired:
            print(f"  ⚠ Timeout rendering {component.id}/{view_name} (component may be too complex)")
            # Kill the process if it's still running
            try:
                result.kill()
            except:
                pass
            return None
        except FileNotFoundError:
            print(f"OpenSCAD not found at '{self.openscad_path}'. Please install OpenSCAD.")
            return None
        except Exception as e:
            print(f"Error rendering {component.id}/{view_name}: {e}")
            return None
        finally:
            # Clean up temp script
            try:
                os.unlink(temp_script)
            except:
                pass

    def render_component(
        self,
        component: ComponentInfo,
        views: List[str] = None
    ) -> Dict[str, Optional[Path]]:
        """
        Render all views for a component.

        Args:
            component: Component to render
            views: List of view names (default: from config)

        Returns:
            Dictionary mapping view name to image path (or None if failed)
        """
        views = views or KB_CONFIG.render_views
        results = {}

        for view_name in views:
            results[view_name] = self.render_component_view(component, view_name)

        return results

    def render_all_components(
        self,
        components: Dict[str, ComponentInfo],
        views: List[str] = None,
        max_workers: int = 4,
        skip_existing: bool = True
    ) -> Dict[str, Dict[str, Optional[Path]]]:
        """
        Render reference images for all components.

        Args:
            components: Dictionary of component ID to ComponentInfo
            views: List of view names to render
            max_workers: Number of parallel render workers
            skip_existing: Skip components that already have images

        Returns:
            Dictionary mapping component ID to view results
        """
        views = views or KB_CONFIG.render_views
        results = {}
        total = len(components)

        print(f"\nRendering {total} components with {len(views)} views each...")

        # Process components
        processed = 0
        failed = 0

        for comp_id, component in components.items():
            processed += 1

            # Check if already rendered
            if skip_existing:
                component_dir = self.output_dir / comp_id
                if component_dir.exists():
                    existing_views = list(component_dir.glob("*.png"))
                    if len(existing_views) >= len(views):
                        results[comp_id] = {
                            v: component_dir / f"{v}.png"
                            for v in views
                            if (component_dir / f"{v}.png").exists()
                        }
                        continue

            print(f"[{processed}/{total}] Rendering {component.name}...")

            try:
                view_results = self.render_component(component, views)
                results[comp_id] = view_results

                # Check if any views succeeded
                success_count = sum(1 for v in view_results.values() if v is not None)
                failed_count = len(views) - success_count
                if success_count == 0:
                    failed += 1
                    print(f"  ✗ Failed: No views rendered")
                elif failed_count > 0:
                    print(f"  ⚠ Partial: {success_count}/{len(views)} views (some timed out or failed)")
                else:
                    print(f"  ✓ Success: {success_count}/{len(views)} views")

            except Exception as e:
                print(f"  Error: {e}")
                failed += 1
                results[comp_id] = {}

        print(f"\nRendering complete: {total - failed}/{total} components successful")
        return results

    def get_reference_images(
        self,
        component_id: str,
        views: List[str] = None
    ) -> Dict[str, Optional[Path]]:
        """
        Get paths to existing reference images for a component.

        Args:
            component_id: Component ID
            views: List of view names (default: from config)

        Returns:
            Dictionary mapping view name to image path (or None if not found)
        """
        views = views or KB_CONFIG.render_views
        component_dir = self.output_dir / component_id

        results = {}
        for view_name in views:
            image_path = component_dir / f"{view_name}.png"
            results[view_name] = image_path if image_path.exists() else None

        return results

    def component_has_images(self, component_id: str, min_views: int = 1) -> bool:
        """Check if a component has at least min_views rendered images."""
        component_dir = self.output_dir / component_id
        if not component_dir.exists():
            return False

        image_count = len(list(component_dir.glob("*.png")))
        return image_count >= min_views

    def get_render_statistics(self) -> Dict:
        """Get statistics about rendered components."""
        total_components = 0
        rendered_components = 0
        total_images = 0

        for component_dir in self.output_dir.iterdir():
            if component_dir.is_dir():
                total_components += 1
                images = list(component_dir.glob("*.png"))
                if images:
                    rendered_components += 1
                    total_images += len(images)

        return {
            "total_component_dirs": total_components,
            "rendered_components": rendered_components,
            "total_images": total_images,
            "avg_views_per_component": total_images / rendered_components if rendered_components > 0 else 0
        }


def render_component_references(
    components: Dict[str, ComponentInfo],
    views: List[str] = None,
    skip_existing: bool = True
) -> Dict[str, Dict[str, Optional[Path]]]:
    """
    Convenience function to render reference images for components.

    Args:
        components: Dictionary of components to render
        views: List of view names
        skip_existing: Skip already rendered components

    Returns:
        Dictionary of render results
    """
    renderer = ComponentRenderer()
    return renderer.render_all_components(
        components,
        views=views,
        skip_existing=skip_existing
    )


def get_component_images(component_id: str) -> Dict[str, Optional[Path]]:
    """Get reference images for a specific component."""
    renderer = ComponentRenderer()
    return renderer.get_reference_images(component_id)
