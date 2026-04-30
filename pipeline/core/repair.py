"""
REMOVED — CRAFT v2.

The v1 `CodeRepairer` / `RepairOrchestrator` path (~641 LOC) is cut from
v2. Its job — LLM-driven code repair guided by deterministic validation —
is subsumed by Phase B's unified-feedback stage, which emits structured
RFC 6902 JSON Patch operations against the plan IR (see §3 Stage 7 of
CRAFT_v2_research_plan.md).

Keeping this module only as a placeholder so `from core.repair import ...`
fails loudly with a useful message instead of silently resolving during
the transition.
"""

from __future__ import annotations

import warnings
from dataclasses import dataclass, field
from typing import Any, Dict, List

MAX_REPAIR_ATTEMPTS = 0  # v2: repair is handled by unified feedback, not here


@dataclass
class RepairResult:
    """Stub kept for import compatibility; never produced by v2 code."""
    success: bool = False
    code: str = ""
    attempts: int = 0
    errors: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


def _deprecated(name: str) -> Any:  # pragma: no cover - defensive
    raise RuntimeError(
        f"{name} has been removed in CRAFT v2. Repair is now performed via "
        "the unified-feedback stage (see Phase B of the v2 research plan). "
        "Legacy repair entry points should be migrated or removed."
    )


class CodeRepairer:  # pragma: no cover
    def __init__(self, *args: Any, **kwargs: Any) -> None:
        warnings.warn(
            "CodeRepairer is removed in CRAFT v2; use unified feedback.",
            DeprecationWarning,
            stacklevel=2,
        )

    def repair(self, *args: Any, **kwargs: Any) -> RepairResult:
        return _deprecated("CodeRepairer.repair")


class RepairOrchestrator:  # pragma: no cover
    def __init__(self, *args: Any, **kwargs: Any) -> None:
        warnings.warn(
            "RepairOrchestrator is removed in CRAFT v2; use unified feedback.",
            DeprecationWarning,
            stacklevel=2,
        )

    def orchestrate(self, *args: Any, **kwargs: Any) -> RepairResult:
        return _deprecated("RepairOrchestrator.orchestrate")


def repair_code(*args: Any, **kwargs: Any) -> RepairResult:  # pragma: no cover
    return _deprecated("repair_code")


def quick_syntax_fix(code: str) -> str:  # pragma: no cover
    return code  # no-op in v2


def fix_zero_dimensions(code: str) -> str:  # pragma: no cover
    return code  # no-op in v2


__all__ = [
    "CodeRepairer",
    "RepairOrchestrator",
    "RepairResult",
    "repair_code",
    "quick_syntax_fix",
    "fix_zero_dimensions",
    "MAX_REPAIR_ATTEMPTS",
]
