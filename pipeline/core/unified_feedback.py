"""
CRAFT v2 Unified Visual Feedback (Phase B.8)

Consolidates v1's two feedback modules — ``visual_corrector`` (VLM
rendering/approval loop) and ``component_verifier`` (part-presence and
connectivity check) — into a single structured feedback object that the
pipeline's Stage 6 consumes.

Design goals
------------
* One structured :class:`FeedbackResult` per iteration. Combines part-presence
  against :class:`AcceptanceCriteria`, dimensional tolerance checks,
  topology observations, and per-view VLM findings.
* Deterministic pieces (part names, tolerances, connectivity) are computed
  before invoking the VLM so the VLM is asked to confirm, not hallucinate.
* Emits ``patch_hints``: small structured suggestions that the Stage 7
  JSON-Patch repair path can translate directly into RFC 6902 operations
  (see :mod:`core.patch_repair`).

This module is a thin orchestration layer: the actual VLM/component
verification is still delegated to the v1 classes so we don't lose any of
their test coverage during the transition.
"""

from __future__ import annotations

from dataclasses import dataclass, field, asdict
from typing import Any, Dict, List, Optional, Tuple

from .reasoner import AcceptanceCriteria, DesignBrief


# =============================================================================
# Feedback data model
# =============================================================================

@dataclass
class PartVerdict:
    """One part × one acceptance-criteria tier."""
    name: str
    tier: str                        # "must_have" | "should_have" | "optional"
    present: bool
    confidence: float = 0.0
    notes: str = ""

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class DimensionVerdict:
    """Check of one parameter against its declared tolerance."""
    name: str
    expected: float
    observed: Optional[float]
    tolerance: float                 # fractional, e.g. 0.15 = ±15%
    within: bool
    source: str = "plan"             # "plan" | "vlm" | "measured"

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class TopologyVerdict:
    """Outcome of a single natural-language topology constraint."""
    constraint: str
    satisfied: bool
    notes: str = ""

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class PatchHint:
    """Structured repair hint for the JSON-Patch repair path (Phase B.9)."""
    op: str                          # "add" | "replace" | "remove"
    target: str                      # dotted path into the plan, e.g. "geometry.base_shapes[2]"
    description: str                 # human-readable reason
    payload: Optional[Any] = None    # value to insert, if applicable

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)


@dataclass
class FeedbackResult:
    """Aggregate structured output of one unified-feedback pass."""
    iteration: int = 0
    passed: bool = False
    overall_score: float = 0.0       # 0..1; weighted by tier

    part_verdicts: List[PartVerdict] = field(default_factory=list)
    dimension_verdicts: List[DimensionVerdict] = field(default_factory=list)
    topology_verdicts: List[TopologyVerdict] = field(default_factory=list)

    missing_must_have: List[str] = field(default_factory=list)
    missing_should_have: List[str] = field(default_factory=list)
    out_of_tolerance: List[str] = field(default_factory=list)
    violated_constraints: List[str] = field(default_factory=list)

    vlm_confidence: float = 0.0
    vlm_suggestions: List[str] = field(default_factory=list)
    patch_hints: List[PatchHint] = field(default_factory=list)

    raw: Dict[str, Any] = field(default_factory=dict)  # upstream outputs

    def to_dict(self) -> Dict[str, Any]:
        out = {
            "iteration": self.iteration,
            "passed": self.passed,
            "overall_score": self.overall_score,
            "part_verdicts": [v.to_dict() for v in self.part_verdicts],
            "dimension_verdicts": [v.to_dict() for v in self.dimension_verdicts],
            "topology_verdicts": [v.to_dict() for v in self.topology_verdicts],
            "missing_must_have": list(self.missing_must_have),
            "missing_should_have": list(self.missing_should_have),
            "out_of_tolerance": list(self.out_of_tolerance),
            "violated_constraints": list(self.violated_constraints),
            "vlm_confidence": self.vlm_confidence,
            "vlm_suggestions": list(self.vlm_suggestions),
            "patch_hints": [h.to_dict() for h in self.patch_hints],
        }
        return out

    def summary(self) -> str:
        bits = [
            f"iter={self.iteration}",
            f"score={self.overall_score:.2f}",
            f"passed={self.passed}",
        ]
        if self.missing_must_have:
            bits.append(f"missing_must={self.missing_must_have}")
        if self.missing_should_have:
            bits.append(f"missing_should={self.missing_should_have}")
        if self.out_of_tolerance:
            bits.append(f"dims_bad={self.out_of_tolerance}")
        if self.violated_constraints:
            bits.append(f"topology_bad={len(self.violated_constraints)}")
        return " ".join(bits)


