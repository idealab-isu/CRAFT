"""
Detect curved/smooth shape needs and enhance prompts with NURBS guidance.

Analyzes design briefs to identify objects that benefit from smooth,
curved surfaces (aerodynamic, aesthetic, decorative, artistic, etc.)
and enriches prompts with guidance on using smooth surface techniques.
"""

from typing import Tuple, List, Optional

# General curved surface indicators
CURVED_SHAPE_KEYWORDS = {
    # Aesthetic/decorative
    "vase", "bottle", "sculpture", "statue", "art", "artistic",
    "decorative", "ornamental", "elegant", "beautiful", "aesthetic",

    # Organic/natural
    "organic", "nature", "natural", "biomorphic", "flowing", "wave",
    "plant", "flower", "leaf", "shell", "coral", "seashell",
    "mushroom", "egg", "bulbous", "round", "rounded",

    # Smooth surface descriptors
    "smooth", "curved", "curve", "sleek", "polished", "glossy",
    "blended", "transition", "smooth transition", "gradient",
    "flowing", "fluid", "liquid", "wavy", "undulating",

    # Functional aerodynamic/hydrodynamic
    "aerodynamic", "streamlined", "tapered", "airfoil", "wing",
    "airplane", "aircraft", "plane", "fuselage", "tail",
    "car", "automobile", "vehicle", "boat", "ship", "yacht", "hull",
    "canoe", "kayak", "submarine", "drone", "helicopter", "rocket",
    "propeller", "turbine", "blade", "fan", "hydrofoil",

    # Abstract smooth forms
    "sphere", "spherical", "cylinder", "cone", "conical",
    "torus", "paraboloid", "hyperboloid", "surface",
    "blend", "fillet", "chamfer", "rounded edge",

    # Art/design styles
    "minimalist", "modern", "contemporary", "sculptural",
    "abstract", "geometric", "parametric"
}


def detect_curved_surface_need(brief_description: str) -> Tuple[bool, List[str], float]:
    """
    Detect if design needs smooth, curved surfaces (aesthetic, aerodynamic, etc).

    Args:
        brief_description: Design brief text

    Returns:
        Tuple of (needs_curves, detected_keywords, confidence_score 0-1.0)
    """
    if not brief_description:
        return False, [], 0.0

    text_lower = brief_description.lower()
    detected = []
    confidence = 0.0

    # Check for curved surface keywords
    for keyword in CURVED_SHAPE_KEYWORDS:
        if keyword in text_lower:
            detected.append(keyword)
            confidence += 0.12

    # Boost confidence if multiple curved terms found
    if len(detected) > 1:
        confidence = min(1.0, confidence * 1.15)

    # Penalize if explicitly boxy/angular terms appear
    if any(term in text_lower for term in ["boxy", "blocky", "cubic", "rectangular", "angular", "square"]):
        confidence *= 0.4

    needs_curves = confidence > 0.25
    return needs_curves, detected, min(1.0, confidence)

# Keep old name for backward compatibility
def detect_aerodynamic_shape(brief_description: str) -> Tuple[bool, List[str], float]:
    """Deprecated: use detect_curved_surface_need instead."""
    return detect_curved_surface_need(brief_description)


def get_smooth_surface_guidance(
    detected_keywords: List[str],
    confidence: float
) -> Optional[str]:
    """
    Generate enhancement prompt for smooth/curved surface guidance.

    Works for any smooth surface: aesthetic, decorative, aerodynamic, etc.

    Args:
        detected_keywords: List of detected surface-related terms
        confidence: Confidence score (0.0 to 1.0)

    Returns:
        Enhancement text to add to planner prompt, or None if not needed
    """
    if confidence < 0.3:
        return None

    guidance_parts = []

    # Aesthetic/decorative/artistic shapes
    if any(kw in detected_keywords for kw in ["vase", "sculpture", "art", "aesthetic", "decorative", "elegant"]):
        guidance_parts.append(
            "Use hull() to blend shapes smoothly. Use offset() for filleted edges. "
            "Use polyhedron() with interpolated curves for custom artistic surfaces."
        )

    # Organic/natural forms
    if any(kw in detected_keywords for kw in ["organic", "nature", "natural", "plant", "shell", "egg"]):
        guidance_parts.append(
            "Create flowing curves: use hull() to blend base shapes, splines via polyhedron(), "
            "and avoid sharp edges. Embrace asymmetry and natural variation."
        )

    # Aerodynamic/functional
    if any(kw in detected_keywords for kw in ["airplane", "wing", "airfoil", "aerodynamic", "streamlined"]):
        guidance_parts.append(
            "Use tapered cylinders with hull() for smooth airfoil transitions. "
            "Use polyhedron() with NACA-like profiles for realistic aerodynamic shapes."
        )

    # Vehicle bodies
    if any(kw in detected_keywords for kw in ["car", "automobile", "boat", "ship", "yacht", "vehicle"]):
        guidance_parts.append(
            "Create smooth body surfaces using hull() for cross-section blending. "
            "Use offset() for rounded edges. Taper strategically for visual flow."
        )

    # Bottles/containers/vessels
    if any(kw in detected_keywords for kw in ["bottle", "vase", "cup", "mug", "teapot", "vessel"]):
        guidance_parts.append(
            "Use hull() with circular profiles at different heights to create smooth vessels. "
            "Taper carefully for visual elegance."
        )

    # Sculptural/abstract
    if any(kw in detected_keywords for kw in ["sculpture", "statue", "abstract", "parametric", "sculptural"]):
        guidance_parts.append(
            "Use polyhedron() with mathematically-defined vertices for smooth abstract forms. "
            "Use hull() and offset() to blend and refine shapes."
        )

    # Spinning/rotating objects
    if any(kw in detected_keywords for kw in ["propeller", "turbine", "blade", "fan", "rotor"]):
        guidance_parts.append(
            "Use revolution or lofting approach: hull() with tapered profiles along rotation axis. "
            "Use polyhedron() for swept aerodynamic blade surfaces."
        )

    # General smooth surface advice
    if not guidance_parts:
        guidance_parts.append(
            "Prioritize smooth surfaces: use hull() for blending, offset() for rounding, "
            "and polyhedron() for custom curves. Minimize flat faces."
        )

    # Format as enhancement
    prompt = "\n\n[SMOOTH CURVED SURFACES DETECTED]\nUse smooth surface techniques:\n"
    for part in guidance_parts:
        prompt += f"• {part}\n"

    return prompt

