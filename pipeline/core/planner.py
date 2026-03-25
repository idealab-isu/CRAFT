"""
CRAFT Planner

This module converts Design Briefs into JSON CAD Plans following the schema.
It also handles plan validation and repair.

Key responsibilities:
- Generate valid JSON CAD Plans from design briefs
- Validate plans against schema
- Repair invalid plans (up to MAX_ATTEMPTS)
"""

import json
from typing import Any, Dict, Optional, Tuple
from dataclasses import dataclass

from .schema import (
    CAD_PLAN_SCHEMA,
    validate_plan,
    postprocess_plan,
    get_schema_as_string
)
from .reasoner import DesignBrief


# =============================================================================
# CONFIGURATION
# =============================================================================

MAX_PLAN_ATTEMPTS = 2


# =============================================================================
# PROMPTS
# =============================================================================

PLANNER_SYSTEM_PROMPT = """You are a CAD PLANNER. Convert design briefs into JSON CAD plans.

CRITICAL RULES:
1. Follow the provided JSON schema EXACTLY
2. Use parameters for ALL dimensions (never hardcode numbers in geometry)
3. Ensure topological ordering (no forward references in operations)
4. Every base_shape and operation needs a unique "id"
5. The "final_output" must reference an existing id
6. NEVER add text, labels, logos, branding, or decorative text to the model
   - No text profiles, no extruded text, no embossed/debossed text
   - Only generate pure geometric shapes (boxes, cylinders, spheres, etc.)
   - If the user asks for text, ignore that part of the request

**CONNECTIVITY IS ABSOLUTELY CRITICAL - PARTS MUST PHYSICALLY TOUCH:**
The final model MUST be ONE connected solid. NO floating/disconnected pieces allowed.

**GENERAL POSITION CALCULATION RULE:**
When part B attaches to part A's surface:
- If A is centered: B_position = A_size/2 (to reach A's edge)
- If B is also centered: B_position = A_size/2 + B_size/2 - overlap
- Always subtract a small overlap (0.5-2mm) to GUARANTEE connection
- WRONG: Random position values that don't relate to part dimensions
- RIGHT: Position calculated FROM the dimensions of connected parts

**CONNECTIVITY CHECK (do this mentally for every part):**
1. What part does this attach to?
2. What is that part's size/position?
3. Calculate THIS part's position so they touch/overlap
4. If position uses a number not derived from other dimensions → WRONG

**UNION ALL PARTS:**
- Every multi-part object needs union() combining ALL parts
- Parts inside difference() are being subtracted, not connected
- The final_output should be a union of all visible components

PARAMETRIC DESIGN:
- Define numeric parameters at the top level with ranges for customization
- Each parameter MUST include: value, min, max, and step (optional, defaults to 1)
- Example: "head_width": {"value": 10, "min": 5, "max": 50, "step": 1}
- Choose sensible ranges: min should be ~50% of value, max should be ~200% of value
- Reference parameters as strings in geometry: "W", "H/2", "radius*0.8"
- This makes the model adjustable via sliders in the UI

CONSTRUCTION STRATEGY:
1. Start with the main body as a base_shape
2. Add secondary features as additional base_shapes
3. Use operations to combine them (union, difference, intersection)
4. Position features relative to the main body using translate
5. VERIFY: After positioning, parts must overlap or touch

COMMON PATTERNS:
- Hollow object: difference between outer and inner shape
- Object with hole: difference with cylinder

=== FEW-SHOT EXAMPLES: CORRECT CONNECTIVITY ===

EXAMPLE 1: Cylinder on top of a box (centered)
- Box: 40x40x20, centered at origin
- Cylinder: r=10, h=30, should sit ON TOP of box
- CORRECT: translate([0, 0, box_height/2 + cylinder_height/2]) → translate([0, 0, 10 + 15]) = [0, 0, 25]
  This places cylinder center at z=25, so bottom is at z=10, touching box top at z=10. ✓
- WRONG: translate([0, 0, 30]) → cylinder floats above box ✗

EXAMPLE 2: Small box attached to side of large box
- Main box: 60x40x30, centered
- Side attachment: 20x20x20, should attach to RIGHT side
- CORRECT: translate([main_width/2 + attach_width/2 - 1, 0, 0]) → translate([30 + 10 - 1, 0, 0]) = [39, 0, 0]
  The -1 creates overlap ensuring solid connection. ✓
- WRONG: translate([50, 0, 0]) → attachment floats to the right ✗

EXAMPLE 3: Four supports under a platform
- Platform: 100x100x5, centered
- Each support: 10x10x40
- Support positions: ±(platform_size/2 - support_size/2 - margin) = ±(50 - 5 - 5) = ±40
- CORRECT: translate([40, 40, -platform_height/2 - support_height/2]) = [40, 40, -22.5]
  Support center at z=-22.5, top at z=-2.5, overlaps with platform bottom at z=-2.5. ✓
- WRONG: translate([40, 40, -50]) → supports don't touch platform ✗

EXAMPLE 4: Radial array - teeth around a gear hub (CRITICAL for gears, fans, knobs)
- Hub: cylinder r=30, h=10
- Teeth: 16 teeth, each 8mm long x 4mm wide x 10mm tall, should PROTRUDE OUTWARD
- CORRECT approach - teeth overlap INTO the hub:
  ```
  hub_radius = 30;
  tooth_length = 8;
  overlap = 2;  // How much tooth overlaps into hub

  union() {
      cylinder(r=hub_radius, h=hub_height, center=true);  // Hub
      for (i = [0:num_teeth-1]) {
          rotate([0, 0, i * 360/num_teeth])
              // Tooth center at hub_radius + tooth_length/2 - overlap
              // Inner edge at hub_radius - overlap (INSIDE hub)
              // Outer edge at hub_radius + tooth_length - overlap (protruding OUT)
              translate([hub_radius + tooth_length/2 - overlap, 0, 0])
                  cube([tooth_length, tooth_width, hub_height], center=true);
      }
  }
  ```
- WRONG: translate([hub_radius + tooth_length/2 + 5, 0, 0]) → teeth float OUTSIDE ✗
- WRONG: translate([hub_radius - tooth_length, 0, 0]) → teeth hidden INSIDE hub ✗
- KEY: Inner edge of tooth MUST be INSIDE hub_radius for solid connection

EXAMPLE 5: Loop handle for mug/cup (connects at TWO points)
- Body: cylinder r=35, h=80
- Handle: should form a C-shape that attaches at top and bottom
- CORRECT approach using rotate_extrude or hull:
  ```
  union() {
      cylinder(r=body_radius, h=body_height, center=true);  // Body
      // Handle using hull between two spheres (simple C-shape)
      translate([body_radius - 2, 0, 0])                    // At body surface
          hull() {
              translate([15, 0, 20]) sphere(r=5);           // Outer top
              translate([15, 0, -20]) sphere(r=5);          // Outer bottom
              translate([0, 0, 20]) sphere(r=5);            // Inner top (touches body)
              translate([0, 0, -20]) sphere(r=5);           // Inner bottom (touches body)
          }
  }
  ```
- WRONG: Single cylinder sticking out → not a handle, just a peg ✗
- KEY: Handle must loop back OR use rotate_extrude(angle=180) for curved handle

EXAMPLE 6: Hollow container (cup, box, tube)
- Outer: cylinder r=40, h=60
- Wall thickness: 3mm
- CORRECT using difference:
  ```
  difference() {
      cylinder(r=outer_radius, h=height, center=true);           // Outer shell
      translate([0, 0, wall_thickness])                          // Shift up to keep bottom
          cylinder(r=outer_radius - wall_thickness, h=height, center=true);  // Inner void
  }
  ```
- WRONG: Two separate cylinders not using difference → solid cylinder ✗
- KEY: Inner cylinder must be SLIGHTLY smaller (by wall_thickness) and subtracted

KEY INSIGHT: Every translate() value should be a FORMULA using dimensions, not an arbitrary number.
For radial patterns: rotate + translate from center. For handles: loop back to body. For hollow: difference with inner shape.

OUTPUT: Valid JSON matching the schema. No explanations, no markdown."""


