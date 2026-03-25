"""
CRAFT Parameter Parser

Utility to parse OpenSCAD parameter definitions with range annotations.
Supports OpenSCAD Customizer syntax for ranges and constraints.
"""

import re
from typing import Dict, List, Any, Optional, Tuple


def parse_parameter_line(line: str) -> Optional[Dict[str, Any]]:
    """
    Parse a single parameter line from OpenSCAD code.

    Supports formats:
    - param = 10; //[5:50]           (min:max, step=1)
    - param = 10; //[5:50:2]         (min:max:step)
    - param = 10; //[1:2:50]         (min:step:max alternative)
    - param = "foo"; //["a", "b"]    (dropdown options)

    Args:
        line: OpenSCAD code line

    Returns:
        Parameter metadata dict or None if not a parameter
    """
    # Match parameter definition: name = value; //[range]
    pattern = r'^\s*([a-zA-Z_]\w*)\s*=\s*([^;]+)\s*;\s*(?://\s*(.+))?$'
    match = re.match(pattern, line.strip())

    if not match:
        return None

    name = match.group(1)
    value_str = match.group(2).strip()
    comment = match.group(3)

    # Parse value
    value = parse_value(value_str)
    if value is None:
        return None

    # Initialize parameter metadata
    param = {
        "name": name,
        "value": value,
        "type": "input"  # default type
    }

    # Parse range/options from comment
    if comment:
        range_info = parse_range_comment(comment)
        if range_info:
            param.update(range_info)
            if "min" in range_info or "options" in range_info:
                param["type"] = "slider" if "min" in range_info else "dropdown"

    return param


def parse_value(value_str: str) -> Optional[float]:
    """
    Parse parameter value from string.

    Args:
        value_str: Value as string (e.g., "10", "3.14", '"string"')

    Returns:
        Numeric value or None if not numeric
    """
    try:
        # Try to parse as number
        return float(value_str)
    except ValueError:
        # Check if it's a string literal (we'll skip these for now)
        if value_str.startswith('"') or value_str.startswith("'"):
            return None
        # Could be an expression - skip for now
        return None


def parse_range_comment(comment: str) -> Dict[str, Any]:
    """
    Parse range annotation from comment.

    Formats:
    - [5:50]        → min=5, max=50, step=1
    - [5:50:2]      → min=5, max=50, step=2
    - [1:2:50]      → min=1, max=50, step=2 (detect based on order)
    - ["a", "b"]    → options=["a", "b"]

    Args:
        comment: Comment text

    Returns:
        Dict with range information
    """
    result = {}

    # Match array/list notation
    bracket_match = re.search(r'\[([^\]]+)\]', comment)
    if not bracket_match:
        return result

    content = bracket_match.group(1).strip()

    # Check if it's a string list (dropdown options)
    if '"' in content or "'" in content:
        # Parse as options list
        options = [opt.strip(' "\'') for opt in content.split(',')]
        result["options"] = options
        return result

    # Parse as numeric range
    parts = [p.strip() for p in content.split(':')]

    if len(parts) == 2:
        # [min:max]
        try:
            result["min"] = float(parts[0])
            result["max"] = float(parts[1])
            result["step"] = 1
        except ValueError:
            pass

    elif len(parts) == 3:
        # Ambiguous: [min:max:step] or [min:step:max]?
        # Heuristic: if middle value is smaller, it's likely step
        try:
            nums = [float(p) for p in parts]
            if nums[1] < nums[0]:
                # [max:step:min] - unlikely
                result["min"] = nums[2]
                result["max"] = nums[0]
                result["step"] = nums[1]
            elif nums[1] < (nums[2] - nums[0]) / 2:
                # Middle value is small → probably step
                result["min"] = nums[0]
                result["max"] = nums[2]
                result["step"] = nums[1]
            else:
                # Standard [min:max:step]
                result["min"] = nums[0]
                result["max"] = nums[1]
                result["step"] = nums[2]
        except ValueError:
            pass

    return result


def parse_parameters_from_scad(code: str) -> List[Dict[str, Any]]:
    """
    Extract all parameters from OpenSCAD code.

    Args:
        code: OpenSCAD source code

    Returns:
        List of parameter metadata dicts
    """
    parameters = []

    for line in code.split('\n'):
        # Skip comments and empty lines
        if line.strip().startswith('//') or not line.strip():
            continue

        param = parse_parameter_line(line)
        if param:
            parameters.append(param)

    return parameters


