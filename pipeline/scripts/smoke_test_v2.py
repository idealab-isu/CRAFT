"""
CRAFT v2 smoke test.

Runs through the Phase A + Phase B.5–B.9 plumbing end-to-end without
hitting any LLM or render backend. Useful as a fast sanity check after
a rebase / edit pass.

Usage:
    cd pipeline
    python scripts/smoke_test_v2.py

The script exits 0 on success, 1 on the first assertion failure.
"""

from __future__ import annotations

import os
import sys
import tempfile
import warnings

# Ensure the pipeline directory is importable
HERE = os.path.dirname(os.path.abspath(__file__))
PIPELINE = os.path.dirname(HERE)
if PIPELINE not in sys.path:
    sys.path.insert(0, PIPELINE)


def _expect(cond: bool, msg: str) -> None:
    if not cond:
        print(f"  FAIL: {msg}")
        raise SystemExit(1)


def phase_a() -> None:
    print("Phase A — cleanup + refactor")

    with warnings.catch_warnings(record=True):
        warnings.simplefilter("always")
        from core.validator import Validator as _V1Validator  # noqa: F401
        from core.repair import CodeRepairer as _V1Repair    # noqa: F401
    print("  A.1 v1 validator/repair stubs import")

    from core.reasoner import TextReasoner, KBDetectionBundle
    _expect(hasattr(TextReasoner, "detect"), "TextReasoner.detect missing")
    _expect(hasattr(TextReasoner, "analyze_with_bundle"),
            "analyze_with_bundle missing")
    _expect(hasattr(KBDetectionBundle, "component_details_for_enhancer"),
            "KBDetectionBundle helper missing")
    print("  A.2 reasoner unified detect path")

    import dataclasses
    from core.scad_autofix import AutoFixResult
    fields = {f.name for f in dataclasses.fields(AutoFixResult)}
    _expect({"fix_source", "llm_attempts", "rule_based_tried"} <= fields,
            "AutoFixResult missing attribution fields")
    print("  A.3 scad_autofix attribution fields present")

    from kb import DetectionStrategiesConfig
    from kb.detector import ComponentDetector
    cfg = DetectionStrategiesConfig.exact_and_semantic_only()
    det = ComponentDetector(components={}, strategies=cfg)
    _expect(det.strategies.enabled_names() == ["exact", "semantic"],
            f"strategy ablation not honored: {det.strategies.enabled_names()}")
    print("  A.4 KB strategy ablation honored")


def phase_b() -> None:
    print("Phase B — core v2 plumbing")

    from core import (
        DesignBrief, AcceptanceCriteria,
        audit_roundtrip,
        render_quality_gate,
        UnifiedFeedbackLoop,
        repair_plan_from_feedback,
    )

    brief = DesignBrief(
        description="unit test",
        expected_parts=["body", "wheel"],
        parameters={"W": 10.0},
        source="text",
        original_input="",
        essential_parts=["body"],
        secondary_parts=["wheel"],
        acceptance_criteria=AcceptanceCriteria(
            must_have_parts=["body"],
            should_have_parts=["wheel"],
            dimensional_tolerances={"W": 0.10},
        ),
    )
    _expect(hasattr(brief, "acceptance_criteria"),
            "DesignBrief.acceptance_criteria missing")
    print("  B.5 AcceptanceCriteria on DesignBrief")

    plan = {
        "parameters": {"W": 12.0},
        "geometry": {
            "base_shapes": [{"id": "body", "type": "cube"}],
            "operations": [],
        },
    }
    scad = "module body() { cube([10,10,10]); }\nbody();"
    audit = audit_roundtrip(plan, scad)
    _expect(audit.ok, f"audit should pass, got {audit.summary()}")
    bad = audit_roundtrip(plan, "// empty")
    _expect(not bad.ok and bad.empty_output, "empty SCAD not flagged")
    print("  B.6 round-trip audit: OK path + empty-output catch")

    # B.7 render-quality gate with a synthetic image
    try:
        import numpy as np
        from PIL import Image
    except ImportError:
        print("  B.7 skipped (numpy/PIL missing in env)")
    else:
        tmp = tempfile.mkdtemp()
        a = np.full((128, 128, 3), 255, np.uint8)
        a[40:80, 40:80] = 120
        path = os.path.join(tmp, "v.png")
        Image.fromarray(a).save(path)
        gate = render_quality_gate({"front": path, "top": path, "iso": path})
        _expect(gate.passed, f"synthetic render should pass gate: {gate.summary()}")
        blank_path = os.path.join(tmp, "blank.png")
        Image.fromarray(np.full((128, 128, 3), 255, np.uint8)).save(blank_path)
        gate2 = render_quality_gate({"front": blank_path, "top": blank_path})
        _expect(not gate2.passed, "blank render should fail gate")
        print("  B.7 render-quality gate (OK path + blank rejection)")

    loop = UnifiedFeedbackLoop()
    feedback = loop.run(
        brief=brief,
        scad_code="// stub",
        view_images={},
        plan=plan,
    )
    _expect("body" in feedback.missing_must_have,
            "body should be missing in unified feedback")
    _expect(any(h.target == "parameters.W" for h in feedback.patch_hints),
            "expected patch hint for parameters.W")
    print("  B.8 unified feedback emits patch hints")

    result = repair_plan_from_feedback(plan=plan, feedback=feedback)
    _expect(result.success(),
            f"json patch repair failed: {result.errors}")
    _expect(result.patched_plan["parameters"]["W"] == 10.0,
            "repair should snap W back to 10")
    print("  B.9 JSON patch repair updates plan")


if __name__ == "__main__":
    phase_a()
    phase_b()
    print("=" * 60)
    print("CRAFT v2 smoke test: PASS")