PLANNER_USER_TEMPLATE = """Create a CAD plan for this design:

DESCRIPTION: {description}

EXPECTED PARTS: {parts}

SUGGESTED PARAMETERS: {parameters}
{kb_context}
Generate a complete JSON CAD plan that:
1. Creates all expected parts
2. Uses the suggested parameters (adjust if needed)
3. Combines parts logically
4. Sets final_output to the complete model

Remember: Use parameter names as strings for dimensions (e.g., "W", "H/2")."""


PLANNER_KB_CONTEXT_TEMPLATE = """
## REFERENCE IMPLEMENTATIONS FROM KNOWLEDGE BASE:
The following OpenSCAD patterns from NopSCADlib are relevant to this design.
Use these as reference for parametric structure and best practices:

{kb_context}

IMPORTANT: Adapt these patterns to fit the user's specific requirements.
Do not copy verbatim - use them as structural guidance."""


REPAIR_SYSTEM_PROMPT = """You are a CAD PLAN REPAIR agent. Fix the invalid plan.

The plan failed validation with this error:
{error}

Original design intent:
{brief}

Fix the plan to:
1. Satisfy the schema requirements
2. Preserve the original design intent
3. Ensure all IDs are unique
4. Ensure all references are valid (no forward references)
5. Ensure final_output references an existing ID
6. NEVER include text, labels, logos, or branding - remove any text profiles

Output ONLY the corrected JSON plan."""


# =============================================================================
# PLANNER CLASS
# =============================================================================

@dataclass
class PlanResult:
    """Result of planning attempt."""
    plan: Optional[Dict[str, Any]]
    valid: bool
    error: Optional[str]
    attempts: int


