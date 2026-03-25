"""
Configuration for CAD-Coder Pipeline

Contains all settings, thresholds, and prompts.
"""

import os
from dataclasses import dataclass, field
from typing import Optional
from pathlib import Path


@dataclass
class Config:
    """Pipeline configuration."""

    # Paths
    dataset_path: str = "GenCAD-Code/data"  # Relative to craft dir or absolute
    output_dir: str = "cad_coder_output"

    # LLM Settings
    model: str = "gpt-4o"
    temperature: float = 0.2
    max_tokens: int = 4096
    max_repair_attempts: int = 2

    # Rendering Settings
    render_size: tuple = (448, 448)  # Match original dataset
    render_view: str = "iso1"  # Isometric view
    render_timeout: int = 60

    # Verification Thresholds
    min_ssim: float = 0.50  # Minimum SSIM for visual match (lowered - different camera angles)
    require_watertight: bool = False  # Don't require watertight for pilot
    require_render: bool = True  # Require successful render
    min_volume: float = 1e-9  # Minimum valid volume

    # Processing Settings
    skip_on_failure: bool = True  # Skip failed samples in pilot
    save_intermediate: bool = True  # Save .scad files even if verification fails
    translation_only: bool = False  # Skip verification entirely (just translate)

    # System Prompt for Translation
    system_prompt: str = field(default_factory=lambda: """You are an expert CAD code translator. Convert CadQuery Python code to OpenSCAD code.

CRITICAL REQUIREMENTS:
1. Output ONLY valid OpenSCAD code - no markdown, no explanations, no comments about the translation
2. The output must be WATERTIGHT (manifold) - no gaps, no missing faces
3. Use ONLY CSG primitives: cube, cylinder, sphere, polygon, circle, linear_extrude, rotate_extrude
4. Use ONLY CSG operations: union, difference, intersection, translate, rotate, scale, mirror, multmatrix
5. Add small overlaps (EPS = 0.01) where boolean operations meet to ensure watertight result
6. Preserve all geometric features - do not simplify or remove parts

TRANSLATION PATTERNS:
- cq.Workplane("XY").box(x,y,z) → cube([x,y,z], center=true)
- .cylinder(h, r) → cylinder(h=h, r=r, center=true)
- .sphere(r) → sphere(r=r)
- .cut(shape) → difference() { base; shape; }
- .union(shape) → union() { base; shape; }
- .fillet(r) → Use minkowski with sphere for approximation, or skip if complex
- .chamfer(d) → Approximate with hull() or skip if complex
- Workplane with offset → translate([x,y,z])
- .extrude(h) → linear_extrude(height=h)

For complex fillets/chamfers that cannot be easily translated, prioritize keeping the overall shape correct over perfect edge treatment.

Output the OpenSCAD code directly, starting with any necessary variable definitions.""")

    # Repair Prompt (used when verification fails)
    repair_prompt: str = field(default_factory=lambda: """The OpenSCAD code you generated has issues. Please fix it.

PROBLEMS DETECTED:
{problems}

ORIGINAL CADQUERY CODE:
{cadquery_code}

YOUR PREVIOUS OPENSCAD OUTPUT:
{openscad_code}

Fix the issues while maintaining:
1. Watertight geometry (add EPS overlaps at boolean junctions)
2. All original features preserved
3. CSG-only operations (no CGAL-specific features)

Output ONLY the corrected OpenSCAD code.""")

    def get_dataset_path(self, base_dir: Optional[str] = None) -> Path:
        """Get absolute path to dataset."""
        if os.path.isabs(self.dataset_path):
            return Path(self.dataset_path)

        if base_dir:
            return Path(base_dir) / self.dataset_path

        # Default: relative to this file's directory
        return Path(__file__).parent.parent.parent / "craft" / self.dataset_path

    def get_output_path(self, base_dir: Optional[str] = None) -> Path:
        """Get absolute path to output directory."""
        if os.path.isabs(self.output_dir):
            return Path(self.output_dir)

        if base_dir:
            return Path(base_dir) / self.output_dir

        return Path(__file__).parent / self.output_dir
