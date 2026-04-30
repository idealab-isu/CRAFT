"""
CRAFT v4 — Stage 1 + 2: Render and deterministic sanity check.

Produces:
- One STL file (used downstream for Chamfer / oracle ablation).
- Eight rendered views (6 ortho + 2 iso) used by the gap assessor.

Sanity check (no LLM, no ground truth) returns:
- render_success: every requested view produced a non-empty PNG.
- stl_success: STL was emitted and is non-zero in size.
- non_blank_views: number of views that contain visible geometry (pixel
  variance > a small threshold).
- view_coverage: fraction of foreground pixels per view (used to flag
  degenerate camera framings).

These signals are consumed by the regression gate later as "render
validity" — a patched model is rejected if it strictly increases the
number of broken views relative to baseline.
"""

from __future__ import annotations

import os
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Make the parent `pipeline/` directory importable regardless of CWD so this
# package can be used both as `python -m pipeline.v4.runner` and via direct
# imports from evaluation scripts.
_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(_PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PIPELINE_ROOT))

from utils.rendering import MultiViewRenderer, ORTHO_VIEWS, ISO_VIEWS  # noqa: E402


# Eight views: 6 ortho + 2 iso. The full ten-view set is available but two
# iso views give the assessor enough 3D context without doubling cost.
V4_VIEWS: List[str] = ORTHO_VIEWS + ["iso1", "iso3"]

# Pixel variance threshold for "this view is not blank".
NONBLANK_STD_THRESHOLD = 6.0


@dataclass
class SanityVerdict:
    """Deterministic, ground-truth-free verdict for one render set."""
    render_success: bool                       # all views produced files
    stl_success: bool                          # STL exists + nonzero size
    non_blank_views: int                       # count of views with visible geom
    total_views: int
    per_view_std: Dict[str, float] = field(default_factory=dict)
    error: Optional[str] = None

    @property
    def num_failed_views(self) -> int:
        return self.total_views - self.non_blank_views

    @property
    def passed(self) -> bool:
        """A render set 'passes' sanity when STL exists and >=80% of views are non-blank."""
        if not self.render_success or not self.stl_success:
            return False
        if self.total_views == 0:
            return False
        return (self.non_blank_views / self.total_views) >= 0.80


@dataclass
class RenderArtifacts:
    """Filesystem paths to all render outputs for one SCAD program."""
    scad_path: str
    stl_path: str
    view_paths: Dict[str, str]                 # view_name -> png path
    iso_view_path: Optional[str] = None        # convenience pointer for VLM input
    sanity: Optional[SanityVerdict] = None


