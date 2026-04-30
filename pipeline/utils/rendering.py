"""
CRAFT Rendering Utilities

This module provides utilities for:
- Standard camera setups (10 views: 6 ortho + 4 iso)
- Batch rendering from multiple viewpoints
- View comparison for evaluation
"""

import os
import subprocess
import tempfile
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


# =============================================================================
# STANDARD CAMERA CONFIGURATIONS
# =============================================================================

@dataclass
class CameraConfig:
    """Camera configuration for OpenSCAD rendering."""
    name: str
    # Camera position and orientation
    # Format: eye_x,eye_y,eye_z,center_x,center_y,center_z
    # Or: translate_x,translate_y,translate_z,rot_x,rot_y,rot_z,distance
    camera_string: str
    description: str


# Distance factor (D) - will be scaled based on model size
# These use the translate,rotation,distance format
STANDARD_VIEWS: Dict[str, CameraConfig] = {
    # Orthographic views (rotation angles to face each direction)
    "front": CameraConfig(
        name="front",
        camera_string="0,0,0,0,0,0,{D}",  # Looking at front (Y-)
        description="Front view (Y-)"
    ),
    "back": CameraConfig(
        name="back",
        camera_string="0,0,0,0,0,180,{D}",  # Looking at back (Y+)
        description="Back view (Y+)"
    ),
    "left": CameraConfig(
        name="left",
        camera_string="0,0,0,0,0,90,{D}",  # Looking from left (X-)
        description="Left view (X-)"
    ),
    "right": CameraConfig(
        name="right",
        camera_string="0,0,0,0,0,-90,{D}",  # Looking from right (X+)
        description="Right view (X+)"
    ),
    "top": CameraConfig(
        name="top",
        camera_string="0,0,0,90,0,0,{D}",  # Looking from top (Z+)
        description="Top view (Z+)"
    ),
    "bottom": CameraConfig(
        name="bottom",
        camera_string="0,0,0,-90,0,0,{D}",  # Looking from bottom (Z-)
        description="Bottom view (Z-)"
    ),
    # Isometric views (45° rotations)
    "iso1": CameraConfig(
        name="iso1",
        camera_string="0,0,0,55,0,45,{D}",  # Front-right-top
        description="Isometric view 1 (front-right-top)"
    ),
    "iso2": CameraConfig(
        name="iso2",
        camera_string="0,0,0,55,0,135,{D}",  # Back-right-top
        description="Isometric view 2 (back-right-top)"
    ),
    "iso3": CameraConfig(
        name="iso3",
        camera_string="0,0,0,55,0,225,{D}",  # Back-left-top
        description="Isometric view 3 (back-left-top)"
    ),
    "iso4": CameraConfig(
        name="iso4",
        camera_string="0,0,0,55,0,315,{D}",  # Front-left-top
        description="Isometric view 4 (front-left-top)"
    ),
}

# Standard view order
ORTHO_VIEWS = ["front", "back", "left", "right", "top", "bottom"]
ISO_VIEWS = ["iso1", "iso2", "iso3", "iso4"]
ALL_VIEWS = ORTHO_VIEWS + ISO_VIEWS


# =============================================================================
# MULTI-VIEW RENDERER
# =============================================================================

