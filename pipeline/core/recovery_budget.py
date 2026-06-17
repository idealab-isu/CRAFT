"""
Shared recovery budget for CRAFT's layered error recovery.

The paper claims a "fixed 10-attempt budget across the five layers." This
module gives that claim a single, real, enforceable counter rather than five
independent per-layer caps that happen to sum to ~10. Every recovery layer
charges this object before retrying, and queries `can_retry()` before
incrementing its own loop counter.

Usage:
    budget = RecoveryBudget(total_attempts=10)
    if budget.can_retry("vlm_correction"):
        budget.charge("vlm_correction")
        ...do the retry...

    # at the end of a pipeline run, dump telemetry:
    state.recovery_budget = budget.to_dict()
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Dict, List


# The five recovery layers, in the order the paper describes them.
LAYERS = (
    "schema_repair",          # Layer 1
    "scad_autofix",           # Layer 2
    "vlm_correction",         # Layer 3
    "component_verification", # Layer 4
    "manual_repair",          # Layer 5
)


@dataclass
class RecoveryBudget:
    """Single shared attempt budget across all recovery layers."""

    total_attempts: int = 10
    used: int = 0
    per_layer_used: Dict[str, int] = field(default_factory=lambda: {l: 0 for l in LAYERS})
    per_layer_triggered: Dict[str, bool] = field(default_factory=lambda: {l: False for l in LAYERS})
    per_layer_succeeded: Dict[str, bool] = field(default_factory=lambda: {l: False for l in LAYERS})
    event_log: List[Dict] = field(default_factory=list)

    # ---- public API -------------------------------------------------------

    def remaining(self) -> int:
        return max(0, self.total_attempts - self.used)

    def can_retry(self, layer: str) -> bool:
        """Return True iff the budget allows at least one more attempt."""
        self._check_layer(layer)
        return self.remaining() > 0

    def charge(self, layer: str, *, note: str = "") -> None:
        """Charge one attempt to the given layer."""
        self._check_layer(layer)
        self.used += 1
        self.per_layer_used[layer] += 1
        self.per_layer_triggered[layer] = True
        self.event_log.append({
            "layer": layer,
            "attempt_number": self.used,
            "note": note,
        })

    def mark_succeeded(self, layer: str) -> None:
        """Flag that this layer ultimately recovered from a failure."""
        self._check_layer(layer)
        self.per_layer_succeeded[layer] = True

    def trigger_rate(self, n_runs: int) -> Dict[str, float]:
        """Aggregate helper — only meaningful when combined across runs."""
        if n_runs <= 0:
            return {l: 0.0 for l in LAYERS}
        return {l: int(self.per_layer_triggered[l]) / n_runs for l in LAYERS}

    # ---- serialization ---------------------------------------------------

    def to_dict(self) -> Dict:
        return {
            "total_attempts": self.total_attempts,
            "used": self.used,
            "remaining": self.remaining(),
            "per_layer_used": dict(self.per_layer_used),
            "per_layer_triggered": dict(self.per_layer_triggered),
            "per_layer_succeeded": dict(self.per_layer_succeeded),
            "event_log": list(self.event_log),
        }

    @classmethod
    def from_dict(cls, d: Dict) -> "RecoveryBudget":
        b = cls(total_attempts=d.get("total_attempts", 10))
        b.used = d.get("used", 0)
        b.per_layer_used = {l: d.get("per_layer_used", {}).get(l, 0) for l in LAYERS}
        b.per_layer_triggered = {l: d.get("per_layer_triggered", {}).get(l, False) for l in LAYERS}
        b.per_layer_succeeded = {l: d.get("per_layer_succeeded", {}).get(l, False) for l in LAYERS}
        b.event_log = list(d.get("event_log", []))
        return b

    # ---- internals -------------------------------------------------------

    def _check_layer(self, layer: str) -> None:
        if layer not in LAYERS:
            raise ValueError(f"Unknown recovery layer {layer!r}; expected one of {LAYERS}")
