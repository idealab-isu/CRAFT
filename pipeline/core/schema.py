"""
CRAFT JSON Schema Definition

This module defines the parametric intermediate representation (IR) for CAD models.
The schema captures primitives, operations, and parameters before compilation to OpenSCAD.

Key design decisions:
- All dimensions can be numbers OR string expressions (e.g., "W/2")
- Parameters are defined at the top level and referenced throughout
- Operations are sequenced to ensure topological ordering
- Final output explicitly identifies the result geometry
"""

from typing import Any, Dict, List, Optional, Tuple
import jsonschema

# =============================================================================
# CAD PLAN JSON SCHEMA
# =============================================================================

CAD_PLAN_SCHEMA: Dict[str, Any] = {
    "type": "object",
    "required": ["metadata", "parameters", "geometry"],
    "properties": {
        "metadata": {
            "type": "object",
            "required": ["version", "units", "description"],
            "properties": {
                "version": {"type": "string", "const": "1.0"},
                "units": {"type": "string", "enum": ["mm", "cm", "m", "in", "ft"]},
                "description": {"type": "string"},
                "approximate": {"type": "boolean", "default": True}
            },
            "additionalProperties": False
        },
        "parameters": {
            "type": "object",
            "description": "Named parameters with optional ranges for customization",
            "additionalProperties": {
                "oneOf": [
                    {"type": "number"},
                    {
                        "type": "object",
                        "required": ["value"],
                        "properties": {
                            "value": {"type": "number"},
                            "min": {"type": "number"},
                            "max": {"type": "number"},
                            "step": {"type": "number"},
                            "type": {"type": "string", "enum": ["slider", "input"]},
                            "description": {"type": "string"}
                        },
                        "additionalProperties": False
                    }
                ]
            }
        },
        "geometry": {
            "type": "object",
            "required": ["base_shapes", "operations"],
            "properties": {
                "base_shapes": {
                    "type": "array",
                    "minItems": 1,
                    "description": "Primary 3D shapes to start with",
                    "items": {
                        "type": "object",
                        "required": ["id", "type"],
                        "properties": {
                            "id": {"type": "string"},
                            "type": {
                                "type": "string",
                                "enum": [
                                    "box", "cylinder", "sphere", "cone", "torus",
                                    "linear_extrude", "rotate_extrude"
                                ]
                            },
                            "size": {
                                "type": "array",
                                "minItems": 3,
                                "maxItems": 3,
                                "items": {"type": ["number", "string"]}
                            },
                            "radius": {"type": ["number", "string"]},
                            "radius2": {"type": ["number", "string"]},  # For cone top radius
                            "height": {"type": ["number", "string"]},
                            "center": {"type": "boolean"},
                            "position": {
                                "type": "array",
                                "minItems": 3,
                                "maxItems": 3,
                                "items": {"type": ["number", "string"]}
                            },
                            "rotation": {
                                "type": "array",
                                "minItems": 3,
                                "maxItems": 3,
                                "items": {"type": ["number", "string"]}
                            },
                            "profile": {
                                "type": "object",
                                "properties": {
                                    "type": {
                                        "type": "string",
                                        "enum": ["polygon", "circle", "square"]
                                    },
                                    "points": {
                                        "type": "array",
                                        "items": {
                                            "type": "array",
                                            "minItems": 2,
                                            "maxItems": 2,
                                            "items": {"type": ["number", "string"]}
                                        }
                                    },
                                    "radius": {"type": ["number", "string"]},
                                    "size": {
                                        "type": "array",
                                        "minItems": 2,
                                        "maxItems": 2,
                                        "items": {"type": ["number", "string"]}
                                    }
                                },
                                "additionalProperties": False
                            }
                        },
                        "allOf": [
                            {
                                "if": {"properties": {"type": {"const": "box"}}},
                                "then": {"required": ["size"]}
                            },
                            {
                                "if": {"properties": {"type": {"const": "cylinder"}}},
                                "then": {"required": ["radius", "height"]}
                            },
                            {
                                "if": {"properties": {"type": {"const": "sphere"}}},
                                "then": {"required": ["radius"]}
                            },
                            {
                                "if": {"properties": {"type": {"const": "cone"}}},
                                "then": {"required": ["radius", "height"]}
                            },
                            {
                                "if": {"properties": {"type": {"const": "torus"}}},
                                "then": {"required": ["radius"]}
                            },
                            {
                                "if": {"properties": {"type": {"const": "linear_extrude"}}},
                                "then": {"required": ["profile", "height"]}
                            },
                            {
                                "if": {"properties": {"type": {"const": "rotate_extrude"}}},
                                "then": {"required": ["profile"]}
                            }
                        ],
                        "additionalProperties": False
                    }
                },
                "operations": {
                    "type": "array",
                    "minItems": 0,
                    "description": "Boolean and transformation operations",
                    "items": {
                        "type": "object",
                        "required": ["id", "type", "target"],
                        "properties": {
                            "id": {"type": "string"},
                            "type": {
                                "type": "string",
                                "enum": [
                                    "union", "difference", "intersection",
                                    "translate", "rotate", "scale", "mirror",
                                    "hull", "minkowski"
                                ]
                            },
                            "target": {"type": ["string", "array"]},
                            "with": {"type": ["string", "array"]},
                            "params": {"type": "object"}
                        },
                        "allOf": [
                            {
                                "if": {
                                    "properties": {
                                        "type": {
                                            "enum": ["union", "difference", "intersection", "hull", "minkowski"]
                                        }
                                    }
                                },
                                "then": {
                                    "properties": {
                                        "target": {"type": "string"},
                                        "with": {
                                            "type": "array",
                                            "minItems": 1,
                                            "items": {"type": "string"}
                                        }
                                    },
                                    "required": ["with"]
                                }
                            },
                            {
                                "if": {"properties": {"type": {"const": "translate"}}},
                                "then": {
                                    "properties": {
                                        "params": {
                                            "type": "object",
                                            "properties": {
                                                "vector": {
                                                    "type": "array",
                                                    "minItems": 3,
                                                    "maxItems": 3,
                                                    "items": {"type": ["number", "string"]}
                                                }
                                            },
                                            "required": ["vector"],
                                            "additionalProperties": False
                                        }
                                    }
                                }
                            },
                            {
                                "if": {"properties": {"type": {"const": "rotate"}}},
                                "then": {
                                    "properties": {
                                        "params": {
                                            "type": "object",
                                            "oneOf": [
                                                {
                                                    "properties": {
                                                        "vector": {
                                                            "type": "array",
                                                            "minItems": 3,
                                                            "maxItems": 3,
                                                            "items": {"type": ["number", "string"]}
                                                        }
                                                    },
                                                    "required": ["vector"],
                                                    "additionalProperties": False
                                                },
                                                {
                                                    "properties": {
                                                        "angle": {"type": ["number", "string"]},
                                                        "axis": {
                                                            "type": "array",
                                                            "minItems": 3,
                                                            "maxItems": 3,
                                                            "items": {"type": ["number", "string"]}
                                                        }
                                                    },
                                                    "required": ["angle", "axis"],
                                                    "additionalProperties": False
                                                }
                                            ]
                                        }
                                    }
                                }
                            },
                            {
                                "if": {"properties": {"type": {"const": "scale"}}},
                                "then": {
                                    "properties": {
                                        "params": {
                                            "type": "object",
                                            "oneOf": [
                                                {
                                                    "properties": {
                                                        "vector": {
                                                            "type": "array",
                                                            "minItems": 3,
                                                            "maxItems": 3,
                                                            "items": {"type": ["number", "string"]}
                                                        }
                                                    },
                                                    "required": ["vector"],
                                                    "additionalProperties": False
                                                },
                                                {
                                                    "properties": {
                                                        "uniform": {"type": ["number", "string"]}
                                                    },
                                                    "required": ["uniform"],
                                                    "additionalProperties": False
                                                }
                                            ]
                                        }
                                    }
                                }
                            },
                            {
                                "if": {"properties": {"type": {"const": "mirror"}}},
                                "then": {
                                    "properties": {
                                        "params": {
                                            "type": "object",
                                            "properties": {
                                                "vector": {
                                                    "type": "array",
                                                    "minItems": 3,
                                                    "maxItems": 3,
                                                    "items": {"type": ["number", "string"]}
                                                }
                                            },
                                            "required": ["vector"],
                                            "additionalProperties": False
                                        }
                                    }
                                }
                            }
                        ],
                        "additionalProperties": False
                    }
                }
            },
            "additionalProperties": False
        },
        "final_output": {
            "type": "string",
            "description": "ID of the final shape or operation"
        }
    },
    "additionalProperties": False
}


# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

def validate_schema(plan: Dict[str, Any]) -> Tuple[bool, Optional[str]]:
    """
    Validate a CAD plan against the JSON schema.
    
    Returns:
        Tuple of (is_valid, error_message)
    """
    try:
        jsonschema.validate(plan, CAD_PLAN_SCHEMA)
        return True, None
    except jsonschema.ValidationError as e:
        return False, str(e.message)


def validate_references(plan: Dict[str, Any]) -> Tuple[bool, Optional[str]]:
    """
    Validate that all ID references in the plan are valid.
    Ensures topological ordering (no forward references).
    
    Returns:
        Tuple of (is_valid, error_message)
    """
    if "geometry" not in plan:
        return False, "Missing 'geometry' field"
    
    geometry = plan["geometry"]
    
    if "base_shapes" not in geometry:
        return False, "Missing 'base_shapes' in geometry"
    
    shapes = geometry.get("base_shapes", [])
    operations = geometry.get("operations", [])
    
    # Collect all shape IDs
    shape_ids = [s.get("id") for s in shapes if s.get("id")]
    
    # Check for duplicate shape IDs
    if len(shape_ids) != len(set(shape_ids)):
        duplicates = [id for id in shape_ids if shape_ids.count(id) > 1]
        return False, f"Duplicate base_shape IDs: {set(duplicates)}"
    
    # Track all seen IDs (shapes + operations)
    seen_ids = set(shape_ids)
    
    def check_ref(ref: Any, context: str) -> Optional[str]:
        """Check if a reference is valid."""
        if isinstance(ref, str):
            if ref not in seen_ids:
                return f"Reference '{ref}' not found in {context}"
        elif isinstance(ref, list):
            for r in ref:
                if isinstance(r, str) and r not in seen_ids:
                    return f"Reference '{r}' not found in {context}"
        return None
    
    # Validate operations in sequence
    for op in operations:
        op_id = op.get("id")
        op_type = op.get("type")
        
        if not op_id:
            return False, "Operation missing 'id' field"
        
        if op_id in seen_ids:
            return False, f"Duplicate ID: '{op_id}'"
        
        # Check target reference
        target = op.get("target")
        if not target:
            return False, f"Operation '{op_id}' missing 'target'"
        
        err = check_ref(target, f"operation '{op_id}' target")
        if err:
            return False, err
        
        # Check 'with' reference for boolean operations
        if op_type in {"union", "difference", "intersection", "hull", "minkowski"}:
            with_refs = op.get("with")
            if not with_refs:
                return False, f"Boolean operation '{op_id}' missing 'with' field"
            err = check_ref(with_refs, f"operation '{op_id}' with")
            if err:
                return False, err
        
        # Add this operation to seen IDs
        seen_ids.add(op_id)
    
    # Validate final_output
    final_output = plan.get("final_output", "")
    if not final_output:
        return False, "Missing 'final_output' field"
    
    if final_output not in seen_ids:
        return False, f"final_output '{final_output}' not found in shapes or operations"
    
    return True, None