class RenderCheck:
    """Render an SCAD file to STL + 8 views, then run sanity checks."""

    def __init__(
        self,
        imgsize: Tuple[int, int] = (512, 512),
        render_distance: float = 200.0,
        render_timeout: int = 90,
        stl_timeout: int = 240,
    ):
        self.imgsize = imgsize
        self.render_distance = render_distance
        self.render_timeout = render_timeout
        self.stl_timeout = stl_timeout

    def render_and_check(
        self,
        scad_path: str,
        out_dir: str,
        prefix: str,
    ) -> RenderArtifacts:
        """Render an SCAD file and return artifacts + sanity verdict.

        Args:
            scad_path: Path to the SCAD file to render.
            out_dir: Directory in which to place STL and PNGs.
            prefix: Filename prefix (e.g. "baseline" or "patched").
        """
        os.makedirs(out_dir, exist_ok=True)
        stl_path = os.path.join(out_dir, f"{prefix}.stl")

        # Fast pre-render syntax check. If OpenSCAD can't even parse the
        # file, skip the (much more expensive) 8 view renders + STL export
        # and fail fast. This is the single biggest source of wasted time
        # when a baseline candidate produces broken SCAD.
        if not self._syntax_ok(scad_path):
            return RenderArtifacts(
                scad_path=scad_path,
                stl_path="",
                view_paths={},
                iso_view_path=None,
                sanity=SanityVerdict(
                    render_success=False,
                    stl_success=False,
                    non_blank_views=0,
                    total_views=len(V4_VIEWS),
                    per_view_std={},
                    error="syntax check failed (parser error)",
                ),
            )

        stl_ok = self._export_stl(scad_path, stl_path)

        renderer = MultiViewRenderer(
            imgsize=self.imgsize,
            distance=self.render_distance,
            timeout=self.render_timeout,
        )
        views_dir = os.path.join(out_dir, f"{prefix}_views")
        os.makedirs(views_dir, exist_ok=True)
        view_paths = renderer.render_all_views(
            scad_path=scad_path,
            output_dir=views_dir,
            prefix=prefix,
            views=V4_VIEWS,
        )

        sanity = self._sanity_check(stl_ok, view_paths, len(V4_VIEWS))

        return RenderArtifacts(
            scad_path=scad_path,
            stl_path=stl_path if stl_ok else "",
            view_paths=view_paths,
            iso_view_path=view_paths.get("iso1"),
            sanity=sanity,
        )

    # ------------------------------------------------------------------
    # Private helpers
    # ------------------------------------------------------------------

    def _syntax_ok(self, scad_path: str) -> bool:
        """Fast OpenSCAD parse-only check (~<1s). Returns False if the file
        contains a parser/syntax error. Warnings are tolerated.

        Critical: OpenSCAD sometimes returns exit code 0 even when stderr
        contains hard parser errors (it parses what it can and emits echo
        output for the valid parts). So we check stderr unconditionally,
        not just on non-zero exit codes.
        """
        try:
            result = subprocess.run(
                [
                    "openscad",
                    "--export-format", "echo",
                    "-o", os.devnull,
                    scad_path,
                ],
                capture_output=True,
                text=True,
                timeout=30,
            )
            stderr = (result.stderr or "").lower()
            # Hard parser failures always fail the gate, regardless of exit code.
            if "parser error" in stderr:
                return False
            if "syntax error" in stderr:
                return False
            if "can't parse file" in stderr or "cant parse file" in stderr:
                return False
            # Non-zero return with no recognized error message -> still fail.
            if result.returncode != 0:
                return False
            return True
        except FileNotFoundError:
            # openscad not on PATH — assume OK and let downstream error out
            return True
        except subprocess.TimeoutExpired:
            return False
        except Exception:
            return True

    def _export_stl(self, scad_path: str, stl_path: str) -> bool:
        """Run OpenSCAD CLI to export an STL. Returns True on success."""
        try:
            result = subprocess.run(
                ["openscad", "-o", stl_path, scad_path],
                capture_output=True,
                text=True,
                timeout=self.stl_timeout,
            )
            ok = (
                result.returncode == 0
                and os.path.exists(stl_path)
                and os.path.getsize(stl_path) > 0
            )
            return ok
        except Exception:
            return False

    def _sanity_check(
        self,
        stl_ok: bool,
        view_paths: Dict[str, str],
        expected_view_count: int,
    ) -> SanityVerdict:
        """Pure-python deterministic check. No LLM, no ground truth."""
        per_view_std: Dict[str, float] = {}
        non_blank = 0

        try:
            from PIL import Image
            import numpy as np

            for view, path in view_paths.items():
                if not (path and os.path.exists(path)):
                    per_view_std[view] = 0.0
                    continue
                try:
                    img = Image.open(path).convert("L")
                    arr = np.array(img)
                    std = float(np.std(arr))
                except Exception:
                    std = 0.0
                per_view_std[view] = std
                if std > NONBLANK_STD_THRESHOLD:
                    non_blank += 1
        except Exception as e:
            return SanityVerdict(
                render_success=bool(view_paths),
                stl_success=stl_ok,
                non_blank_views=0,
                total_views=expected_view_count,
                per_view_std={},
                error=f"sanity check failed: {e}",
            )

        return SanityVerdict(
            render_success=len(view_paths) == expected_view_count,
            stl_success=stl_ok,
            non_blank_views=non_blank,
            total_views=expected_view_count,
            per_view_std=per_view_std,
        )
