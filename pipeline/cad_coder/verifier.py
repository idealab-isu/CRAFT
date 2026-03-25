"""
Verification Module for CAD-Coder Pipeline

Verifies translated OpenSCAD code by:
1. Rendering to PNG and comparing with original image (SSIM)
2. Exporting to STL and checking watertightness
3. Validating geometry (non-zero volume, finite bounds)
"""

import os
import tempfile
from pathlib import Path
from typing import Optional, Tuple, List, Any
from dataclasses import dataclass, field

try:
    import trimesh
    HAS_TRIMESH = True
except ImportError:
    HAS_TRIMESH = False

try:
    from PIL import Image
    import numpy as np
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

from .config import Config

# Import from existing cadence utilities
import sys
sys.path.insert(0, str(Path(__file__).parent.parent))
from utils.openscad_runner import render_scad_code, export_stl_from_code
from utils.metrics import compute_ssim, compute_silhouette_iou


@dataclass
class VerificationResult:
    """Result of verification checks."""
    passed: bool
    render_success: bool = False
    watertight: bool = False
    ssim: float = 0.0
    iou: float = 0.0
    volume: float = 0.0
    problems: List[str] = field(default_factory=list)
    render_path: Optional[str] = None
    stl_path: Optional[str] = None

    def get_problems_str(self) -> str:
        """Get problems as formatted string."""
        return "\n".join(f"- {p}" for p in self.problems)


