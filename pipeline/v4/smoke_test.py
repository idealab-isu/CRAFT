"""
CRAFT v4 — Smoke test.

Imports every v4 module, instantiates the pieces that don't need the
network, runs trivial logic asserts on the regression gate, and confirms
that the runner wiring constructs without error.

Does NOT call OpenAI. Run this before the first real benchmark to make
sure paths resolve and modules import cleanly:

    python -m pipeline.v4.smoke_test
"""

from __future__ import annotations

import sys
from pathlib import Path

_PIPELINE_ROOT = Path(__file__).resolve().parent.parent
if str(_PIPELINE_ROOT) not in sys.path:
    sys.path.insert(0, str(_PIPELINE_ROOT))


def _ok(msg: str) -> None:
    print(f"  OK  {msg}")


def _fail(msg: str) -> None:
    print(f"  FAIL {msg}")


def main() -> int:
    print("CRAFT v4 smoke test")
    print("=" * 60)

    # 1. Imports.
    print("[1/5] imports")
    try:
        from v4 import (
            BaselineGenerator,
            GapAssessor,
            KBReference,
            RegressionGate,
            SCADPatcher,
            V4Config,
            V4Runner,
        )
        from v4.regression_gate import GateInputs
        _ok("v4 module imports")
    except Exception as e:
        _fail(f"import failed: {e}")
        return 1

    # 2. Renderer/sanity helpers.
    print("[2/5] render/sanity helpers")
    try:
        from v4.render_check import RenderCheck, V4_VIEWS
        rc = RenderCheck()
        assert len(V4_VIEWS) == 8
        _ok(f"RenderCheck constructed; {len(V4_VIEWS)} views configured")
    except Exception as e:
        _fail(f"render_check: {e}")
        return 1

    # 3. KB reference (must NOT raise even if KB index is missing).
    print("[3/5] KB reference (missing index tolerated)")
    try:
        kb = KBReference(min_score=0.85)
        hint = kb.lookup("a 608 skateboard bearing")
        assert hint is not None
        _ok(f"KBReference returned hint (fired={hint.fired})")
    except Exception as e:
        _fail(f"kb_reference: {e}")
        return 1

    # 4. Regression gate logic (synthetic).
    print("[4/5] regression-gate logic")
    try:
        # Default margin = 2: requires patch to add 2+ passing criteria.
        gate = RegressionGate()
        assert gate.min_patch_gain == 2
        b = GateInputs(
            name="baseline", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=2, criteria_total=4,
            num_failed_views=1, stl_success=True,
        )
        # Margin = 1 patch should be REVERTED at default margin 2.
        p_margin1 = GateInputs(
            name="patched", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=3, criteria_total=4,
            num_failed_views=1, stl_success=True,
        )
        d = gate.decide(b, p_margin1)
        assert not d.kept_patch, (
            f"expected revert at default margin 2, got {d.chosen} ({d.reason})"
        )
        _ok(f"revert margin-1 patch at default margin 2: {d.reason}")

        # Margin = 2 patch should be KEPT.
        p_better = GateInputs(
            name="patched", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=4, criteria_total=4,
            num_failed_views=1, stl_success=True,
        )
        d = gate.decide(b, p_better)
        assert d.kept_patch, f"expected keep, got {d.chosen} ({d.reason})"
        _ok(f"keep when criteria improves by 2+: {d.reason}")

        # Legacy behaviour: with min_patch_gain=1, margin=1 is kept.
        legacy = RegressionGate(min_patch_gain=1)
        d = legacy.decide(b, p_margin1)
        assert d.kept_patch
        _ok(f"legacy margin=1 keeps margin-1 patch: {d.reason}")

        # Patched ties — should revert.
        p_tie = GateInputs(
            name="patched", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=2, criteria_total=4,
            num_failed_views=1, stl_success=True,
        )
        d = gate.decide(b, p_tie)
        assert not d.kept_patch
        _ok(f"revert on tie: {d.reason}")

        # Patched lost STL — must revert.
        p_no_stl = GateInputs(
            name="patched", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=99, criteria_total=99,
            num_failed_views=0, stl_success=False,
        )
        d = gate.decide(b, p_no_stl)
        assert not d.kept_patch
        _ok(f"revert on lost STL: {d.reason}")

        # Patched added broken views — must revert.
        p_more_blank = GateInputs(
            name="patched", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=99, criteria_total=99,
            num_failed_views=2, stl_success=True,
        )
        d = gate.decide(b, p_more_blank)
        assert not d.kept_patch
        _ok(f"revert on more failed views: {d.reason}")

        # ----- Multi-baseline selection -----
        # Two baselines, gpt52 has more passing criteria → wins.
        c_gpt52 = GateInputs(
            name="baseline_gpt-5_2", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=4, criteria_total=5,
            num_failed_views=0, stl_success=True,
        )
        c_gpt4o = GateInputs(
            name="baseline_gpt-4o", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=2, criteria_total=5,
            num_failed_views=0, stl_success=True,
        )
        winner, reason = gate.select_best_baseline([c_gpt52, c_gpt4o])
        assert winner is not None and winner.name == "baseline_gpt-5_2"
        _ok(f"multi-baseline: gpt52 wins on criteria — {reason}")

        # Tie on criteria → tie-break on failed views.
        c1 = GateInputs(
            name="baseline_gpt-5_2", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=3, criteria_total=5,
            num_failed_views=2, stl_success=True,
        )
        c2 = GateInputs(
            name="baseline_gpt-4o", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=3, criteria_total=5,
            num_failed_views=0, stl_success=True,
        )
        winner, reason = gate.select_best_baseline([c1, c2])
        assert winner is not None and winner.name == "baseline_gpt-4o"
        _ok(f"multi-baseline: gpt-4o wins on render quality — {reason}")

        # No STL anywhere → still pick the least-broken candidate.
        c_no_stl_a = GateInputs(
            name="baseline_a", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=0, criteria_total=5,
            num_failed_views=4, stl_success=False,
        )
        c_no_stl_b = GateInputs(
            name="baseline_b", scad_code="", scad_path="", stl_path="",
            view_paths={}, criteria_pass=0, criteria_total=5,
            num_failed_views=2, stl_success=False,
        )
        winner, reason = gate.select_best_baseline([c_no_stl_a, c_no_stl_b])
        assert winner is not None and winner.name == "baseline_b"
        _ok(f"multi-baseline: STL-less fallback — {reason}")
    except Exception as e:
        _fail(f"gate logic: {e}")
        return 1

    # 5. Runner construction (does NOT call any network endpoints).
    print("[5/5] runner construction")
    try:
        cfg = V4Config(use_kb=False, enable_patch=True)
        # Note: V4Runner instantiates an OpenAI client; this just needs the
        # OPENAI_API_KEY env var to exist (anything goes — we don't call out).
        import os
        if not os.getenv("OPENAI_API_KEY"):
            os.environ["OPENAI_API_KEY"] = "smoke-test-no-network"
        runner = V4Runner(config=cfg)
        assert runner is not None
        _ok("V4Runner constructed")
    except Exception as e:
        _fail(f"runner construction: {e}")
        return 1

    print("=" * 60)
    print("OK — all smoke checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
