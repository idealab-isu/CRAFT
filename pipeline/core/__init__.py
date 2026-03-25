"""
CADence Core Module

Contains the main pipeline components:
- schema: JSON CAD Plan schema and validation
- reasoner: Text understanding
- vision: Multi-view image analysis
- planner: Design brief to JSON plan conversion
- compiler: JSON plan to OpenSCAD compilation
- validator: Deterministic validation
- repair: Code repair
"""

from .schema import (
    CAD_PLAN_SCHEMA,
    validate_plan,
    validate_schema,
    validate_references,
    postprocess_plan,
    get_schema_as_string,
    extract_shape_ids,
    extract_parameters
)

from .reasoner import (
    TextReasoner,
    DesignBrief,
    KBComponentContext,
    create_design_brief
)

from .vision import (
    VisionAnalyzer,
    VisionAnalysis,
    vision_to_design_brief,
    analyze_views,
    encode_image_as_data_url,
    DEFAULT_VIEW_NAMES,
    ORTHO_VIEW_NAMES,
    ISO_VIEW_NAMES
)

from .planner import (
    Planner,
    PlanResult,
    create_cad_plan,
    quick_plan,
    MAX_PLAN_ATTEMPTS
)

from .compiler import (
    Compiler,
    compile_plan,
    compile_plan_fallback,
    strip_to_scad,
    format_value
)

from .validator import (
    Validator,
    ValidationResult,
    CheckResult,
    validate_scad,
    check_syntax,
    check_renders_non_blank,
    check_geometry_sanity,
    check_heuristic_coverage,
    VALIDATION_WEIGHTS,
    PASS_THRESHOLD
)

from .repair import (
    CodeRepairer,
    RepairOrchestrator,
    RepairResult,
    repair_code,
    quick_syntax_fix,
    fix_zero_dimensions,
    MAX_REPAIR_ATTEMPTS
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
    "KBComponentContext",
    "create_design_brief",
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
    "strip_to_scad",
    "format_value",
    # Validator
    "Validator",
    "ValidationResult",
    "CheckResult",
    "validate_scad",
    "check_syntax",
    "check_renders_non_blank",
    "check_geometry_sanity",
    "check_heuristic_coverage",
    "VALIDATION_WEIGHTS",
    "PASS_THRESHOLD",
    # Repair
    "CodeRepairer",
    "RepairOrchestrator",
    "RepairResult",
    "repair_code",
    "quick_syntax_fix",
    "fix_zero_dimensions",
    "MAX_REPAIR_ATTEMPTS",
]