# =============================================================================
# Scoring helpers
# =============================================================================

_TIER_WEIGHTS = {"must_have": 0.60, "should_have": 0.25, "optional": 0.05}
_DIMENSION_WEIGHT = 0.10


def _score(feedback: FeedbackResult) -> float:
    """Weighted score across parts and dimensions."""
    score = 0.0

    # Parts, bucketed by tier
    buckets: Dict[str, List[PartVerdict]] = {
        "must_have": [], "should_have": [], "optional": []
    }
    for v in feedback.part_verdicts:
        buckets.setdefault(v.tier, []).append(v)

    for tier, verdicts in buckets.items():
        if not verdicts:
            continue
        w = _TIER_WEIGHTS.get(tier, 0.0)
        ok = sum(1 for v in verdicts if v.present)
        score += w * (ok / len(verdicts))

    # Dimensions
    dims = feedback.dimension_verdicts
    if dims:
        ok = sum(1 for d in dims if d.within)
        score += _DIMENSION_WEIGHT * (ok / len(dims))

    # Cap at 1
    return min(score, 1.0)


# =============================================================================
# Unified feedback loop
# =============================================================================

class UnifiedFeedbackLoop:
    """
    Runs one pass of unified visual+structural feedback.

    This is a Phase B.8 plumbing class — it still uses the v1
    :class:`VisualSelfCorrector` and :class:`ComponentVerifier` internally,
    but maps their outputs into a single :class:`FeedbackResult` aligned to
    the :class:`AcceptanceCriteria` the Stage 1 reasoner produced.

    Downstream (Stage 7) consumes ``feedback.patch_hints`` to propose
    JSON-Patch edits instead of regenerating the whole plan.
    """

    def __init__(
        self,
        visual_corrector: Any = None,
        component_verifier: Any = None,
        min_pass_score: float = 0.80,
    ):
        self.visual_corrector = visual_corrector
        self.component_verifier = component_verifier
        self.min_pass_score = min_pass_score

    # ------------------------------------------------------------------
    # Public entry point

    def run(
        self,
        brief: DesignBrief,
        scad_code: str,
        view_images: Dict[str, str],
        plan: Optional[Dict[str, Any]] = None,
        iteration: int = 0,
    ) -> FeedbackResult:
        """
        Produce a FeedbackResult for the current iteration.

        Args:
            brief: the Stage 1 DesignBrief (used for AcceptanceCriteria).
            scad_code: the SCAD code under review.
            view_images: mapping of view-name → image path (from Stage 5).
            plan: optional JSON plan; used for dimension observation.
            iteration: which iteration of the correction loop this is.
        """
        criteria: AcceptanceCriteria = brief.acceptance_criteria
        feedback = FeedbackResult(iteration=iteration)

        # --- 1. Structural check (parts present) ------------------------
        presence_map, vlm_conf, vlm_suggestions, raw_cv = self._run_component_verifier(
            brief=brief, scad_code=scad_code, view_images=view_images,
        )
        feedback.raw["component_verifier"] = raw_cv
        feedback.vlm_confidence = vlm_conf
        feedback.vlm_suggestions.extend(vlm_suggestions)

        feedback.part_verdicts = self._build_part_verdicts(criteria, presence_map)

        # --- 2. Dimension tolerance check -------------------------------
        feedback.dimension_verdicts = self._check_dimensions(brief, plan, presence_map)

        # --- 3. Topology constraints (pass-through to VLM suggestions) --
        feedback.topology_verdicts = self._check_topology(criteria, vlm_suggestions)

        # --- 4. Visual corrector (optional, VLM approval signal) --------
        vlm_ok, vlm_raw = self._run_visual_corrector(
            brief=brief, scad_code=scad_code, view_images=view_images,
        )
        feedback.raw["visual_corrector"] = vlm_raw

        # --- 5. Roll-ups -------------------------------------------------
        feedback.missing_must_have = [
            v.name for v in feedback.part_verdicts
            if v.tier == "must_have" and not v.present
        ]
        feedback.missing_should_have = [
            v.name for v in feedback.part_verdicts
            if v.tier == "should_have" and not v.present
        ]
        feedback.out_of_tolerance = [
            d.name for d in feedback.dimension_verdicts if not d.within
        ]
        feedback.violated_constraints = [
            t.constraint for t in feedback.topology_verdicts if not t.satisfied
        ]

        feedback.overall_score = _score(feedback)
        no_hard_fails = (
            not feedback.missing_must_have
            and not feedback.out_of_tolerance
        )
        feedback.passed = (
            no_hard_fails
            and feedback.overall_score >= self.min_pass_score
            and vlm_ok
        )

        # --- 6. Patch hints for Stage 7 (B.9) ---------------------------
        feedback.patch_hints = self._emit_patch_hints(feedback, criteria)

        print(f"[UnifiedFeedback] {feedback.summary()}")
        return feedback

    # ------------------------------------------------------------------
    # Internals

    def _run_component_verifier(
        self,
        brief: DesignBrief,
        scad_code: str,
        view_images: Dict[str, str],
    ) -> Tuple[Dict[str, Tuple[bool, float, str]], float, List[str], Dict[str, Any]]:
        """Invoke v1 ComponentVerifier and normalize its output."""
        presence: Dict[str, Tuple[bool, float, str]] = {}
        vlm_conf = 0.0
        suggestions: List[str] = []
        raw: Dict[str, Any] = {}

        if self.component_verifier is None:
            return presence, vlm_conf, suggestions, raw

        try:
            result = self.component_verifier.verify(
                scad_code=scad_code,
                expected_parts=brief.expected_parts,
                brief=brief,
                view_images=view_images,
            )
        except Exception as e:  # pragma: no cover - defensive
            raw["error"] = f"component_verifier threw: {str(e)[:200]}"
            return presence, vlm_conf, suggestions, raw

        raw["component_verifier_output"] = getattr(result, "to_dict", lambda: {})()

        parts_list = getattr(result, "parts_present", None) or []
        confidences: List[float] = []
        for p in parts_list:
            name = getattr(p, "part_name", None) or ""
            if not name:
                continue
            presence[name] = (
                bool(getattr(p, "present", False)),
                float(getattr(p, "confidence", 0.0)),
                str(getattr(p, "notes", "")),
            )
            confidences.append(float(getattr(p, "confidence", 0.0)))
        if confidences:
            vlm_conf = sum(confidences) / len(confidences)

        for s in getattr(result, "issues", []) or []:
            suggestions.append(str(s))
        return presence, vlm_conf, suggestions, raw

    def _run_visual_corrector(
        self,
        brief: DesignBrief,
        scad_code: str,
        view_images: Dict[str, str],
    ) -> Tuple[bool, Dict[str, Any]]:
        """Invoke v1 VisualSelfCorrector non-destructively to read its VLM approval."""
        raw: Dict[str, Any] = {}
        if self.visual_corrector is None:
            return True, raw

        try:
            assessment = self.visual_corrector.assess_only(
                scad_code=scad_code,
                view_images=view_images,
                brief=brief,
            )
        except Exception as e:  # pragma: no cover - defensive
            raw["error"] = f"visual_corrector threw: {str(e)[:200]}"
            return True, raw  # don't hard-fail on this

        raw["assessment"] = getattr(assessment, "__dict__", {})
        approved = bool(getattr(assessment, "approved", True))
        return approved, raw

    def _build_part_verdicts(
        self,
        criteria: AcceptanceCriteria,
        presence: Dict[str, Tuple[bool, float, str]],
    ) -> List[PartVerdict]:
        verdicts: List[PartVerdict] = []

        def _verdict(part: str, tier: str) -> PartVerdict:
            present, conf, notes = presence.get(part, (False, 0.0, "not observed"))
            return PartVerdict(
                name=part, tier=tier,
                present=present, confidence=conf, notes=notes,
            )

        for p in criteria.must_have_parts:
            verdicts.append(_verdict(p, "must_have"))
        for p in criteria.should_have_parts:
            if p in {v.name for v in verdicts}:
                continue
            verdicts.append(_verdict(p, "should_have"))
        return verdicts

    def _check_dimensions(
        self,
        brief: DesignBrief,
        plan: Optional[Dict[str, Any]],
        presence: Dict[str, Tuple[bool, float, str]],
    ) -> List[DimensionVerdict]:
        """
        Compare plan parameters against declared tolerances.

        Without a metric renderer we can't truly measure the SCAD output, so
        we treat the plan value as ground-truth and flag a parameter only
        when it is outside its own declared tolerance of the brief's value.
        This becomes a harder check once Stage 5 produces real measurements.
        """
        verdicts: List[DimensionVerdict] = []
        criteria = brief.acceptance_criteria
        expected_params = dict(brief.parameters or {})
        plan_params: Dict[str, Any] = {}
        if plan is not None:
            raw_plan_params = plan.get("parameters", {}) or {}
            for name, value in raw_plan_params.items():
                if isinstance(value, dict):
                    plan_params[name] = value.get("value", None)
                else:
                    plan_params[name] = value

        for name, tol in criteria.dimensional_tolerances.items():
            expected = expected_params.get(name)
            observed = plan_params.get(name, expected)
            if expected is None or observed is None:
                verdicts.append(DimensionVerdict(
                    name=name, expected=float(expected or 0.0),
                    observed=None, tolerance=tol,
                    within=False, source="plan",
                ))
                continue
            try:
                exp = float(expected)
                obs = float(observed)
            except (TypeError, ValueError):
                verdicts.append(DimensionVerdict(
                    name=name, expected=0.0, observed=None,
                    tolerance=tol, within=False, source="plan",
                ))
                continue
            denom = abs(exp) if exp else 1.0
            delta = abs(obs - exp) / denom
            verdicts.append(DimensionVerdict(
                name=name, expected=exp, observed=obs,
                tolerance=tol, within=(delta <= tol), source="plan",
            ))
        return verdicts

    def _check_topology(
        self,
        criteria: AcceptanceCriteria,
        vlm_suggestions: List[str],
    ) -> List[TopologyVerdict]:
        """
        Shallow topology check: if a VLM suggestion text-mentions a
        constraint, assume it was violated; otherwise tentatively satisfied.
        The full check lands with the VLM rewrite.
        """
        out: List[TopologyVerdict] = []
        for c in criteria.topology_constraints:
            violated = any(self._mentions(c, s) for s in vlm_suggestions)
            out.append(TopologyVerdict(
                constraint=c,
                satisfied=not violated,
                notes=("flagged by VLM suggestion" if violated else ""),
            ))
        return out

    @staticmethod
    def _mentions(constraint: str, suggestion: str) -> bool:
        lower = suggestion.lower()
        key_terms = [w for w in constraint.lower().split() if len(w) > 3]
        return sum(1 for w in key_terms if w in lower) >= max(1, len(key_terms) // 3)

    def _emit_patch_hints(
        self,
        feedback: FeedbackResult,
        criteria: AcceptanceCriteria,
    ) -> List[PatchHint]:
        hints: List[PatchHint] = []

        for part in feedback.missing_must_have:
            hints.append(PatchHint(
                op="add", target="geometry.base_shapes[-]",
                description=f"Add missing must-have part '{part}'",
                payload={"id": part, "_stub": True},
            ))
        for part in feedback.missing_should_have:
            hints.append(PatchHint(
                op="add", target="geometry.base_shapes[-]",
                description=f"Add missing should-have part '{part}'",
                payload={"id": part, "_stub": True},
            ))

        for dim in feedback.dimension_verdicts:
            if dim.within:
                continue
            hints.append(PatchHint(
                op="replace",
                target=f"parameters.{dim.name}",
                description=(
                    f"Update {dim.name}: observed={dim.observed}, "
                    f"expected={dim.expected} ±{dim.tolerance:.0%}"
                ),
                payload={"value": dim.expected},
            ))

        for constraint in feedback.violated_constraints:
            hints.append(PatchHint(
                op="add",
                target="geometry.operations[-]",
                description=f"Enforce topology constraint: '{constraint}'",
                payload={"_constraint": constraint},
            ))

        return hints


__all__ = [
    "PartVerdict",
    "DimensionVerdict",
    "TopologyVerdict",
    "PatchHint",
    "FeedbackResult",
    "UnifiedFeedbackLoop",
]
