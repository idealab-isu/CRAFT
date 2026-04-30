"""
CRAFT Core Module (v2)

Contains the main pipeline components:
- schema: JSON CAD Plan schema and validation
- reasoner: Text understanding + consolidated KB grounding
- vision: Multi-view image analysis
- planner: Design brief to JSON plan conversion
- compiler: JSON plan to OpenSCAD compilation
- render_checks: Deterministic render sanity gates
  (thin replacement for the removed v1 ``validator`` / ``repair`` modules)

v1 modules ``core.validator`` and ``core.repair`` survive only as deprecation
stubs; prefer importing from ``core.render_checks``.
"""

from .schema import (
    CAD_PLAN_SCHEMA,
    validate_plan,
    validate_schema,
    validate_references,
    postprocess_plan,
    get_schema_as_string,
    extract_shape_ids,
    extract_parameters,
)

from .reasoner import (
    TextReasoner,
    DesignBrief,
    AcceptanceCriteria,
    KBComponentContext,
    create_design_brief,
    detect_primary_dimension,
)

from .vision import (
    VisionAnalyzer,
    VisionAnalysis,
    vision_to_design_brief,
    analyze_views,
    encode_image_as_data_url,
    DEFAULT_VIEW_NAMES,
    ORTHO_VIEW_NAMES,
    ISO_VIEW_NAMES,
)

from .planner import (
    Planner,
    PlanResult,
    create_cad_plan,
    quick_plan,
    MAX_PLAN_ATTEMPTS,
)

from .compiler import (
    Compiler,
    compile_plan,
    compile_plan_fallback,
    compile_plan_with_audit,
    CompileAudit,
    audit_roundtrip,
    strip_to_scad,
    format_value,
)

# v2: deterministic render/syntax sanity only.  The v1 Validator/Repair
# modules are stubs now; see core.render_checks for what actually runs.
from .render_checks import (
    CheckResult,
    ValidationResult,
    Validator,
    check_renders_non_blank,
    validate_scad,
    VALIDATION_WEIGHTS,
    PASS_THRESHOLD,
    # v2 Phase B.7 render-quality gate
    ViewQuality,
    QualityGateResult,
    QUALITY_GATE_DEFAULTS,
    render_quality_gate,
)

# v2 Phase B.8: unified visual + structural feedback
from .unified_feedback import (
    PartVerdict,
    DimensionVerdict,
    TopologyVerdict,
    PatchHint,
    FeedbackResult,
    UnifiedFeedbackLoop,
)

# v2 Phase B.9: JSON Patch repair
from .patch_repair import (
    PatchApplyResult,
    apply_patches,
    hints_to_patches,
    repair_plan_from_feedback,
)

# v2: intermediate sketch grounding (image-gen sketch from refined prompt)
from .sketch_generator import (
    SketchResult,
    SketchGenerator,
    build_sketch_prompt,
    sketch_from_design_brief,
    SKETCH_ENABLED_DEFAULT,
)

# v2: rule-based preemptive render-safety scan (no LLM call). Runs AFTER
# compile and BEFORE the first render so we don't burn 60s × 6 views on
# known-bad patterns like minkowski() that the planner may still emit.
from .scad_autofix import (
    PreemptiveFixResult,
    preemptive_render_safety_fix,
    SCADAutoFixer,
    AutoFixResult,
    fix_scad_for_rendering,
)

# v2: repair is removed; stubs re-exported so legacy eval scripts import
# without ImportError. Invoking any of these raises at call time.
from .repair import (
    CodeRepairer,
    RepairOrchestrator,
    RepairResult,
    repair_code,
    quick_syntax_fix,
    fix_zero_dimensions,
    MAX_REPAIR_ATTEMPTS,
)

__all__ = [
    # Schema
    "CAD_PLAN_SCHEMA",
    "validate_plan",
    "validate_schema",
    "validate_references",
    "postprocess_plan",
    "get_schema_as_string",
    "extract_shape_ids",
    "extract_parameters",
    # Reasoner
    "TextReasoner",
    "DesignBrief",
    "AcceptanceCriteria",
    "KBComponentContext",
    "create_design_brief",
    "detect_primary_dimension",
    # Vision
    "VisionAnalyzer",
    "VisionAnalysis",
    "vision_to_design_brief",
    "analyze_views",
    "encode_image_as_data_url",
    "DEFAULT_VIEW_NAMES",
    "ORTHO_VIEW_NAMES",
    "ISO_VIEW_NAMES",
    # Planner
    "Planner",
    "PlanResult",
    "create_cad_plan",
    "quick_plan",
    "MAX_PLAN_ATTEMPTS",
    # Compiler
    "Compiler",
    "compile_plan",
    "compile_plan_fallback",
    "compile_plan_with_audit",
    "CompileAudit",
    "audit_roundtrip",
    "strip_to_scad",
    "format_value",
    # Render checks (lightweight v2 replacement for v1 Validator)
    "CheckResult",
    "ValidationResult",
    "Validator",
    "check_renders_non_blank",
    "validate_scad",
    "VALIDATION_WEIGHTS",
    "PASS_THRESHOLD",
    # v2 Phase B.7 render-quality gate
    "ViewQuality",
    "QualityGateResult",
    "QUALITY_GATE_DEFAULTS",
    "render_quality_gate",
    # v2 Phase B.8 unified feedback
    "PartVerdict",
    "DimensionVerdict",
    "TopologyVerdict",
    "PatchHint",
    "FeedbackResult",
    "UnifiedFeedbackLoop",
    # v2 Phase B.9 JSON Patch repair
    "PatchApplyResult",
    "apply_patches",
    "hints_to_patches",
    "repair_plan_from_feedback",
    # v2 sketch grounding
    "SketchResult",
    "SketchGenerator",
    "build_sketch_prompt",
    "sketch_from_design_brief",
    "SKETCH_ENABLED_DEFAULT",
    # Legacy repair stubs (raise on invocation)
    "CodeRepairer",
    "RepairOrchestrator",
    "RepairResult",
    "repair_code",
    "quick_syntax_fix",
    "fix_zero_dimensions",
    "MAX_REPAIR_ATTEMPTS",
]
