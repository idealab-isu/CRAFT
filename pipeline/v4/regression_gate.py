"""
CRAFT v4 — Stage 7: Non-regression gate.

The gate decides whether to keep the patched SCAD or revert to the baseline.
It must use INFERENCE-AVAILABLE signals only — never ground-truth STL or
ground-truth metrics. This is what guarantees v4 >= GPT-5.2 baseline on
every sample (in expectation; modulo noise in the proxy signals).

Decision rule:

    KEEP_PATCH iff
        (criteria_pass_count_patched > criteria_pass_count_baseline)
            AND
        (num_failed_views_patched <= num_failed_views_baseline)
            AND
        (stl_success_patched OR not stl_success_baseline)

Otherwise REVERT_TO_BASELINE.

Tie behaviour: if the patched output ties on criteria pass count, it is
discarded (cost without proven benefit). This is intentional — the
non-regression rule is only as good as the noise floor of the criteria
verdicts, so we err strict.

The companion oracle gate (oracle_gate.py / run_v4_oracle_ablation.py) uses
ground-truth Chamfer to pick the winner. It is reported separately as an
upper-bound figure and MUST NOT be used as the deployable rule.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import List, Optional, Tuple


@dataclass
class GateInputs:
    """Snapshot of one candidate (baseline_<model>, patched, etc.)."""
    name: str                        # e.g. "baseline_gpt-5.2", "baseline_gpt-4o", "patched"
    scad_code: str
    scad_path: str
    stl_path: str
    view_paths: dict
    criteria_pass: int               # acceptance criteria passed
    criteria_total: int
    num_failed_views: int            # from sanity verdict
    stl_success: bool


@dataclass
class GateDecision:
    """Outcome of the non-regression gate."""
    chosen: str                      # "baseline" | "patched"
    reason: str
    baseline_pass: int
    patched_pass: int
    baseline_failed_views: int
    patched_failed_views: int
    baseline_stl_ok: bool
    patched_stl_ok: bool

    @property
    def kept_patch(self) -> bool:
        return self.chosen == "patched"


class RegressionGate:
    """Inference-only non-regression gate.

    ``min_patch_gain`` controls how aggressive the gate is when accepting
    a patch over the chosen baseline:

        min_patch_gain = 1   → "strictly greater" (legacy v4 default)
        min_patch_gain = 2   → "must add 2+ passing criteria" (current default)
        min_patch_gain = 3   → very conservative

    Empirically (canonical 30 v2 run), patches with margin = 1 were a
    coin flip — half helped, half hurt — while patches with margin >= 2
    were genuine wins. Default 2 is the right starting point.
    """

    def __init__(self, min_patch_gain: int = 2):
        self.min_patch_gain = max(1, int(min_patch_gain))

    # ------------------------------------------------------------------
    # Multi-baseline selection
    # ------------------------------------------------------------------

    def select_best_baseline(
        self, candidates: List[GateInputs]
    ) -> Tuple[Optional[GateInputs], str]:
        """Pick the strongest baseline among multiple candidates.

        Selection rules (inference-only):
            1. Drop candidates that failed STL export.
            2. Among the rest, prefer higher ``criteria_pass``.
            3. Tie-break: fewer ``num_failed_views``.
            4. Tie-break: order in input list (so callers can encode a
               preference, e.g. put gpt-5.2 first as default).

        Returns ``(winner, reason_string)``. ``winner`` is None iff every
        candidate failed STL export.
        """
        if not candidates:
            return None, "no candidates"

        # Step 1: STL filter.
        with_stl = [c for c in candidates if c.stl_success]
        if not with_stl:
            # No candidate has a valid STL — fall back to whichever rendered
            # the most non-blank views, or the first one if nothing rendered.
            best = min(candidates, key=lambda c: c.num_failed_views)
            return best, f"no STL succeeded; picked {best.name} on render quality"

        # Step 2: highest criteria pass count.
        max_pass = max(c.criteria_pass for c in with_stl)
        top_pass = [c for c in with_stl if c.criteria_pass == max_pass]
        if len(top_pass) == 1:
            w = top_pass[0]
            return w, (
                f"{w.name} won on criteria ({w.criteria_pass}/{w.criteria_total})"
            )

        # Step 3: fewest broken views.
        min_failed = min(c.num_failed_views for c in top_pass)
        top_views = [c for c in top_pass if c.num_failed_views == min_failed]
        if len(top_views) == 1:
            w = top_views[0]
            return w, (
                f"{w.name} won on render quality ({w.num_failed_views} bad views)"
            )

        # Step 4: list order (callers' preference).
        # ``candidates`` ordering is preserved through the filter chain.
        for c in candidates:
            if c in top_views:
                return c, f"{c.name} won on default preference (tie)"
        # unreachable
        return top_views[0], "tie fallback"

    # ------------------------------------------------------------------
    # Patched-vs-baseline non-regression gate (unchanged contract)
    # ------------------------------------------------------------------

    def decide(
        self,
        baseline: GateInputs,
        patched: Optional[GateInputs],
    ) -> GateDecision:
        if patched is None:
            return GateDecision(
                chosen="baseline",
                reason="no patch attempted",
                baseline_pass=baseline.criteria_pass,
                patched_pass=0,
                baseline_failed_views=baseline.num_failed_views,
                patched_failed_views=0,
                baseline_stl_ok=baseline.stl_success,
                patched_stl_ok=False,
            )

        # Hard guard: a patch that loses STL when baseline had one is a
        # regression we never accept.
        if baseline.stl_success and not patched.stl_success:
            return self._revert(
                "patched lost STL export",
                baseline, patched,
            )

        # Hard guard: a patch that increases the number of broken views.
        if patched.num_failed_views > baseline.num_failed_views:
            return self._revert(
                f"patched view-failure count rose "
                f"({baseline.num_failed_views} -> {patched.num_failed_views})",
                baseline, patched,
            )

        # Patch must beat baseline by at least min_patch_gain passing criteria.
        gain = patched.criteria_pass - baseline.criteria_pass
        if gain >= self.min_patch_gain:
            return self._keep(
                f"patched gained {gain} criteria "
                f"({baseline.criteria_pass} -> {patched.criteria_pass}, "
                f"threshold +{self.min_patch_gain})",
                baseline, patched,
            )

        # Below the margin → revert. Tied / mild gains are too noisy to trust.
        return self._revert(
            f"patched gain ({gain}) below margin (+{self.min_patch_gain}); "
            f"{baseline.criteria_pass} -> {patched.criteria_pass}",
            baseline, patched,
        )

    @staticmethod
    def _keep(reason, baseline: GateInputs, patched: GateInputs) -> GateDecision:
        return GateDecision(
            chosen="patched",
            reason=reason,
            baseline_pass=baseline.criteria_pass,
            patched_pass=patched.criteria_pass,
            baseline_failed_views=baseline.num_failed_views,
            patched_failed_views=patched.num_failed_views,
            baseline_stl_ok=baseline.stl_success,
            patched_stl_ok=patched.stl_success,
        )

    @staticmethod
    def _revert(reason, baseline: GateInputs, patched: GateInputs) -> GateDecision:
        return GateDecision(
            chosen="baseline",
            reason=reason,
            baseline_pass=baseline.criteria_pass,
            patched_pass=patched.criteria_pass,
            baseline_failed_views=baseline.num_failed_views,
            patched_failed_views=patched.num_failed_views,
            baseline_stl_ok=baseline.stl_success,
            patched_stl_ok=patched.stl_success,
        )