# Keep old name for backward compatibility
def get_nurbs_enhancement_prompt(
    detected_keywords: List[str],
    confidence: float
) -> Optional[str]:
    """Deprecated: use get_smooth_surface_guidance instead."""
    return get_smooth_surface_guidance(detected_keywords, confidence)


def get_smooth_surface_code_pattern(
    keywords: List[str]
) -> Optional[str]:
    """
    Get OpenSCAD code snippet suggestions for smooth surfaces.

    Args:
        keywords: Detected shape keywords

    Returns:
        Suggested OpenSCAD pattern, or None
    """
    # Aerodynamic/wing shapes
    if any(kw in keywords for kw in ["airfoil", "wing", "airplane"]):
        return """// Smooth tapered wing using hull()
module smooth_wing(root_chord, tip_chord, span) {
  hull() {
    linear_extrude(0.1) polygon(airfoil_profile(root_chord));
    translate([0, 0, span])
      scale(tip_chord/root_chord)
        linear_extrude(0.1) polygon(airfoil_profile(root_chord));
  }
}

// Or use polyhedron() for NACA precision (from nurbs_surfaces module)
wing_surface = polyhedron(points = [...], faces = [...]);"""

    # Marine/vessel shapes (boats, hulls)
    elif any(kw in keywords for kw in ["boat", "hull", "canoe", "ship", "yacht"]):
        return """// Smooth boat hull with tapered nose/tail
module smooth_hull(length, beam, draft) {
  hull() {
    // Bow - sharp
    translate([0, 0, draft]) sphere(r=beam/2);
    // Stern - tapered
    translate([length, 0, draft]) sphere(r=beam/3);
    // Bottom keel
    cube([length, beam, 0.1]);
  }
}"""

    # Vessels: bottles, vases, cups
    elif any(kw in keywords for kw in ["vase", "bottle", "vessel", "cup", "mug", "teapot"]):
        return """// Smooth curved vessel using hull()
module smooth_vessel(height, base_r, mid_r, top_r) {
  hull() {
    cylinder(r=base_r, h=0.1);           // Base
    translate([0, 0, height*0.3])
      cylinder(r=mid_r, h=0.1);          // Widest point
    translate([0, 0, height])
      cylinder(r=top_r, h=0.1);          // Rim
  }
}

// For elegant flowing shapes, add fillets with offset()
color("cyan") offset(-2) smooth_vessel(100, 30, 40, 25);"""

    # Sculptural/artistic abstract
    elif any(kw in keywords for kw in ["sculpture", "statue", "art", "abstract", "artistic"]):
        return """// Smooth abstract form - blend multiple shapes
module smooth_sculpture() {
  hull() {
    // Base form
    sphere(r=30);
    // Extended form
    translate([40, 0, 20]) sphere(r=25);
    // Flow element
    translate([0, 50, 10]) ellipsoid(20, 15, 30);
  }

  // Refine with offset for fillets
  offset(r=3) {
    // Original design
  }
}"""

    # Organic/natural forms
    elif any(kw in keywords for kw in ["organic", "nature", "natural", "plant", "shell", "egg"]):
        return """// Organic flowing form
module organic_shape() {
  hull() {
    // Create asymmetric, natural shapes
    sphere(r=25);
    translate([15, 10, 30]) sphere(r=20);
    translate([-10, 20, 15]) sphere(r=18);
  }
}

// Use offset() for softened edges, polyhedron() for custom curves"""

    # Turbine/blade/propeller
    elif any(kw in keywords for kw in ["turbine", "blade", "propeller", "fan", "rotor"]):
        return """// Smooth aerodynamic blade
module smooth_blade(length, width, thickness) {
  hull() {
    linear_extrude(0.1) polygon(airfoil_cross_section(width, thickness));
    translate([length, 0, 0])
      scale([0.3, 0.3, 1])
        linear_extrude(0.1) polygon(airfoil_cross_section(width, thickness));
  }
}"""

    # Fallback for any smooth surface
    else:
        return """// Smooth curved surface template
module smooth_surface() {
  // Method 1: hull() for smooth blending
  hull() {
    shape_1();
    shape_2();
    shape_3();
  }

  // Method 2: offset() for filleted edges
  offset(r=2) original_shape();

  // Method 3: polyhedron() for custom curves
  polyhedron(points = [...], faces = [...]);
}"""

# Keep old name for backward compatibility
def get_nurbs_code_suggestion(keywords: List[str]) -> Optional[str]:
    """Deprecated: use get_smooth_surface_code_pattern instead."""
    return get_smooth_surface_code_pattern(keywords)