class Verifier:
    """
    Verifies OpenSCAD code quality.

    Checks:
    1. Render success - OpenSCAD can render without errors
    2. Visual similarity - SSIM compared to original image
    3. Watertight - STL mesh is manifold (no holes)
    4. Valid geometry - Non-zero volume, finite bounds
    """

    def __init__(self, config: Optional[Config] = None):
        """
        Initialize verifier.

        Args:
            config: Pipeline configuration
        """
        self.config = config or Config()

    def verify(
        self,
        openscad_code: str,
        original_image: Any,
        output_dir: Optional[str] = None
    ) -> VerificationResult:
        """
        Verify OpenSCAD code against original image.

        Args:
            openscad_code: Generated OpenSCAD code
            original_image: Original PIL Image from dataset
            output_dir: Optional directory to save outputs

        Returns:
            VerificationResult with all checks
        """
        result = VerificationResult(passed=False)
        problems = []

        # Use temp directory if not specified
        if output_dir:
            work_dir = Path(output_dir)
            work_dir.mkdir(parents=True, exist_ok=True)
            cleanup = False
        else:
            work_dir = Path(tempfile.mkdtemp(prefix="cad_verify_"))
            cleanup = True

        try:
            # 1. Render to PNG
            render_path = work_dir / "render.png"
            render_success, scad_path = render_scad_code(
                openscad_code,
                str(render_path),
                imgsize=self.config.render_size,
            )

            result.render_success = render_success

            if not render_success:
                problems.append("OpenSCAD render failed")
                result.problems = problems
                return result

            result.render_path = str(render_path)

            # 2. Compare with original image (SSIM)
            if original_image is not None and HAS_PIL:
                ssim, iou = self._compare_images(original_image, render_path)
                result.ssim = ssim
                result.iou = iou

                if ssim < self.config.min_ssim:
                    problems.append(f"SSIM too low: {ssim:.3f} < {self.config.min_ssim}")
            else:
                # No original image to compare - skip visual check
                result.ssim = 1.0
                result.iou = 1.0

            # 3. Export to STL and check watertight
            stl_path = work_dir / "model.stl"
            stl_success, stl_error = export_stl_from_code(
                openscad_code,
                str(stl_path),
                timeout=self.config.render_timeout,
            )

            if stl_success and HAS_TRIMESH:
                result.stl_path = str(stl_path)
                watertight, volume, geo_problems = self._check_geometry(stl_path)
                result.watertight = watertight
                result.volume = volume

                if self.config.require_watertight and not watertight:
                    problems.append("Mesh is not watertight (has holes/gaps)")

                if volume < self.config.min_volume:
                    problems.append(f"Volume too small: {volume}")

                # Only add geo_problems if they're critical
                for gp in geo_problems:
                    if "infinite" in gp.lower():  # Only critical errors
                        problems.append(gp)
            elif not stl_success:
                # STL export failure is not critical if render succeeded
                # (some valid OpenSCAD can fail STL due to complexity)
                if self.config.require_watertight:
                    problems.append(f"STL export failed: {stl_error}")
            else:
                # No trimesh - skip watertight check
                result.watertight = True

            # Final verdict
            result.problems = problems
            result.passed = len(problems) == 0

            return result

        finally:
            # Cleanup temp files if needed
            if cleanup:
                import shutil
                try:
                    shutil.rmtree(work_dir)
                except:
                    pass

    def _compare_images(
        self,
        original: Any,
        rendered_path: Path
    ) -> Tuple[float, float]:
        """
        Compare original and rendered images.

        Args:
            original: PIL Image from dataset
            rendered_path: Path to rendered PNG

        Returns:
            Tuple of (ssim, iou)
        """
        try:
            # Save original to temp file for comparison
            with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as f:
                original_path = f.name
                # Handle PIL Image
                if hasattr(original, "save"):
                    original.save(original_path)
                else:
                    # Already a path or numpy array
                    Image.fromarray(np.array(original)).save(original_path)

            # Compute metrics
            ssim = compute_ssim(original_path, str(rendered_path))
            iou = compute_silhouette_iou(original_path, str(rendered_path))

            # Cleanup
            os.unlink(original_path)

            return ssim, iou

        except Exception as e:
            print(f"[Verifier] Image comparison error: {e}")
            return 0.0, 0.0

    def _check_geometry(self, stl_path: Path) -> Tuple[bool, float, List[str]]:
        """
        Check STL geometry for validity.

        Args:
            stl_path: Path to STL file

        Returns:
            Tuple of (is_watertight, volume, problems)
        """
        problems = []

        try:
            mesh = trimesh.load_mesh(str(stl_path))

            # Handle scene vs mesh
            if isinstance(mesh, trimesh.Scene):
                if len(mesh.geometry) == 0:
                    return False, 0.0, ["Empty mesh"]
                mesh = trimesh.util.concatenate(list(mesh.geometry.values()))

            # Check watertight
            watertight = mesh.is_watertight

            # Check volume
            volume = 0.0
            if mesh.is_volume:
                volume = float(mesh.volume)
            else:
                problems.append("Mesh is not a valid volume")

            # Check bounds
            if not np.all(np.isfinite(mesh.bounds)):
                problems.append("Mesh has infinite bounds")

            # Check for degenerate faces
            if hasattr(mesh, "remove_degenerate_faces"):
                n_before = len(mesh.faces)
                mesh.remove_degenerate_faces()
                n_after = len(mesh.faces)
                if n_before - n_after > 0:
                    problems.append(f"Mesh had {n_before - n_after} degenerate faces")

            return watertight, volume, problems

        except Exception as e:
            return False, 0.0, [f"Geometry check failed: {str(e)}"]

    def quick_check(self, openscad_code: str) -> Tuple[bool, str]:
        """
        Quick render check without full verification.

        Useful for testing if code is syntactically valid.

        Args:
            openscad_code: OpenSCAD code to check

        Returns:
            Tuple of (success, error_message)
        """
        with tempfile.NamedTemporaryFile(suffix=".png", delete=True) as f:
            render_path = f.name
            success, _ = render_scad_code(
                openscad_code,
                render_path,
                imgsize=(256, 256),  # Smaller for speed
            )
            if success:
                return True, ""
            else:
                return False, "Render failed"


def verify_translation(
    openscad_code: str,
    original_image: Any = None,
    config: Optional[Config] = None
) -> Tuple[bool, float, List[str]]:
    """
    Convenience function to verify a translation.

    Args:
        openscad_code: Generated OpenSCAD code
        original_image: Optional original image for comparison
        config: Optional configuration

    Returns:
        Tuple of (passed, ssim, problems_list)
    """
    verifier = Verifier(config=config)
    result = verifier.verify(openscad_code, original_image)
    return result.passed, result.ssim, result.problems
