"""
CRAFT Render Checks (v2, Phase A replacement for validator.py / repair.py)

Minimal deterministic sanity checks used inside the pipeline. The v1
`core/validator.py` (584 LOC) and `core/repair.py` (641 LOC) were a
pre-VLM fallback path that is effectively dead in production. CRAFT v2
replaces all substantive validation and repair with the unified-feedback
loop (Phase B).

This module preserves only what the live pipeline still needs from the
old validator:

  - `CheckResult` / `ValidationResult` dataclasses (for API compatibility)
  - `check_renders_non_blank()` — used by `visual_corrector.py` to catch
    blank renders before the VLM can hallucinate approval on them
  - A lightweight `Validator` class with the same `.validate(...)` signature
    as v1 but doing only renders-non-blank + basic bracket balance. It is
    used as a transitional shim so existing call sites (`app.py`,
    `visual_corrector.py`, legacy eval scripts) keep working until Phase B
    rewires them into the unified-feedback stage.

Intentionally **no LLM calls**, **no heuristic-coverage logic**, **no
repair logic**. Everything here is deterministic and ~120 LOC.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field, asdict
from typing import Any, Dict, List, Optional

import numpy as np
from PIL import Image


# -----------------------------------------------------------------------------
# Weights / thresholds (retained so callers that read them keep working)
# -----------------------------------------------------------------------------

VALIDATION_WEIGHTS: Dict[str, float] = {
    "syntax": 0.50,
    "renders": 0.50,
}

PASS_THRESHOLD: float = 0.80


# -----------------------------------------------------------------------------
# Result dataclasses (API-compatible with v1 validator)
# -----------------------------------------------------------------------------

@dataclass
class CheckResult:
    """Result of a single validation check."""
    passed: bool
    message: str
    weight: float
    score: float = 0.0

    def __post_init__(self) -> None:
        if self.score == 0.0:
            self.score = 1.0 if self.passed else 0.0


@dataclass
class ValidationResult:
    """Complete validation result (legacy-compatible)."""
    score: int
    passed: bool
    checks: Dict[str, CheckResult] = field(default_factory=dict)
    issues: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "score": self.score,
            "passed": self.passed,
            "checks": {k: asdict(v) for k, v in self.checks.items()},
            "issues": self.issues,
        }


# -----------------------------------------------------------------------------
# Bracket / syntax sanity (no OpenSCAD subprocess — fast)
# -----------------------------------------------------------------------------

def _check_brackets(code: str) -> CheckResult:
    """Balanced-bracket check. Deliberately tolerant (comments/strings are
    stripped by simple regex; good enough for a blank-render gate)."""
    if not code or not code.strip():
        return CheckResult(
            passed=False,
            message="Empty code",
            weight=VALIDATION_WEIGHTS["syntax"],
        )

    pairs = {"{": "}", "[": "]", "(": ")"}
    closing = {v: k for k, v in pairs.items()}
    stack: List[str] = []
    in_line_comment = False
    in_block_comment = False
    in_string = False
    prev = ""
    for ch in code:
        if in_line_comment:
            if ch == "\n":
                in_line_comment = False
            prev = ch
            continue
        if in_block_comment:
            if prev == "*" and ch == "/":
                in_block_comment = False
            prev = ch
            continue
        if in_string:
            if ch == '"' and prev != "\\":
                in_string = False
            prev = ch
            continue
        if prev == "/" and ch == "/":
            in_line_comment = True
            prev = ch
            continue
        if prev == "/" and ch == "*":
            in_block_comment = True
            prev = ch
            continue
        if ch == '"':
            in_string = True
            prev = ch
            continue
        if ch in pairs:
            stack.append(ch)
        elif ch in closing:
            if not stack or stack[-1] != closing[ch]:
                return CheckResult(
                    passed=False,
                    message=f"Unmatched '{ch}'",
                    weight=VALIDATION_WEIGHTS["syntax"],
                )
            stack.pop()
        prev = ch

    if stack:
        return CheckResult(
            passed=False,
            message=f"Unclosed '{stack[-1]}'",
            weight=VALIDATION_WEIGHTS["syntax"],
        )
    return CheckResult(
        passed=True,
        message="Brackets balanced",
        weight=VALIDATION_WEIGHTS["syntax"],
    )


# -----------------------------------------------------------------------------
# Render blank-detection (used by visual_corrector to veto VLM approval
# on degenerate images; this is the single most important deterministic
# signal retained from v1)
# -----------------------------------------------------------------------------

def check_renders_non_blank(img_path: Optional[str]) -> CheckResult:
    """Return pass=True iff the rendered image has visible geometry."""
    if not img_path or not os.path.exists(img_path):
        return CheckResult(
            passed=False,
            message="Image file not found",
            weight=VALIDATION_WEIGHTS["renders"],
        )

    try:
        img = Image.open(img_path)
        arr = np.array(img)

        if arr.ndim == 3:
            if arr.shape[2] == 4:
                gray = np.mean(arr[:, :, :3], axis=2)
            else:
                gray = np.mean(arr, axis=2)
        else:
            gray = arr

        std_dev = float(np.std(gray))
        unique_values = int(len(np.unique(gray.astype(np.uint8))))

        if std_dev < 1.0:
            return CheckResult(
                passed=False,
                message=f"Image appears uniform (std={std_dev:.2f})",
                weight=VALIDATION_WEIGHTS["renders"],
            )
        if unique_values < 10:
            return CheckResult(
                passed=False,
                message=f"Image has too few colors ({unique_values})",
                weight=VALIDATION_WEIGHTS["renders"],
            )

        # Optional edge-density refinement
        try:
            from scipy import ndimage  # type: ignore

            edges = np.abs(ndimage.sobel(gray, axis=0)) + np.abs(
                ndimage.sobel(gray, axis=1)
            )
            edge_density = float(np.sum(edges > 20) / edges.size)
            if edge_density < 0.001:
                return CheckResult(
                    passed=False,
                    message=f"No visible geometry (edge density={edge_density:.4f})",
                    weight=VALIDATION_WEIGHTS["renders"],
                )
            return CheckResult(
                passed=True,
                message=f"Image OK (edge density={edge_density:.2%})",
                weight=VALIDATION_WEIGHTS["renders"],
            )
        except ImportError:
            if std_dev > 5.0 and unique_values > 20:
                return CheckResult(
                    passed=True,
                    message=f"Image has content (std={std_dev:.1f}, colors={unique_values})",
                    weight=VALIDATION_WEIGHTS["renders"],
                )
            return CheckResult(
                passed=False,
                message="Image may be blank or nearly blank",
                weight=VALIDATION_WEIGHTS["renders"],
            )
    except Exception as e:  # pragma: no cover - defensive
        return CheckResult(
            passed=False,
            message=f"Render check failed: {str(e)[:64]}",
            weight=VALIDATION_WEIGHTS["renders"],
        )


# -----------------------------------------------------------------------------
# Minimal Validator shim
# -----------------------------------------------------------------------------

class Validator:
    """Deterministic shim retained for v1-era callers.

    v2's real validation lives in the unified-feedback stage (Phase B).
    This class intentionally only performs:

      1. Bracket-balance check on the SCAD source.
      2. Non-blank render check on the provided image, if any.

    Heuristic-coverage and geometry-sanity checks from v1 were ad-hoc
    regex matching that didn't carry a signal worth keeping for v2.
    """

    def __init__(self, pass_threshold: float = PASS_THRESHOLD) -> None:
        self.pass_threshold = pass_threshold

    def validate(
        self,
        code: str,
        expected_parts: Optional[List[str]] = None,
        prompt: str = "",
        scad_path: Optional[str] = None,
        img_path: Optional[str] = None,
    ) -> ValidationResult:
        checks: Dict[str, CheckResult] = {}
        issues: List[str] = []

        checks["syntax"] = _check_brackets(code)
        if not checks["syntax"].passed:
            issues.append(f"Syntax: {checks['syntax'].message}")

        if img_path:
            checks["renders"] = check_renders_non_blank(img_path)
        else:
            checks["renders"] = CheckResult(
                passed=False,
                message="No render available",
                weight=VALIDATION_WEIGHTS["renders"],
                score=0.0,
            )
        if not checks["renders"].passed:
            issues.append(f"Render: {checks['renders'].message}")

        total = sum(c.score * c.weight for c in checks.values())
        score_100 = int(round(total * 100))
        passed = total >= self.pass_threshold

        return ValidationResult(
            score=score_100,
            passed=passed,
            checks=checks,
            issues=issues,
        )


def validate_scad(
    code: str,
    expected_parts: Optional[List[str]] = None,
    prompt: str = "",
    scad_path: Optional[str] = None,
    img_path: Optional[str] = None,
    pass_threshold: float = PASS_THRESHOLD,
) -> ValidationResult:
    """Functional convenience wrapper."""
    return Validator(pass_threshold).validate(
        code=code,
        expected_parts=expected_parts or [],
        prompt=prompt,
        scad_path=scad_path,
        img_path=img_path,
    )


# -----------------------------------------------------------------------------
# Render-quality gate (CRAFT v2, Phase B.7)
#
# Deterministic, multi-view quality gate that runs after Stage 5. Looks at
# every view image and reports per-view + aggregate metrics. Stage 5 uses
# ``passed`` to decide whether to trust the render, drop the candidate, or
# re-render with different camera parameters. Intentionally threshold-driven
# and LLM-free.
# -----------------------------------------------------------------------------

@dataclass
class ViewQuality:
    """Per-view deterministic quality metrics."""
    view_name: str
    image_path: str
    ok: bool
    coverage: float            # fraction of foreground (non-background) pixels
    std_dev: float             # pixel intensity spread
    aspect_ratio: float        # image W/H
    bbox_fill: float           # foreground bbox area / image area
    issues: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class QualityGateResult:
    """Aggregate render-quality decision for a multi-view render batch."""
    passed: bool
    views: List[ViewQuality] = field(default_factory=list)
    mean_coverage: float = 0.0
    coverage_spread: float = 0.0     # max - min across views
    failures: List[str] = field(default_factory=list)

    def to_dict(self) -> Dict[str, Any]:
        return {
            "passed": self.passed,
            "views": [v.to_dict() for v in self.views],
            "mean_coverage": self.mean_coverage,
            "coverage_spread": self.coverage_spread,
            "failures": self.failures,
        }

    def summary(self) -> str:
        return (
            f"gate={'PASS' if self.passed else 'FAIL'} "
            f"views={len(self.views)} "
            f"mean_cov={self.mean_coverage:.2%} "
            f"spread={self.coverage_spread:.2%} "
            f"failures={self.failures or 'none'}"
        )


# Default thresholds — tuned on v1 data; callers may override.
QUALITY_GATE_DEFAULTS: Dict[str, float] = {
    "min_coverage": 0.02,          # >=2% foreground pixels
    "max_coverage": 0.85,          # <=85% foreground (otherwise it's a solid block)
    "min_std_dev": 5.0,            # intensity spread (avoid flat images)
    "min_bbox_fill": 0.01,         # tightest bbox covers >=1% of the frame
    "min_aspect": 0.5,             # image W/H sanity
    "max_aspect": 2.5,
    "max_coverage_spread": 0.60,   # multi-view consistency cap
    "background_tolerance": 12.0,  # pixel-distance to the inferred background
}


def _score_single_view(
    view_name: str,
    image_path: str,
    thresholds: Dict[str, float],
) -> ViewQuality:
    issues: List[str] = []
    if not image_path or not os.path.exists(image_path):
        return ViewQuality(
            view_name=view_name, image_path=image_path or "",
            ok=False, coverage=0.0, std_dev=0.0,
            aspect_ratio=0.0, bbox_fill=0.0,
            issues=["image file not found"],
        )

    try:
        img = Image.open(image_path)
        arr = np.array(img)
    except Exception as e:
        return ViewQuality(
            view_name=view_name, image_path=image_path, ok=False,
            coverage=0.0, std_dev=0.0, aspect_ratio=0.0, bbox_fill=0.0,
            issues=[f"cannot read image: {str(e)[:64]}"],
        )

    if arr.ndim == 3:
        gray = np.mean(arr[:, :, :3], axis=2)
    else:
        gray = arr.astype(np.float32)

    h, w = gray.shape[:2]
    aspect = (w / h) if h else 0.0
    std_dev = float(np.std(gray))

    # Infer background from corners (render tool usually uses solid bg).
    corners = np.concatenate([
        gray[:4, :4].ravel(), gray[:4, -4:].ravel(),
        gray[-4:, :4].ravel(), gray[-4:, -4:].ravel(),
    ])
    bg_val = float(np.median(corners))
    fg_mask = np.abs(gray - bg_val) > thresholds["background_tolerance"]
    coverage = float(fg_mask.mean())

    # Bounding box of foreground
    if fg_mask.any():
        rows = np.any(fg_mask, axis=1)
        cols = np.any(fg_mask, axis=0)
        r0, r1 = np.argmax(rows), len(rows) - 1 - np.argmax(rows[::-1])
        c0, c1 = np.argmax(cols), len(cols) - 1 - np.argmax(cols[::-1])
        bbox_fill = ((r1 - r0 + 1) * (c1 - c0 + 1)) / float(h * w)
    else:
        bbox_fill = 0.0

    if coverage < thresholds["min_coverage"]:
        issues.append(f"coverage too low ({coverage:.2%})")
    if coverage > thresholds["max_coverage"]:
        issues.append(f"coverage saturated ({coverage:.2%})")
    if std_dev < thresholds["min_std_dev"]:
        issues.append(f"image too flat (std={std_dev:.2f})")
    if bbox_fill < thresholds["min_bbox_fill"]:
        issues.append(f"subject bbox too small ({bbox_fill:.2%})")
    if aspect < thresholds["min_aspect"] or aspect > thresholds["max_aspect"]:
        issues.append(f"unusual aspect ratio ({aspect:.2f})")

    return ViewQuality(
        view_name=view_name,
        image_path=image_path,
        ok=not issues,
        coverage=coverage,
        std_dev=std_dev,
        aspect_ratio=aspect,
        bbox_fill=bbox_fill,
        issues=issues,
    )


def render_quality_gate(
    image_paths: Dict[str, str],
    thresholds: Optional[Dict[str, float]] = None,
    required_min_pass_fraction: float = 0.75,
) -> QualityGateResult:
    """
    Run the v2 render-quality gate across a set of view images.

    Args:
        image_paths: mapping of ``view_name -> image path`` (front/top/iso/…).
        thresholds: optional overrides for ``QUALITY_GATE_DEFAULTS``.
        required_min_pass_fraction: fraction of views that must pass
            individually for the gate to return ``passed=True``.

    Returns:
        :class:`QualityGateResult` with per-view metrics and a pass/fail
        verdict that Stage 5 can act on.
    """
    cfg = dict(QUALITY_GATE_DEFAULTS)
    if thresholds:
        cfg.update(thresholds)

    views: List[ViewQuality] = []
    for name, path in image_paths.items():
        views.append(_score_single_view(name, path, cfg))

    coverages = [v.coverage for v in views if v.coverage > 0]
    mean_cov = float(np.mean(coverages)) if coverages else 0.0
    cov_spread = float(max(coverages) - min(coverages)) if coverages else 0.0

    failures: List[str] = []
    if not views:
        failures.append("no views supplied")
    passed_views = sum(1 for v in views if v.ok)
    if views and passed_views / max(len(views), 1) < required_min_pass_fraction:
        failures.append(
            f"only {passed_views}/{len(views)} views passed "
            f"(need {required_min_pass_fraction:.0%})"
        )
    if cov_spread > cfg["max_coverage_spread"]:
        failures.append(
            f"multi-view coverage spread too high "
            f"({cov_spread:.2%} > {cfg['max_coverage_spread']:.0%})"
        )

    result = QualityGateResult(
        passed=not failures,
        views=views,
        mean_coverage=mean_cov,
        coverage_spread=cov_spread,
        failures=failures,
    )
    print(f"[RenderQualityGate] {result.summary()}")
    return result


__all__ = [
    "CheckResult",
    "ValidationResult",
    "Validator",
    "check_renders_non_blank",
    "validate_scad",
    "VALIDATION_WEIGHTS",
    "PASS_THRESHOLD",
    # v2 Phase B.7
    "ViewQuality",
    "QualityGateResult",
    "QUALITY_GATE_DEFAULTS",
    "render_quality_gate",
]
