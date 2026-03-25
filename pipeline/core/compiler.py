"""
CRAFT Compiler

This module compiles JSON CAD Plans into OpenSCAD code.

Key features:
- Preserves parametric expressions
- Generates clean, idiomatic OpenSCAD
- Handles all primitive types and operations defined in the schema
"""

import json
import re
from typing import Any, Dict, List, Optional
from .schema import extract_parameters, extract_parameter_metadata


def add_smart_parameter_ranges(params: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    """
    Add smart default ranges to parameters based on their names and values.

    Args:
        params: Dictionary of parameters (can be numbers or dicts with metadata)

    Returns:
        Dictionary with all parameters having range metadata
    """
    result = {}

    for name, value in params.items():
        # If already has metadata, keep it
        if isinstance(value, dict):
            result[name] = value.copy()
            continue

        # Otherwise, create metadata with smart ranges
        param_meta = {"value": value}

        # Determine range based on parameter name and value
        name_lower = name.lower()

        # Dimensions (width, height, length, depth, diameter, radius)
        if any(keyword in name_lower for keyword in ['width', 'height', 'length', 'depth', 'size', 'w', 'h', 'l', 'd']):
            param_meta["min"] = max(1, value * 0.2)  # 20% of original
            param_meta["max"] = value * 3  # 300% of original
            param_meta["step"] = 1 if value >= 10 else 0.5

        # Diameter or radius
        elif any(keyword in name_lower for keyword in ['diameter', 'radius', 'dia', 'rad', 'r']):
            param_meta["min"] = max(1, value * 0.3)
            param_meta["max"] = value * 3
            param_meta["step"] = 1 if value >= 10 else 0.5

        # Thickness or wall thickness
        elif any(keyword in name_lower for keyword in ['thick', 'wall', 't']):
            param_meta["min"] = max(0.5, value * 0.5)
            param_meta["max"] = value * 5
            param_meta["step"] = 0.5

        # Pitch or thread
        elif any(keyword in name_lower for keyword in ['pitch', 'thread']):
            param_meta["min"] = max(0.1, value * 0.5)
            param_meta["max"] = value * 3
            param_meta["step"] = 0.1 if value < 5 else 0.25

        # Angle
        elif 'angle' in name_lower:
            param_meta["min"] = 0
            param_meta["max"] = 360
            param_meta["step"] = 5

        # Count or number
        elif any(keyword in name_lower for keyword in ['count', 'num', 'n']):
            param_meta["min"] = 1
            param_meta["max"] = max(20, value * 2)
            param_meta["step"] = 1

        # Default range for unknown parameters
        else:
            param_meta["min"] = max(0.1, value * 0.1)
            param_meta["max"] = value * 5
            param_meta["step"] = 1 if value >= 10 else 0.5

        result[name] = param_meta

    return result


# =============================================================================
# PROMPTS
# =============================================================================

COMPILER_SYSTEM_PROMPT = """You are an OpenSCAD COMPILER. Convert JSON CAD plans into clean OpenSCAD code.

CRITICAL REQUIREMENT - GENERATE COMPLETE GEOMETRY FOR KB COMPONENTS:
When Knowledge Base (KB) components are provided (marked as [MANDATORY]):
- You MUST generate COMPLETE, DETAILED, SELF-CONTAINED geometry for each component
- DO NOT just copy KB module code - it has external dependencies that won't work
- Instead, CREATE your own module that produces realistic geometry based on the KB specifications
- The final render MUST show recognizable, detailed components (not just boxes/cylinders)

COMPONENT-SPECIFIC GEOMETRY REQUIREMENTS:

**FANS (axial fans, cooling fans):**
- Frame: Square outer frame with rounded corners, mounting holes at corners
- Hub: Central cylinder where blades attach
- Blades: 5-9 curved/angled blades radiating from hub (USE HULL BETWEEN SHAPES or linear_extrude)
- Example blade pattern:
  ```
  module fan_blade() {
    hull() {
      translate([hub_r, 0, 0]) cylinder(r=2, h=blade_h);
      translate([frame_size/2-5, 0, blade_h/2]) rotate([0, 15, 0]) cylinder(r=3, h=blade_h);
    }
  }
  for (i = [0:num_blades-1]) rotate([0, 0, i*360/num_blades]) fan_blade();
  ```
- NEVER make a fan without visible blades - that defeats the purpose!

**NEMA STEPPER MOTORS (NEMA17, NEMA23, etc.):**
- Body: Square cross-section cylinder/cube with rounded edges
- Faceplate: Circular front plate with mounting holes at corners
- Shaft: Cylindrical shaft protruding from center (typically 5mm diameter)
- Back: Rear circular or square cap
- Include: 4 corner mounting holes, central pilot hole
- NEMA17: 42.3mm square, various lengths (34-48mm common)

**SERVO MOTORS:**
- Body: Rectangular main body
- Output shaft: Cylinder on top with splines/horn
- Mounting tabs: Flanges on sides with holes
- Cable: Optional wire bundle from back

**BRACKETS/MOUNTS:**
- Should have: Mounting holes, proper thickness (2-5mm typical)
- L-brackets: Two perpendicular faces with holes
- Plates: Flat with hole patterns matching components

GENERAL REQUIREMENTS:
1. Define ALL parameters at the top as OpenSCAD variables
2. Implement each base_shape from the plan
3. Apply operations in the specified sequence
4. Use proper OpenSCAD syntax

PARAMETER HANDLING:
- When a value is a NUMBER, output it directly: radius = 40;
- When a value is a STRING, output it as an expression: radius = W/2;
- Preserve all parametric expressions exactly as written
- If parameter has "min" and "max" fields, add range comment: param = value; //[min:max]
- If parameter has "min", "max", and "step", add: param = value; //[min:max:step]
- Example: head_width = 10; //[5:50] or height = 100; //[50:200:10]

SHAPE MAPPING:
- box → cube([x, y, z])
- cylinder → cylinder(h=height, r=radius) or cylinder(h=height, r1=radius, r2=radius2)
- sphere → sphere(r=radius)
- cone → cylinder(h=height, r1=radius, r2=0) or use radius2 if specified
- torus → rotate_extrude() circle(r=minor_radius); translate([major_radius, 0, 0])
- linear_extrude → linear_extrude(height=h) profile_2d();
- rotate_extrude → rotate_extrude() profile_2d();

OPERATION MAPPING:
- union → union() { ... }
- difference → difference() { ... }
- intersection → intersection() { ... }
- translate → translate([x, y, z]) ...
- rotate → rotate([x, y, z]) ... or rotate(a=angle, v=[axis])
- scale → scale([x, y, z]) ... or scale(uniform) ...
- mirror → mirror([x, y, z]) ...
- hull → hull() { ... }

AVOID THESE EXPENSIVE OPERATIONS:
- DO NOT use minkowski() - it causes extreme slowdowns and render timeouts
- DO NOT use hull() on more than 3-4 simple shapes
- DO NOT set $fn > 64 when combined with boolean operations
- For rounded edges, use offset() on 2D profiles before extrude, or simply omit fillets

POSITIONING:
- If a shape has "position", wrap it: translate([x, y, z]) shape();
- If a shape has "rotation", wrap it: rotate([x, y, z]) shape();
- Apply in order: translate(position) rotate(rotation) shape();

COLOR AND MATERIAL RENDERING:
IMPORTANT: Apply realistic colors to make renders look professional and visually distinct.
- Use color() to differentiate components based on their material and type
- Choose colors that match real-world engineering materials:

Material-based colors (pick based on context):
- Aluminum/metal brackets: color("Silver") or color([0.75, 0.75, 0.77])
- Steel parts: color("DimGray") or color([0.4, 0.4, 0.43])
- Black anodized aluminum: color([0.15, 0.15, 0.17])
- Motors (NEMA/stepper): body=color("Black") or color([0.1, 0.1, 0.12]), shaft=color("Silver")
- Fans: frame=color([0.12, 0.12, 0.14]), blades=color([0.2, 0.2, 0.22]) or accent color
- Servo motors: body=color([0.15, 0.2, 0.35]) (dark blue), output horn=color("White")
- PCBs: color([0.0, 0.4, 0.2]) (green) or color([0.1, 0.1, 0.6]) (blue)
- 3D printed PLA: color([0.85, 0.85, 0.8]) (off-white) or use vibrant colors
- Rubber/elastomers: color([0.2, 0.2, 0.2])
- Brass: color([0.8, 0.6, 0.2])
- Copper: color([0.72, 0.45, 0.2])

Component-specific defaults:
- Main structural parts: darker, neutral colors
- Mounting brackets: silver/aluminum look
- Moving parts: slight contrast from static parts
- Accent parts (knobs, buttons): can use brighter colors

Apply colors at the module/component level, not individual primitives.
Each distinct component should have its own color for visual clarity.

CODE STYLE:
- Use consistent indentation (2 or 4 spaces)
- Group related geometry
- Add minimal comments for clarity
- Use $fn for smooth curves where appropriate

OUTPUT: Only valid OpenSCAD code. No markdown fences, no explanations."""


COMPILER_USER_TEMPLATE = """Compile this CAD plan to OpenSCAD:

{plan_json}
{kb_code_section}

Generate complete, working OpenSCAD code."""


# =============================================================================
# CODE CLEANING UTILITIES
# =============================================================================

def strip_to_scad(code: str) -> str:
    """
    Strip markdown fences and clean OpenSCAD code.
    
    Args:
        code: Raw code string possibly with markdown
        
    Returns:
        Clean OpenSCAD code
    """
    # Remove markdown code fences
    match = re.search(r"```(?:scad|openscad)?\s*([\s\S]*?)```", code, flags=re.IGNORECASE)
    if match:
        code = match.group(1)
    
    # Clean up artifacts
    code = code.strip().strip("`")
    code = re.sub(r"\bopenscad\b", "", code, flags=re.IGNORECASE)
    code = re.sub(r'^[\s;#]*```.*?$', '', code, flags=re.MULTILINE)
    
    return code.strip()


def format_value(value: Any) -> str:
    """
    Format a value for OpenSCAD output.
    
    Args:
        value: Number, string expression, or other value
        
    Returns:
        Formatted string for OpenSCAD
    """
    if isinstance(value, str):
        # It's an expression, output as-is
        return value
    elif isinstance(value, bool):
        return "true" if value else "false"
    elif isinstance(value, (int, float)):
        # Format number (avoid scientific notation for small numbers)
        if isinstance(value, float) and value == int(value):
            return str(int(value))
        return str(value)
    elif isinstance(value, list):
        # Format as array
        formatted = [format_value(v) for v in value]
        return "[" + ", ".join(formatted) + "]"
    else:
        return str(value)


# =============================================================================
# COMPILER CLASS
# =============================================================================

class Compiler:
    """Compiles JSON CAD Plans to OpenSCAD code."""
    
    def __init__(self, client, model: str = "gpt-4o"):
        """
        Initialize the compiler.
        
        Args:
            client: OpenAI client instance
            model: Model to use for compilation
        """
        self.client = client
        self.model = model
    
    def compile(
        self,
        plan: Dict[str, Any],
        kb_components: List[Any] = None
    ) -> str:
        """
        Compile a JSON CAD plan to OpenSCAD code.
        
        Args:
            plan: Valid JSON CAD plan
            kb_components: Optional list of KBComponentContext objects for code injection
            
        Returns:
            OpenSCAD code string
        """
        plan_json = json.dumps(plan, indent=2)
        
        # Build KB code injection section based on confidence
        kb_code_section = self._build_kb_code_section(kb_components) if kb_components else ""
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0,
                messages=[
                    {"role": "system", "content": COMPILER_SYSTEM_PROMPT},
                    {"role": "user", "content": COMPILER_USER_TEMPLATE.format(
                        plan_json=plan_json,
                        kb_code_section=kb_code_section
                    )}
                ]
            )
            
            code = response.choices[0].message.content.strip()
            return strip_to_scad(code)
            
        except Exception as e:
            # Fallback: generate basic code from plan directly
            return self._fallback_compile(plan, str(e))
    
    def _build_kb_code_section(self, kb_components: List[Any]) -> str:
        """
        Build KB component specifications section.

        IMPORTANT: KB module code often has external dependencies (include/use statements,
        data tables) that won't work if copied directly. Instead, we provide SPECIFICATIONS
        that the LLM uses to GENERATE complete, self-contained geometry.

        Args:
            kb_components: List of KBComponentContext objects

        Returns:
            Formatted string for inclusion in compiler prompt
        """
        if not kb_components:
            return ""

        sections = []
        sections.append("\n## MANDATORY COMPONENT SPECIFICATIONS:")
        sections.append("="*60)
        sections.append("CRITICAL: Generate COMPLETE, DETAILED geometry for these components.")
        sections.append("DO NOT copy the reference code - it has external dependencies.")
        sections.append("Instead, CREATE self-contained modules based on the specifications below.")
        sections.append("="*60 + "\n")

        # Separate mandatory (PRIMARY/SECONDARY) from optional (ATTACHMENT)
        mandatory_components = []
        optional_components = []

        for kb_comp in kb_components:
            role = getattr(kb_comp, 'role', 'primary')
            role_upper = role.upper() if isinstance(role, str) else str(role).upper()
            if role_upper in ("PRIMARY", "SECONDARY"):
                mandatory_components.append(kb_comp)
            else:
                optional_components.append(kb_comp)

        # List mandatory components
        if mandatory_components:
            sections.append("### MANDATORY COMPONENTS (MUST BE VISIBLE):")
            component_names = [getattr(c, 'component_name', getattr(c, 'module_name', 'unknown'))
                             for c in mandatory_components]
            sections.append(f"You MUST create detailed geometry for: {', '.join(component_names)}")
            sections.append("These are the ESSENTIAL parts the user requested!\n")

        # Check if this is a multi-component assembly
        is_assembly = len(kb_components) > 1
        if is_assembly:
            sections.append("### ASSEMBLY STRUCTURE:")
            sections.append("Multiple components detected - they must physically connect!")
            sections.append("")
            sections.append("ASSEMBLY RULES:")
            sections.append("1. Place PRIMARY component at origin [0,0,0]")
            sections.append("2. SECONDARY components attach to PRIMARY")
            sections.append("3. Add bracket/mount to connect them")
            sections.append("4. NO FLOATING PARTS - everything must be connected")
            sections.append("")

        # Process each component
        for kb_comp in kb_components:
            module_name = getattr(kb_comp, 'module_name', 'unknown')
            component_name = getattr(kb_comp, 'component_name', module_name)
            description = getattr(kb_comp, 'description', '')
            role = getattr(kb_comp, 'role', 'primary')
            priority = getattr(kb_comp, 'priority', 1)
            parameters = getattr(kb_comp, 'parameters', [])

            role_upper = role.upper() if isinstance(role, str) else str(role).upper()
            is_mandatory = role_upper in ("PRIMARY", "SECONDARY")
            tag = "[MANDATORY]" if is_mandatory else "[OPTIONAL]"

            sections.append(f"### {tag} [{role_upper}] {component_name}")

            # Add component-specific geometry guidance
            module_lower = module_name.lower()

            if 'fan' in module_lower:
                sections.append("Component Type: AXIAL FAN")
                sections.append("REQUIRED GEOMETRY (must all be present):")
                sections.append("  1. Frame: Square outer frame with corner mounting holes")
                sections.append("  2. Hub: Central cylinder (about 40% of frame width)")
                sections.append("  3. Blades: 7 curved blades radiating from hub - USE HULL!")
                sections.append("     Example blade:")
                sections.append("     ```")
                sections.append("     module blade(h, hub_r, outer_r) {")
                sections.append("       hull() {")
                sections.append("         translate([hub_r+2, 0, 0]) cylinder(r=2, h=h, $fn=12);")
                sections.append("         translate([outer_r-3, 3, h*0.3]) rotate([0,10,15])")
                sections.append("           cylinder(r=2.5, h=h*0.7, $fn=12);")
                sections.append("       }")
                sections.append("     }")
                sections.append("     for(i=[0:6]) rotate([0,0,i*360/7]) blade(...);")
                sections.append("     ```")
                sections.append("  4. Motor mount: Ring around hub")
                sections.append("IMPORTANT: A fan WITHOUT BLADES is WRONG! Blades are essential.")

            elif 'nema' in module_lower or 'stepper' in module_lower:
                sections.append("Component Type: NEMA STEPPER MOTOR")
                sections.append("REQUIRED GEOMETRY:")
                sections.append("  1. Body: Square profile (42.3mm for NEMA17), length varies")
                sections.append("  2. Faceplate: Circular raised section on front")
                sections.append("  3. Shaft: 5mm diameter, 20-24mm length, protruding from center")
                sections.append("  4. Mounting holes: 4 corners, M3 (31mm spacing for NEMA17)")
                sections.append("  5. Rear cap: Can be simplified cylinder")
                sections.append("Typical dimensions: 42.3x42.3x40mm body, 5mm shaft")

            elif 'servo' in module_lower:
                sections.append("Component Type: SERVO MOTOR")
                sections.append("REQUIRED GEOMETRY:")
                sections.append("  1. Body: Rectangular main housing")
                sections.append("  2. Output shaft: Cylinder with gear teeth/splines")
                sections.append("  3. Mounting tabs: Side flanges with holes")
                sections.append("  4. Wire channel: Optional rear opening")

            elif 'bracket' in module_lower or 'mount' in module_lower:
                sections.append("Component Type: MOUNTING BRACKET")
                sections.append("REQUIRED GEOMETRY:")
                sections.append("  1. Plate(s): 2-4mm thick material")
                sections.append("  2. Mounting holes: Match component patterns")
                sections.append("  3. Structural support if L-shaped")

            else:
                # Generic component
                sections.append(f"Description: {description or 'Custom component'}")
                sections.append("Generate appropriate detailed geometry based on component type.")

            # Add parameter info
            if parameters:
                sections.append("\nDimensions from KB:")
                for param in parameters[:8]:  # Limit to avoid overwhelming
                    pname = param.get('name', 'unknown')
                    pdefault = param.get('default', '')
                    if pdefault:
                        sections.append(f"  - {pname} = {pdefault}")

            sections.append("")

        # Assembly instructions
        sections.append("\n### FINAL ASSEMBLY:")
        sections.append("="*60)
        sections.append("Your output MUST include:")
        for mc in mandatory_components:
            mc_name = getattr(mc, 'component_name', getattr(mc, 'module_name', 'unknown'))
            mc_mod = getattr(mc, 'module_name', mc_name)
            sections.append(f"  [X] module {mc_mod}() with COMPLETE detailed geometry")
        sections.append("  [X] module assembly() that combines all parts")
        sections.append("  [X] assembly(); call at the end")
        sections.append("="*60)
        sections.append("")
        sections.append("EXAMPLE STRUCTURE:")
        sections.append("```openscad")
        sections.append("// Parameters")
        sections.append("motor_size = 42.3;")
        sections.append("motor_length = 40;")
        sections.append("fan_size = 40;")
        sections.append("")
        sections.append("// NEMA motor - complete geometry")
        sections.append("module NEMA() {")
        sections.append("  color(\"Black\") {")
        sections.append("    // Body")
        sections.append("    cube([motor_size, motor_size, motor_length], center=true);")
        sections.append("    // Faceplate")
        sections.append("    translate([0,0,motor_length/2]) cylinder(d=22, h=2, $fn=32);")
        sections.append("    // Shaft")
        sections.append("    color(\"Silver\") translate([0,0,motor_length/2])")
        sections.append("      cylinder(d=5, h=20, $fn=16);")
        sections.append("  }")
        sections.append("}")
        sections.append("")
        sections.append("// Fan - MUST have visible blades!")
        sections.append("module fan() {")
        sections.append("  color([0.15,0.15,0.17]) {")
        sections.append("    // Frame")
        sections.append("    difference() {")
        sections.append("      cube([fan_size, fan_size, 10], center=true);")
        sections.append("      cylinder(d=fan_size-4, h=12, center=true, $fn=32);")
        sections.append("    }")
        sections.append("    // Hub")
        sections.append("    cylinder(d=15, h=8, center=true, $fn=24);")
        sections.append("    // Blades - 7 curved blades")
        sections.append("    for(i=[0:6]) rotate([0,0,i*360/7])")
        sections.append("      hull() {")
        sections.append("        translate([9,0,-3]) cylinder(r=2, h=6, $fn=8);")
        sections.append("        translate([17,4,0]) rotate([0,12,20]) cylinder(r=2.5, h=5, $fn=8);")
        sections.append("      }")
        sections.append("  }")
        sections.append("}")
        sections.append("")
        sections.append("// Bracket")
        sections.append("module bracket() {")
        sections.append("  color(\"Silver\") difference() {")
        sections.append("    cube([motor_size, motor_size, 3], center=true);")
        sections.append("    cylinder(d=24, h=5, center=true, $fn=32);")
        sections.append("  }")
        sections.append("}")
        sections.append("")
        sections.append("// Assembly")
        sections.append("module assembly() {")
        sections.append("  NEMA();")
        sections.append("  translate([0,0,motor_length/2+1.5]) bracket();")
        sections.append("  translate([0,0,motor_length/2+15]) fan();")
        sections.append("}")
        sections.append("assembly();")
        sections.append("```")
        sections.append("")
        sections.append("CRITICAL: Fans MUST have blades. Motors MUST have shafts. No oversimplified boxes!")

        return "\n".join(sections)
    
    def _fallback_compile(self, plan: Dict[str, Any], error: str = "") -> str:
        """
        Fallback compilation using direct translation.
        
        This is a simple, rule-based compiler for when the LLM fails.
        """
        lines = []
        
        # Add error comment if applicable
        if error:
            lines.append(f"// Fallback compilation (LLM error: {error[:50]})")
            lines.append("")
        
        # Parameters with range annotations
        # Add smart ranges if not already present
        raw_params = plan.get("parameters", {})
        params_with_ranges = add_smart_parameter_ranges(raw_params)

        if params_with_ranges:
            lines.append("// Parameters")
            for name, meta in params_with_ranges.items():
                value = meta.get("value", 0)
                param_line = f"{name} = {format_value(value)};"

                # Add range comment if available
                if "min" in meta and "max" in meta:
                    min_val = meta["min"]
                    max_val = meta["max"]
                    step = meta.get("step", 1)

                    if step == 1:
                        param_line += f" //[{min_val}:{max_val}]"
                    else:
                        param_line += f" //[{min_val}:{max_val}:{step}]"

                elif "options" in meta:
                    options = meta["options"]
                    options_str = ", ".join(f'"{opt}"' for opt in options)
                    param_line += f" //[{options_str}]"

                lines.append(param_line)
            lines.append("")
        
        # Generate modules for base shapes
        shapes = plan.get("geometry", {}).get("base_shapes", [])
        for shape in shapes:
            lines.extend(self._compile_shape(shape))
            lines.append("")
        
        # Generate operations
        operations = plan.get("geometry", {}).get("operations", [])
        for op in operations:
            lines.extend(self._compile_operation(op))
            lines.append("")
        
        # Final output
        final_output = plan.get("final_output", "")
        if final_output:
            lines.append(f"// Final output")
            lines.append(f"{final_output}();")
        
        return "\n".join(lines)
    
    def _compile_shape(self, shape: Dict[str, Any]) -> List[str]:
        """Compile a single base shape to OpenSCAD."""
        lines = []
        shape_id = shape.get("id", "shape")
        shape_type = shape.get("type", "box")
        
        lines.append(f"module {shape_id}() {{")
        
        # Build the geometry string
        geom = self._shape_to_scad(shape)
        
        # Handle position and rotation
        position = shape.get("position")
        rotation = shape.get("rotation")
        
        indent = "    "
        if position:
            pos_str = format_value(position)
            lines.append(f"{indent}translate({pos_str})")
            indent += "    "
        
        if rotation:
            rot_str = format_value(rotation)
            lines.append(f"{indent}rotate({rot_str})")
            indent += "    "
        
        lines.append(f"{indent}{geom}")
        lines.append("}")
        
        return lines
    
    def _shape_to_scad(self, shape: Dict[str, Any]) -> str:
        """Convert a shape definition to OpenSCAD primitive call."""
        shape_type = shape.get("type", "box")
        center = shape.get("center", False)
        
        if shape_type == "box":
            size = shape.get("size", [10, 10, 10])
            size_str = format_value(size)
            center_str = ", center=true" if center else ""
            return f"cube({size_str}{center_str});"
        
        elif shape_type == "cylinder":
            height = shape.get("height", 10)
            radius = shape.get("radius", 5)
            center_str = ", center=true" if center else ""
            return f"cylinder(h={format_value(height)}, r={format_value(radius)}{center_str});"
        
        elif shape_type == "sphere":
            radius = shape.get("radius", 5)
            return f"sphere(r={format_value(radius)});"
        
        elif shape_type == "cone":
            height = shape.get("height", 10)
            radius = shape.get("radius", 5)
            radius2 = shape.get("radius2", 0)
            center_str = ", center=true" if center else ""
            return f"cylinder(h={format_value(height)}, r1={format_value(radius)}, r2={format_value(radius2)}{center_str});"
        
        elif shape_type == "torus":
            # Torus needs special handling
            radius = shape.get("radius", 10)  # Major radius
            # Minor radius might be in profile or as a separate field
            profile = shape.get("profile", {})
            minor_r = profile.get("radius", 3)
            return f"rotate_extrude() translate([{format_value(radius)}, 0, 0]) circle(r={format_value(minor_r)});"
        
        elif shape_type == "linear_extrude":
            height = shape.get("height", 10)
            profile = shape.get("profile", {})
            profile_str = self._profile_to_scad(profile)
            return f"linear_extrude(height={format_value(height)}) {profile_str}"
        
        elif shape_type == "rotate_extrude":
            profile = shape.get("profile", {})
            profile_str = self._profile_to_scad(profile)
            return f"rotate_extrude() {profile_str}"
        
        else:
            return f"// Unknown shape type: {shape_type}"
    
    def _profile_to_scad(self, profile: Dict[str, Any]) -> str:
        """Convert a 2D profile to OpenSCAD."""
        profile_type = profile.get("type", "circle")
        
        if profile_type == "circle":
            radius = profile.get("radius", 5)
            return f"circle(r={format_value(radius)});"
        
        elif profile_type == "square":
            size = profile.get("size", [10, 10])
            size_str = format_value(size)
            return f"square({size_str});"
        
        elif profile_type == "polygon":
            points = profile.get("points", [[0, 0], [10, 0], [5, 10]])
            points_str = format_value(points)
            return f"polygon(points={points_str});"

        else:
            # Text profiles are not supported - use a placeholder circle
            return f"circle(r=5); // Unknown profile type: {profile_type}"
    
    def _compile_operation(self, op: Dict[str, Any]) -> List[str]:
        """Compile an operation to OpenSCAD."""
        lines = []
        op_id = op.get("id", "op")
        op_type = op.get("type", "union")
        target = op.get("target", "")
        with_refs = op.get("with", [])
        params = op.get("params", {})
        
        lines.append(f"module {op_id}() {{")
        
        if op_type in {"union", "difference", "intersection", "hull", "minkowski"}:
            # Boolean/combining operations
            lines.append(f"    {op_type}() {{")
            lines.append(f"        {target}();")
            if isinstance(with_refs, list):
                for ref in with_refs:
                    lines.append(f"        {ref}();")
            elif isinstance(with_refs, str):
                lines.append(f"        {with_refs}();")
            lines.append("    }")
        
        elif op_type == "translate":
            vector = params.get("vector", [0, 0, 0])
            vector_str = format_value(vector)
            if isinstance(target, list):
                lines.append(f"    translate({vector_str}) {{")
                for t in target:
                    lines.append(f"        {t}();")
                lines.append("    }")
            else:
                lines.append(f"    translate({vector_str}) {target}();")
        
        elif op_type == "rotate":
            if "vector" in params:
                vector = params.get("vector", [0, 0, 0])
                vector_str = format_value(vector)
                rot_call = f"rotate({vector_str})"
            else:
                angle = params.get("angle", 0)
                axis = params.get("axis", [0, 0, 1])
                rot_call = f"rotate(a={format_value(angle)}, v={format_value(axis)})"
            
            if isinstance(target, list):
                lines.append(f"    {rot_call} {{")
                for t in target:
                    lines.append(f"        {t}();")
                lines.append("    }")
            else:
                lines.append(f"    {rot_call} {target}();")
        
        elif op_type == "scale":
            if "vector" in params:
                vector = params.get("vector", [1, 1, 1])
                scale_str = format_value(vector)
            else:
                uniform = params.get("uniform", 1)
                scale_str = format_value(uniform)
            
            if isinstance(target, list):
                lines.append(f"    scale({scale_str}) {{")
                for t in target:
                    lines.append(f"        {t}();")
                lines.append("    }")
            else:
                lines.append(f"    scale({scale_str}) {target}();")
        
        elif op_type == "mirror":
            vector = params.get("vector", [1, 0, 0])
            vector_str = format_value(vector)
            if isinstance(target, list):
                lines.append(f"    mirror({vector_str}) {{")
                for t in target:
                    lines.append(f"        {t}();")
                lines.append("    }")
            else:
                lines.append(f"    mirror({vector_str}) {target}();")
        
        else:
            lines.append(f"    // Unknown operation type: {op_type}")
            lines.append(f"    {target}();")
        
        lines.append("}")
        
        return lines


# =============================================================================
# CONVENIENCE FUNCTION
# =============================================================================

def compile_plan(
    client,
    plan: Dict[str, Any],
    model: str = "gpt-4o",
    kb_components: List[Any] = None
) -> str:
    """
    Convenience function to compile a CAD plan to OpenSCAD.
    
    Args:
        client: OpenAI client
        plan: Valid JSON CAD plan
        model: Model to use
        kb_components: Optional list of KBComponentContext objects
        
    Returns:
        OpenSCAD code string
    """
    compiler = Compiler(client, model)
    return compiler.compile(plan, kb_components=kb_components)


def compile_plan_fallback(plan: Dict[str, Any]) -> str:
    """
    Compile using only the fallback (no LLM).
    
    Useful for testing or when LLM is unavailable.
    """
    compiler = Compiler(None)
    return compiler._fallback_compile(plan)
