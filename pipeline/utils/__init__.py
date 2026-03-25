"""
CRAFT Utilities

Contains helper modules:
- openscad_runner: Execute OpenSCAD rendering
- rendering: Multi-view rendering utilities
- metrics: Image comparison metrics (SSIM, IoU, etc.)
"""

from .openscad_runner import (
    OpenScadRunner,
    RenderMode,
    render_scad,
    render_scad_code
)

from .rendering import (
    CameraConfig,
    MultiViewRenderer,
    STANDARD_VIEWS,
    ALL_VIEWS,
    ORTHO_VIEWS,
    ISO_VIEWS,
    render_standard_views,
    compare_view_images,
    aggregate_view_metrics,
    get_view_names,
    get_ortho_view_names,
    get_iso_view_names
)

from .metrics import (
    compute_ssim,
    compute_silhouette_iou,
    compute_mse,
    compute_psnr,
    compute_all_metrics,
    compute_mean_metrics,
    load_image_grayscale,
    load_image_rgb,
    to_silhouette
)

__all__ = [
    # OpenSCAD Runner
    "OpenScadRunner",
    "RenderMode",
    "render_scad",
    "render_scad_code",
    # Rendering
    "CameraConfig",
    "MultiViewRenderer",
    "STANDARD_VIEWS",
    "ALL_VIEWS",
    "ORTHO_VIEWS",
    "ISO_VIEWS",
    "render_standard_views",
    "compare_view_images",
    "aggregate_view_metrics",
    "get_view_names",
    "get_ortho_view_names",
    "get_iso_view_names",
    # Metrics
    "compute_ssim",
    "compute_silhouette_iou",
    "compute_mse",
    "compute_psnr",
    "compute_all_metrics",
    "compute_mean_metrics",
    "load_image_grayscale",
    "load_image_rgb",
    "to_silhouette",
]