class MultiViewRenderer:
    """
    Renders a model from multiple standardized viewpoints.
    
    Used for:
    - Generating evaluation comparison images
    - Creating training data views
    """
    
    def __init__(
        self,
        imgsize: Tuple[int, int] = (400, 400),
        distance: float = 200,
        colorscheme: str = "Tomorrow",
        timeout: int = 30,
        fn_override: Optional[int] = None,
    ):
        """
        Initialize the renderer.

        Args:
            imgsize: Output image size per view
            distance: Camera distance (D factor)
            colorscheme: OpenSCAD color scheme
            timeout: Render timeout per view
            fn_override: CRAFT v2.1 two-pass rendering. When set, injects
                ``-D '$fn=N'`` on the OpenSCAD command line. Iteration
                renders inside the VLM/component loops pass a low value
                (e.g. 32) for fast previews; the final user-facing render
                leaves this ``None`` so the SCAD's own ``$fn`` wins.
        """
        self.imgsize = imgsize
        self.distance = distance
        self.colorscheme = colorscheme
        self.timeout = timeout
        self.fn_override = fn_override
    
    def render_all_views(
        self,
        scad_path: str,
        output_dir: str,
        prefix: str = "view",
        views: Optional[List[str]] = None
    ) -> Dict[str, str]:
        """
        Render model from all standard viewpoints.
        
        Args:
            scad_path: Path to .scad file
            output_dir: Directory for output images
            prefix: Filename prefix
            views: List of view names (default: all 10)
            
        Returns:
            Dict mapping view names to output paths
        """
        os.makedirs(output_dir, exist_ok=True)
        
        if views is None:
            views = ALL_VIEWS
        
        results = {}
        
        for view_name in views:
            if view_name not in STANDARD_VIEWS:
                continue
            
            config = STANDARD_VIEWS[view_name]
            output_path = os.path.join(output_dir, f"{prefix}_{view_name}.png")
            
            success = self._render_view(scad_path, output_path, config)
            
            if success:
                results[view_name] = output_path
        
        return results
    
    def render_stl_views(
        self,
        stl_path: str,
        output_dir: str,
        prefix: str = "stl",
        views: Optional[List[str]] = None
    ) -> Dict[str, str]:
        """
        Render STL file from all standard viewpoints.

        Creates a temporary .scad file that imports the STL.

        Args:
            stl_path: Path to .stl file
            output_dir: Directory for output images
            prefix: Filename prefix
            views: List of view names

        Returns:
            Dict mapping view names to output paths
        """
        # Create temporary .scad that imports the STL
        scad_content = f'import("{os.path.abspath(stl_path)}");'
        
        with tempfile.NamedTemporaryFile(
            mode='w',
            suffix='.scad',
            delete=False
        ) as f:
            f.write(scad_content)
            temp_scad = f.name
        
        try:
            return self.render_all_views(temp_scad, output_dir, prefix, views)
        finally:
            # Clean up temp file
            if os.path.exists(temp_scad):
                os.remove(temp_scad)
    
    def _render_view(
        self,
        scad_path: str,
        output_path: str,
        config: CameraConfig
    ) -> bool:
        """Render a single view."""
        # Format camera string with distance
        camera_str = config.camera_string.format(D=self.distance)

        # Use --viewall to automatically fit the entire model in view.
        # This is critical for larger/complex models that would otherwise
        # appear blank with a fixed camera distance.
        # --autocenter centers the model, --viewall adjusts zoom to fit.
        cmd = [
            "openscad",
            "-o", output_path,
            f"--imgsize={self.imgsize[0]},{self.imgsize[1]}",
            "--preview",
            "--colorscheme", self.colorscheme,
            "--autocenter",  # Auto-center the model
            "--viewall",     # Auto-zoom to fit entire model in view
            "--camera", camera_str,
        ]

        # CRAFT v2.1 two-pass rendering: iteration renders use a lower $fn
        # to keep the VLM/component-verifier loops fast. The final
        # user-facing render leaves fn_override as None so the SCAD's own
        # $fn wins and the output is high-fidelity.
        if self.fn_override is not None:
            cmd.extend(["-D", f"$fn={int(self.fn_override)}"])

        cmd.append(scad_path)

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=self.timeout
            )

            success = (
                result.returncode == 0 and
                os.path.exists(output_path) and
                os.path.getsize(output_path) > 0
            )

            if not success and result.stderr:
                print(f"[Render] Error rendering {config.name}: {result.stderr[:200]}")

            return success

        except Exception as e:
            print(f"[Render] Exception rendering {config.name}: {e}")
            return False


# =============================================================================
# VIEW COMPARISON UTILITIES
# =============================================================================

def compare_view_images(
    original_dir: str,
    generated_dir: str,
    views: Optional[List[str]] = None,
    original_prefix: str = "original",
    generated_prefix: str = "generated"
) -> Dict[str, Dict[str, float]]:
    """
    Compare original and generated view images.
    
    Args:
        original_dir: Directory with original view images
        generated_dir: Directory with generated view images
        views: List of view names to compare
        original_prefix: Filename prefix for originals
        generated_prefix: Filename prefix for generated
        
    Returns:
        Dict mapping view names to metric dicts
    """
    from .metrics import compute_ssim, compute_silhouette_iou
    
    if views is None:
        views = ALL_VIEWS
    
    results = {}
    
    for view_name in views:
        original_path = os.path.join(original_dir, f"{original_prefix}_{view_name}.png")
        generated_path = os.path.join(generated_dir, f"{generated_prefix}_{view_name}.png")
        
        if not os.path.exists(original_path) or not os.path.exists(generated_path):
            continue
        
        results[view_name] = {
            "ssim": compute_ssim(original_path, generated_path),
            "iou": compute_silhouette_iou(original_path, generated_path)
        }
    
    return results


def aggregate_view_metrics(
    view_results: Dict[str, Dict[str, float]]
) -> Dict[str, float]:
    """
    Aggregate metrics across all views.
    
    Args:
        view_results: Dict from compare_view_images
        
    Returns:
        Dict with mean metrics
    """
    if not view_results:
        return {"ssim_mean": 0.0, "iou_mean": 0.0}
    
    ssim_values = [r["ssim"] for r in view_results.values() if "ssim" in r]
    iou_values = [r["iou"] for r in view_results.values() if "iou" in r]
    
    return {
        "ssim_mean": sum(ssim_values) / len(ssim_values) if ssim_values else 0.0,
        "iou_mean": sum(iou_values) / len(iou_values) if iou_values else 0.0,
        "view_count": len(view_results)
    }


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

def render_standard_views(
    scad_path: str,
    output_dir: str,
    prefix: str = "view"
) -> Dict[str, str]:
    """
    Convenience function to render all 10 standard views.
    
    Args:
        scad_path: Path to .scad file
        output_dir: Output directory
        prefix: Filename prefix
        
    Returns:
        Dict mapping view names to paths
    """
    renderer = MultiViewRenderer()
    return renderer.render_all_views(scad_path, output_dir, prefix)


def get_view_names() -> List[str]:
    """Get list of all standard view names."""
    return ALL_VIEWS.copy()


def get_ortho_view_names() -> List[str]:
    """Get list of orthographic view names."""
    return ORTHO_VIEWS.copy()


def get_iso_view_names() -> List[str]:
    """Get list of isometric view names."""
    return ISO_VIEWS.copy()