def validate_plan(plan: Dict[str, Any]) -> Tuple[bool, Optional[str]]:
    """
    Full validation: schema + reference integrity.
    
    Returns:
        Tuple of (is_valid, error_message)
    """
    # First validate schema
    valid, error = validate_schema(plan)
    if not valid:
        return False, f"Schema validation failed: {error}"
    
    # Then validate references
    valid, error = validate_references(plan)
    if not valid:
        return False, f"Reference validation failed: {error}"
    
    return True, None


def postprocess_plan(plan: Dict[str, Any]) -> Dict[str, Any]:
    """
    Apply default values and fix common issues in a plan.
    """
    # Ensure metadata exists with defaults
    if "metadata" not in plan:
        plan["metadata"] = {}
    
    plan["metadata"].setdefault("version", "1.0")
    plan["metadata"].setdefault("units", "mm")
    plan["metadata"].setdefault("description", "Generated CAD model")
    plan["metadata"].setdefault("approximate", True)
    
    # Ensure geometry structure
    if "geometry" not in plan:
        plan["geometry"] = {}
    
    plan["geometry"].setdefault("base_shapes", [])
    plan["geometry"].setdefault("operations", [])
    
    # Ensure parameters exist
    plan.setdefault("parameters", {})
    
    # Auto-set final_output if missing
    if not plan.get("final_output"):
        ops = plan["geometry"].get("operations", [])
        shapes = plan["geometry"].get("base_shapes", [])
        
        if ops:
            plan["final_output"] = ops[-1].get("id", "")
        elif shapes:
            plan["final_output"] = shapes[-1].get("id", "")
    
    return plan


# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def get_schema_as_string() -> str:
    """Return the schema as a formatted JSON string for prompts."""
    import json
    return json.dumps(CAD_PLAN_SCHEMA, indent=2)


def extract_shape_ids(plan: Dict[str, Any]) -> List[str]:
    """Extract all shape and operation IDs from a plan."""
    ids = []
    
    for shape in plan.get("geometry", {}).get("base_shapes", []):
        if shape.get("id"):
            ids.append(shape["id"])
    
    for op in plan.get("geometry", {}).get("operations", []):
        if op.get("id"):
            ids.append(op["id"])
    
    return ids


def extract_parameters(plan: Dict[str, Any]) -> Dict[str, float]:
    """Extract parameter definitions from a plan (values only)."""
    params = plan.get("parameters", {})
    result = {}
    for name, value in params.items():
        if isinstance(value, dict):
            result[name] = value.get("value", 0)
        else:
            result[name] = value
    return result


def extract_parameter_metadata(plan: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    """
    Extract parameter metadata including ranges and constraints.

    Returns:
        Dict mapping parameter name to metadata:
        {
            "head_width": {"value": 10, "min": 5, "max": 50, "step": 1, "type": "slider"},
            "head_height": {"value": 5, "min": 1, "max": 10}
        }
    """
    params = plan.get("parameters", {})
    result = {}

    for name, value in params.items():
        if isinstance(value, dict):
            result[name] = value.copy()
        else:
            # Convert simple number to metadata format
            result[name] = {"value": value}

    return result


def normalize_parameters(plan: Dict[str, Any]) -> None:
    """
    Convert all parameters to metadata format in-place.
    Simple numbers become {"value": num}.
    """
    params = plan.get("parameters", {})
    for name, value in params.items():
        if not isinstance(value, dict):
            params[name] = {"value": value}
