"""
DEPRECATED — CRAFT v2 stub.

The v1 deterministic validator (~584 LOC) was a pre-VLM fallback path kept
around as dead weight. In v2 it is replaced by:

  - `core.render_checks` for the single useful signal it carried
    (non-blank render detection + bracket sanity).
  - The Phase B unified-feedback stage for everything else.

This file is retained as a thin re-export so legacy imports keep working
during the v2 transition. New code must import from
`core.render_checks` directly.
"""

from __future__ import annotations

import warnings

from .render_checks import (  # noqa: F401  (re-exports)
    CheckResult,
    ValidationResult,
    Validator,
    check_renders_non_blank,
    validate_scad,
    VALIDATION_WEIGHTS,
    PASS_THRESHOLD,
)

warnings.warn(
    "core.validator is deprecated in CRAFT v2; import from core.render_checks "
    "(or use the Phase B unified-feedback stage).",
    DeprecationWarning,
    stacklevel=2,
)


def check_syntax(code: str, scad_path=None) -> CheckResult:  # pragma: no cover
    """Legacy shim. v2 no longer shells out to OpenSCAD for syntax; we
    only balance brackets. Kept so legacy callers don't crash."""
    from .render_checks import _check_brackets
    return _check_brackets(code)


def check_geometry_sanity(code: str) -> CheckResult:  # pragma: no cover
    """Legacy shim; v2 drops heuristic geometry checks."""
    return CheckResult(
        passed=True,
        message="geometry sanity check dropped in v2",
        weight=0.0,
        score=1.0,
    )


def check_heuristic_coverage(
    code: str, expected_parts=None, prompt: str = ""
) -> CheckResult:  # pragma: no cover
    """Legacy shim; v2 drops regex-based coverage heuristics in favor of
    acceptance-criteria predicates (Phase B, Stage 1)."""
    return CheckResult(
        passed=True,
        message="heuristic coverage dropped in v2",
        weight=0.0,
        score=1.0,
    )


__all__ = [
    "CheckResult",
    "ValidationResult",
    "Validator",
    "check_renders_non_blank",
    "validate_scad",
    "check_syntax",
    "check_geometry_sanity",
    "check_heuristic_coverage",
    "VALIDATION_WEIGHTS",
    "PASS_THRESHOLD",
]