def parameters_to_dict(
    parameters: List[Dict[str, Any]],
    essential_params: List[str] = None,
    max_params: int = 6
) -> Dict[str, Dict[str, Any]]:
    """
    Convert parameter list to dictionary keyed by parameter name.
    Adds sensible default ranges if not present.

    Args:
        parameters: List of parameter metadata
        essential_params: List of parameter names marked as essential by LLM
                         If None, shows all slider-capable params up to max_params
        max_params: Maximum number of parameters to return (default 6)

    Returns:
        Dict mapping parameter name to metadata
    """
    # Always-hidden patterns (internal/meta parameters)
    ALWAYS_HIDDEN = [
        # Labels/text (should never appear)
        "label", "text", "logo", "brand", "font",
        # Internal suffixes
        "_internal", "_calc", "_derived", "_temp",
        # Very small values likely internal
        "$fn", "$fa", "$fs",
    ]

    result = {}
    for p in parameters:
        name = p["name"]
        name_lower = name.lower()
        meta = {k: v for k, v in p.items() if k != "name"}

        # Skip always-hidden parameters
        is_hidden = any(pattern in name_lower for pattern in ALWAYS_HIDDEN)
        if is_hidden:
            continue

        # Determine if this is essential (LLM-decided or all if no list provided)
        if essential_params is not None:
            # Use LLM-provided categorization
            is_essential = name in essential_params or name_lower in [p.lower() for p in essential_params]
            meta["visibility"] = "essential" if is_essential else "advanced"
        else:
            # No LLM categorization - treat all as potentially essential
            meta["visibility"] = "essential"

        # Add default ranges if not present
        if "min" not in meta and "max" not in meta and "value" in meta:
            value = meta["value"]
            if isinstance(value, (int, float)) and value != 0:
                meta["min"] = max(0.1, value * 0.5)
                meta["max"] = value * 2.0
                meta["step"] = max(0.1, abs(value) * 0.05)
                meta["type"] = "slider"

        result[name] = meta

    # If LLM provided essential params, filter to only essential
    if essential_params is not None:
        result = {k: v for k, v in result.items() if v.get("visibility") == "essential"}

    # Limit to max_params (prioritize by order parsed)
    if len(result) > max_params:
        keys = list(result.keys())[:max_params]
        result = {k: result[k] for k in keys}

    return result


def categorize_parameters_with_llm(
    client,
    scad_code: str,
    design_description: str,
    model: str = "gpt-4o"
) -> Optional[List[str]]:
    """
    Ask the LLM to categorize which parameters are essential for user modification.

    Args:
        client: OpenAI client
        scad_code: The generated OpenSCAD code
        design_description: Description of what was designed
        model: Model to use for categorization

    Returns:
        List of parameter names that are essential for user modification
        Returns None to show all parameters if categorization fails
    """
    # Extract parameter names from code
    params = parse_parameters_from_scad(scad_code)
    if not params:
        return None  # None = show all params

    param_names = [p["name"] for p in params]

    # For simple cases with few params, just show all
    if len(param_names) <= 3:
        print(f"[Param] Only {len(param_names)} params, showing all: {param_names}")
        return None  # None = show all

    prompt = f"""Given this CAD design and its parameters, identify which parameters are ESSENTIAL for user customization.

DESIGN: {design_description}

PARAMETERS FOUND:
{', '.join(param_names)}

Return the parameter names that a user would want to modify to customize the basic size/shape.
- Essential = main dimensions that define the object's overall size
- Exclude internal calculations, decorations, small details

Respond with JSON object: {{"essential": ["param1", "param2"]}}"""

    try:
        response = client.chat.completions.create(
            model=model,
            temperature=0,
            response_format={"type": "json_object"},
            messages=[
                {"role": "system", "content": "You categorize CAD parameters. Return JSON: {\"essential\": [\"param_names\"]}"},
                {"role": "user", "content": prompt}
            ]
        )

        import json
        data = json.loads(response.choices[0].message.content)

        # Extract essential params from response
        essential = []
        if isinstance(data, dict):
            essential = data.get("essential", data.get("parameters", data.get("essential_params", [])))
        elif isinstance(data, list):
            essential = data

        print(f"[Param] LLM categorized essential: {essential}")

        # If LLM returned empty or invalid, show all params
        if not essential:
            print(f"[Param] LLM returned empty, showing all params")
            return None

        return essential

    except Exception as e:
        print(f"[Param] LLM categorization failed: {e}, showing all params")
        return None  # None = show all params


def generate_scad_with_ranges(
    parameters: Dict[str, Dict[str, Any]]
) -> str:
    """
    Generate OpenSCAD parameter definitions with range comments.

    Args:
        parameters: Dict of parameter metadata

    Returns:
        OpenSCAD code string
    """
    lines = []

    for name, meta in parameters.items():
        value = meta.get("value", 0)
        line = f"{name} = {value};"

        # Add range comment if available
        if "min" in meta and "max" in meta:
            min_val = meta["min"]
            max_val = meta["max"]
            step = meta.get("step", 1)

            if step == 1:
                line += f" //[{min_val}:{max_val}]"
            else:
                line += f" //[{min_val}:{max_val}:{step}]"

        elif "options" in meta:
            options = meta["options"]
            options_str = ", ".join(f'"{opt}"' for opt in options)
            line += f" //[{options_str}]"

        lines.append(line)

    return "\n".join(lines)


def update_parameter_value(code: str, param_name: str, new_value: float) -> str:
    """
    Update a parameter value in OpenSCAD code.

    Args:
        code: Original OpenSCAD code
        param_name: Parameter name to update
        new_value: New value

    Returns:
        Updated OpenSCAD code
    """
    lines = code.split('\n')
    updated_lines = []

    pattern = re.compile(rf'^\s*{re.escape(param_name)}\s*=\s*[^;]+;(.*)$')

    for line in lines:
        match = pattern.match(line)
        if match:
            # Preserve any comment
            comment = match.group(1)
            updated_line = f"{param_name} = {new_value};{comment}"
            updated_lines.append(updated_line)
        else:
            updated_lines.append(line)

    return '\n'.join(updated_lines)


def update_multiple_parameters(
    code: str,
    updates: Dict[str, float]
) -> str:
    """
    Update multiple parameter values in OpenSCAD code.

    Args:
        code: Original OpenSCAD code
        updates: Dict mapping parameter names to new values

    Returns:
        Updated OpenSCAD code
    """
    updated_code = code

    for param_name, new_value in updates.items():
        updated_code = update_parameter_value(updated_code, param_name, new_value)

    return updated_code