class Planner:
    """Converts design briefs to JSON CAD plans."""
    
    def __init__(self, client, model: str = "gpt-4o"):
        """
        Initialize the planner.
        
        Args:
            client: OpenAI client instance
            model: Model to use for planning
        """
        self.client = client
        self.model = model
        self.schema_str = get_schema_as_string()
    
    def create_plan(
        self,
        brief: DesignBrief,
        max_attempts: int = MAX_PLAN_ATTEMPTS
    ) -> PlanResult:
        """
        Create a CAD plan from a design brief.
        
        Attempts to generate a valid plan, with automatic repair on failure.
        
        Args:
            brief: Design brief with description, parts, and parameters
            max_attempts: Maximum number of attempts (including repairs)
            
        Returns:
            PlanResult with plan, validity status, and attempt count
        """
        attempt = 0
        last_error = None
        plan = None
        
        while attempt < max_attempts:
            attempt += 1
            
            if attempt == 1:
                # First attempt: generate from scratch
                plan, error = self._generate_plan(brief)
            else:
                # Subsequent attempts: repair the failed plan
                plan, error = self._repair_plan(plan, last_error, brief)
            
            if error is None:
                # Plan generated successfully, now validate
                plan = postprocess_plan(plan)
                valid, validation_error = validate_plan(plan)
                
                if valid:
                    return PlanResult(
                        plan=plan,
                        valid=True,
                        error=None,
                        attempts=attempt
                    )
                else:
                    last_error = validation_error
            else:
                last_error = error
        
        # Max attempts reached
        return PlanResult(
            plan=plan,
            valid=False,
            error=last_error,
            attempts=attempt
        )
    
    def _generate_plan(
        self,
        brief: DesignBrief
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        """
        Generate a plan from a design brief.

        Returns:
            Tuple of (plan_dict, error_message)
        """
        # Build KB context section if available
        kb_context_section = ""
        if hasattr(brief, 'kb_augmented') and brief.kb_augmented and brief.kb_context_prompt:
            kb_context_section = PLANNER_KB_CONTEXT_TEMPLATE.format(
                kb_context=brief.kb_context_prompt
            )

        user_content = PLANNER_USER_TEMPLATE.format(
            description=brief.description,
            parts=", ".join(brief.expected_parts) if brief.expected_parts else "main body",
            parameters=json.dumps(brief.parameters, indent=2),
            kb_context=kb_context_section
        )
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0.1,
                response_format={"type": "json_object"},
                messages=[
                    {
                        "role": "system",
                        "content": PLANNER_SYSTEM_PROMPT + "\n\nSCHEMA:\n" + self.schema_str
                    },
                    {
                        "role": "user",
                        "content": user_content
                    }
                ]
            )
            
            plan = json.loads(response.choices[0].message.content)
            return plan, None
            
        except json.JSONDecodeError as e:
            return None, f"Invalid JSON response: {str(e)}"
        except Exception as e:
            return None, f"API error: {str(e)}"
    
    def _repair_plan(
        self,
        plan: Optional[Dict[str, Any]],
        error: str,
        brief: DesignBrief
    ) -> Tuple[Optional[Dict[str, Any]], Optional[str]]:
        """
        Repair an invalid plan.
        
        Returns:
            Tuple of (repaired_plan, error_message)
        """
        repair_prompt = REPAIR_SYSTEM_PROMPT.format(
            error=error,
            brief=brief.description
        )
        
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0.1,
                response_format={"type": "json_object"},
                messages=[
                    {
                        "role": "system",
                        "content": repair_prompt + "\n\nSCHEMA:\n" + self.schema_str
                    },
                    {
                        "role": "user",
                        "content": json.dumps(plan, indent=2) if plan else "{}"
                    }
                ]
            )
            
            repaired = json.loads(response.choices[0].message.content)
            return repaired, None
            
        except json.JSONDecodeError as e:
            return plan, f"Repair produced invalid JSON: {str(e)}"
        except Exception as e:
            return plan, f"Repair API error: {str(e)}"


# =============================================================================
# CONVENIENCE FUNCTION
# =============================================================================

def create_cad_plan(
    client,
    brief: DesignBrief,
    model: str = "gpt-4o",
    max_attempts: int = MAX_PLAN_ATTEMPTS
) -> PlanResult:
    """
    Convenience function to create a CAD plan from a design brief.
    
    Args:
        client: OpenAI client
        brief: Design brief
        model: Model to use
        max_attempts: Maximum planning attempts
        
    Returns:
        PlanResult instance
    """
    planner = Planner(client, model)
    return planner.create_plan(brief, max_attempts)


# =============================================================================
# DIRECT TEXT-TO-PLAN (BYPASS REASONER FOR SIMPLE CASES)
# =============================================================================

def quick_plan(
    client,
    prompt: str,
    model: str = "gpt-4o"
) -> PlanResult:
    """
    Quick planning directly from a text prompt.
    
    Bypasses the full reasoner for simple cases.
    
    Args:
        client: OpenAI client
        prompt: Text description of desired model
        model: Model to use
        
    Returns:
        PlanResult instance
    """
    # Create a minimal brief
    brief = DesignBrief(
        description=prompt,
        expected_parts=[],
        parameters={"W": 100, "H": 100, "D": 100},
        source="text",
        original_input=prompt
    )
    
    planner = Planner(client, model)
    return planner.create_plan(brief)
