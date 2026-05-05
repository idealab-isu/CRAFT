"""
Smooth curved surface generation (NURBS-like polyhedron approximation).

Generates high-fidelity approximations of smooth surfaces using polyhedron()
with carefully interpolated control points. Works for any smooth shape:
aerodynamic, aesthetic, decorative, artistic, organic, etc.

Examples: airfoils, fuselages, car bodies, vases, sculptures, bottles.
"""

import math
from typing import List, Tuple, Optional, Callable


def cubic_spline_interpolate(
    points: List[float],
    num_points: int = 50
) -> List[float]:
    """
    Interpolate smooth curve through control points using cubic spline.

    Args:
        points: Control point values
        num_points: Output points to generate

    Returns:
        Smooth interpolated values
    """
    if len(points) < 2:
        return points

    result = []
    n = len(points) - 1

    for i in range(num_points):
        t = i / (num_points - 1) if num_points > 1 else 0  # 0 to 1
        segment = int(t * n)
        segment = min(segment, n - 1)

        # Local parameter within segment
        t_local = (t * n) - segment

        # Get control points
        p0 = points[segment] if segment > 0 else points[0]
        p1 = points[segment]
        p2 = points[segment + 1]
        p3 = points[segment + 2] if segment + 2 < len(points) else points[-1]

        # Catmull-Rom cubic spline
        t2 = t_local * t_local
        t3 = t2 * t_local

        a = -0.5*t3 + t2 - 0.5*t_local
        b = 1.5*t3 - 2.5*t2 + 1
        c = -1.5*t3 + 2*t2 + 0.5*t_local
        d = 0.5*t3 - 0.5*t2

        value = a*p0 + b*p1 + c*p2 + d*p3
        result.append(value)

    return result


def smooth_profile_revolution(
    radius_points: List[float],
    height: float = 100,
    num_circumference: int = 16,
    num_height_sections: int = 20
) -> Tuple[List[Tuple[float, float, float]], List[List[int]]]:
    """
    Generate smooth surface by revolving a profile curve.

    Great for vases, bottles, bowls, cups, jars, etc.

    Args:
        radius_points: Radius at each height (0 to 1 scale)
        height: Total height of object
        num_circumference: Points around circumference
        num_height_sections: Sections along height

    Returns:
        Tuple of (vertices, faces) for polyhedron()
    """
    # Interpolate smooth profile
    smooth_radii = cubic_spline_interpolate(radius_points, num_height_sections)

    vertices = []
    faces = []

    for h_idx, radius in enumerate(smooth_radii):
        z = (h_idx / (num_height_sections - 1)) * height if num_height_sections > 1 else 0
        section_start = len(vertices)

        # Create circle at this height
        for c_idx in range(num_circumference):
            angle = 2 * math.pi * c_idx / num_circumference
            x = radius * 50 * math.cos(angle)  # Scale radius
            y = radius * 50 * math.sin(angle)
            vertices.append((x, y, z))

        # Connect to previous section
        if h_idx > 0:
            prev_section = section_start - num_circumference
            for c_idx in range(num_circumference):
                curr = section_start + c_idx
                curr_next = section_start + (c_idx + 1) % num_circumference
                prev = prev_section + c_idx
                prev_next = prev_section + (c_idx + 1) % num_circumference

                faces.append([prev, prev_next, curr_next, curr])

    # Cap top and bottom
    faces.append(list(range(num_circumference)))
    faces.append(list(range(len(vertices) - num_circumference, len(vertices))))

    return vertices, faces


def smooth_blob_form(
    scale_factors: List[float],
    base_shape: str = "sphere",
    num_sections: int = 10
) -> Tuple[List[Tuple[float, float, float]], List[List[int]]]:
    """
    Generate smooth organic blob by interpolating scaled shapes.

    Args:
        scale_factors: Scale at each section (0 to 1)
        base_shape: "sphere", "cube", "cylinder"
        num_sections: Number of interpolated sections

    Returns:
        Tuple of (vertices, faces)
    """
    # Smooth the scale factors
    smooth_scales = cubic_spline_interpolate(scale_factors, num_sections)

    vertices = []
    faces = []

    if base_shape == "sphere":
        points_per_section = 12
    else:
        points_per_section = 8

    for s_idx, scale in enumerate(smooth_scales):
        z = (s_idx / (num_sections - 1)) * 100 if num_sections > 1 else 0
        section_start = len(vertices)

        if base_shape == "sphere":
            # Create icosphere-like points
            for p_idx in range(points_per_section):
                angle = 2 * math.pi * p_idx / points_per_section
                x = scale * 30 * math.cos(angle)
                y = scale * 30 * math.sin(angle)
                vertices.append((x, y, z))

        # Connect sections
        if s_idx > 0:
            prev_section = section_start - points_per_section
            for p_idx in range(points_per_section):
                curr = section_start + p_idx
                curr_next = section_start + (p_idx + 1) % points_per_section
                prev = prev_section + p_idx
                prev_next = prev_section + (p_idx + 1) % points_per_section

                faces.append([prev, prev_next, curr_next, curr])

    return vertices, faces


def generate_airfoil_profile(
    chord_length: float = 100,
    thickness_ratio: float = 0.12,
    camber: float = 0.04,
    num_points: int = 50
) -> List[Tuple[float, float]]:
    """
    Generate NACA-like airfoil profile (2D cross-section).

    Uses NACA 4-digit methodology for smooth aerodynamic shape.

    Args:
        chord_length: Airfoil chord length (leading to trailing edge)
        thickness_ratio: Thickness as fraction of chord (default 12%)
        camber: Maximum camber as fraction of chord (default 4%)
        num_points: Number of points along profile (more = smoother)

    Returns:
        List of (x, y) tuples representing airfoil profile
    """
    profile = []

    for i in range(num_points):
        # Parametric position along chord (0 to 1)
        t = i / (num_points - 1)
        x = t * chord_length

        # Thickness distribution (parabolic near leading edge, tapers to trailing)
        y_t = (
            thickness_ratio * chord_length / 0.2 *
            (0.2969 * math.sqrt(t) -
             0.1260 * t -
             0.3516 * t**2 +
             0.2843 * t**3 -
             0.1015 * t**4)
        )

        # Camber line (curved upper surface bias)
        if t <= 0.5:
            y_c = camber * chord_length / 0.25 * t**2
            dy_c = camber * chord_length / 0.25 * 2 * t
        else:
            y_c = camber * chord_length / 0.75 * (1 - 2*t + t**2)
            dy_c = camber * chord_length / 0.75 * (-2 + 2*t)

        # Upper surface (camber + thickness)
        profile.append((x, y_c + y_t))

    # Reverse for lower surface (camber - thickness)
    for i in range(num_points - 1, -1, -1):
        t = i / (num_points - 1)
        x = t * chord_length

        y_t = (
            thickness_ratio * chord_length / 0.2 *
            (0.2969 * math.sqrt(t) -
             0.1260 * t -
             0.3516 * t**2 +
             0.2843 * t**3 -
             0.1015 * t**4)
        )

        if t <= 0.5:
            y_c = camber * chord_length / 0.25 * t**2
        else:
            y_c = camber * chord_length / 0.75 * (1 - 2*t + t**2)

        # Lower surface
        profile.append((x, y_c - y_t))

    return profile


def scale_profile(profile: List[Tuple[float, float]], scale: float) -> List[Tuple[float, float]]:
    """Scale a 2D profile by a factor."""
    return [(x * scale, y * scale) for x, y in profile]


def generate_tapered_surface(
    base_profile: List[Tuple[float, float]],
    num_sections: int = 10,
    taper_ratio: float = 0.3,
    length: float = 100
) -> Tuple[List[Tuple[float, float, float]], List[List[int]]]:
    """
    Generate a tapered 3D surface (e.g., airplane wing).

    Creates a polyhedron with a profile that tapers from root to tip.

    Args:
        base_profile: 2D profile points (x, y)
        num_sections: Number of cross-sections along length
        taper_ratio: Tip chord / root chord (0 = point, 1 = uniform)
        length: Total length along Z axis

    Returns:
        Tuple of (vertices, faces) for polyhedron()
    """
    vertices = []
    faces = []

    # Generate cross-sections along the span
    for i in range(num_sections):
        # Position along span (0 to 1)
        pos = i / (num_sections - 1) if num_sections > 1 else 0

        # Scale profile based on taper
        taper_scale = 1.0 - (1.0 - taper_ratio) * pos
        scaled_profile = scale_profile(base_profile, taper_scale)

        # Z position along span
        z = pos * length

        # Add vertices for this section
        section_start = len(vertices)
        for x, y in scaled_profile:
            vertices.append((x, y, z))

        # Create faces between this section and next (if not last)
        if i < num_sections - 1:
            next_section_start = len(vertices)
            num_profile_points = len(scaled_profile)

            for j in range(num_profile_points):
                current = section_start + j
                next_current = section_start + (j + 1) % num_profile_points

                next = next_section_start + j
                next_next = next_section_start + (j + 1) % num_profile_points

                # Create quad face (two triangles)
                faces.append([current, next_current, next_next, next])

    # Close the tip
    if num_sections > 1:
        tip_start = len(vertices) - len(base_profile)
        faces.append(list(range(tip_start, len(vertices))))

    # Close the root
    root_end = len(base_profile)
    faces.append(list(range(root_end - 1, -1, -1)))

    return vertices, faces


def generate_fuselage(
    radius: float = 25,
    length: float = 200,
    nose_type: str = "cone",
    tail_type: str = "cone",
    num_sections: int = 20,
    num_circumference: int = 16
) -> Tuple[List[Tuple[float, float, float]], List[List[int]]]:
    """
    Generate a smooth fuselage (aircraft body-like surface).

    Creates a tapered cylinder with aerodynamic nose/tail.

    Args:
        radius: Fuselage radius
        length: Fuselage length
        nose_type: "cone" or "hemisphere"
        tail_type: "cone" or "hemisphere"
        num_sections: Longitudinal segments
        num_circumference: Circumference segments

    Returns:
        Tuple of (vertices, faces) for polyhedron()
    """
    vertices = []
    faces = []

    # Nose taper (0 to 1)
    nose_length = length * 0.15
    # Body section (constant radius)
    body_length = length * 0.7
    # Tail taper (1 to 0)
    tail_length = length * 0.15

    # Generate circular cross-sections
    for section_idx in range(num_sections):
        z_pos = section_idx / (num_sections - 1) * length if num_sections > 1 else 0
        z_rel = z_pos / length  # 0 to 1

        # Determine radius taper for this section
        if z_rel < nose_length / length:
            # Nose: tapers from 0 to radius
            taper = z_rel / (nose_length / length)
        elif z_rel < (nose_length + body_length) / length:
            # Body: constant radius
            taper = 1.0
        else:
            # Tail: tapers from radius to 0
            taper = 1.0 - ((z_rel - (nose_length + body_length) / length) / (tail_length / length))

        section_start = len(vertices)

        # Create circle at this cross-section
        for point_idx in range(num_circumference):
            angle = 2 * math.pi * point_idx / num_circumference
            x = radius * taper * math.cos(angle)
            y = radius * taper * math.sin(angle)
            z = z_pos

            vertices.append((x, y, z))

        # Create faces connecting to previous section
        if section_idx > 0:
            prev_section_start = section_start - num_circumference

            for point_idx in range(num_circumference):
                current = section_start + point_idx
                current_next = section_start + (point_idx + 1) % num_circumference

                prev = prev_section_start + point_idx
                prev_next = prev_section_start + (point_idx + 1) % num_circumference

                # Quad: connect ring to ring
                faces.append([prev, current, current_next, prev_next])

    return vertices, faces


def nurbs_surface_to_openscad(
    vertices: List[Tuple[float, float, float]],
    faces: List[List[int]],
    name: str = "nurbs_surface"
) -> str:
    """
    Convert NURBS surface vertices and faces to OpenSCAD polyhedron code.

    Args:
        vertices: List of (x, y, z) tuples
        faces: List of face vertex indices
        name: Variable name for the polyhedron

    Returns:
        OpenSCAD code as string
    """
    code = f"// NURBS approximation surface\n{name} = polyhedron(\n"

    # Format vertices
    code += "  points = [\n"
    for i, (x, y, z) in enumerate(vertices):
        code += f"    [{x:.2f}, {y:.2f}, {z:.2f}]"
        if i < len(vertices) - 1:
            code += ","
        code += "\n"
    code += "  ],\n"

    # Format faces
    code += "  faces = [\n"
    for i, face in enumerate(faces):
        code += f"    {face}"
        if i < len(faces) - 1:
            code += ","
        code += "\n"
    code += "  ]\n"
    code += ");\n\n"

    return code


def airfoil_wing_to_openscad(
    chord: float = 100,
    span: float = 200,
    taper_ratio: float = 0.4,
    thickness: float = 0.12,
    camber: float = 0.04,
    num_sections: int = 12,
    num_profile_points: int = 40
) -> str:
    """
    Generate complete OpenSCAD code for an airfoil wing with taper.

    Args:
        chord: Root chord length
        span: Wing span
        taper_ratio: Tip chord / root chord
        thickness: NACA thickness ratio
        camber: NACA camber ratio
        num_sections: Cross-sections along span
        num_profile_points: Points along airfoil profile

    Returns:
        Complete OpenSCAD code
    """
    # Generate 2D airfoil profile
    profile = generate_airfoil_profile(
        chord_length=chord,
        thickness_ratio=thickness,
        camber=camber,
        num_points=num_profile_points
    )

    # Generate 3D tapered wing surface
    vertices, faces = generate_tapered_surface(
        profile,
        num_sections=num_sections,
        taper_ratio=taper_ratio,
        length=span
    )

    # Convert to OpenSCAD
    scad_code = nurbs_surface_to_openscad(vertices, faces, "wing")

    # Add usage comment
    scad_code += (
        "// Wing with aerodynamic airfoil profile\n"
        f"// Chord: {chord} | Span: {span} | Taper: {taper_ratio}\n"
        f"// Thickness: {thickness*100:.1f}% | Camber: {camber*100:.1f}%\n"
        "color([0.3, 0.5, 0.8]) wing;\n"
    )

    return scad_code


def fuselage_to_openscad(
    radius: float = 30,
    length: float = 250,
    num_sections: int = 20,
    num_circumference: int = 16
) -> str:
    """
    Generate complete OpenSCAD code for a smooth fuselage.

    Args:
        radius: Fuselage radius
        length: Fuselage length
        num_sections: Longitudinal segments
        num_circumference: Circumference segments

    Returns:
        Complete OpenSCAD code
    """
    vertices, faces = generate_fuselage(
        radius=radius,
        length=length,
        num_sections=num_sections,
        num_circumference=num_circumference
    )

    scad_code = nurbs_surface_to_openscad(vertices, faces, "fuselage")

    scad_code += (
        "// Smooth aerodynamic fuselage\n"
        f"// Radius: {radius} | Length: {length}\n"
        "color([0.7, 0.7, 0.7]) fuselage;\n"
    )

    return scad_code


def smooth_vase_to_openscad(
    height: float = 150,
    base_radius: float = 40,
    mid_radius: float = 50,
    top_radius: float = 35,
    color_hex: str = "#8B7355"
) -> str:
    """Generate smooth vase with flowing curves."""
    profile = [
        base_radius / 50,
        mid_radius / 50,
        (mid_radius + top_radius) / 100,
        top_radius / 50
    ]

    vertices, faces = smooth_profile_revolution(
        radius_points=profile,
        height=height,
        num_circumference=20,
        num_height_sections=15
    )

    scad_code = nurbs_surface_to_openscad(vertices, faces, "vase")
    r = int(color_hex[1:3], 16) / 255
    g = int(color_hex[3:5], 16) / 255
    b = int(color_hex[5:7], 16) / 255

    scad_code += f"color([{r:.2f}, {g:.2f}, {b:.2f}]) vase;\n"
    return scad_code


def smooth_bottle_to_openscad(
    height: float = 200,
    body_radius: float = 40,
    neck_radius: float = 20,
    color_hex: str = "#2F4F4F"
) -> str:
    """Generate smooth bottle with elegant curves."""
    profile = [
        body_radius / 50 * 0.8,
        body_radius / 50,
        neck_radius / 50 * 0.9,
        neck_radius / 50,
        neck_radius / 50 * 1.1
    ]

    vertices, faces = smooth_profile_revolution(
        radius_points=profile,
        height=height,
        num_circumference=18,
        num_height_sections=12
    )

    scad_code = nurbs_surface_to_openscad(vertices, faces, "bottle")
    r = int(color_hex[1:3], 16) / 255
    g = int(color_hex[3:5], 16) / 255
    b = int(color_hex[5:7], 16) / 255

    scad_code += f"color([{r:.2f}, {g:.2f}, {b:.2f}]) bottle;\n"
    return scad_code


def smooth_sculpture_to_openscad(
    scale_curve: List[float],
    height: float = 200,
    color_hex: str = "#696969"
) -> str:
    """Generate abstract smooth sculpture form."""
    vertices, faces = smooth_blob_form(
        scale_factors=scale_curve,
        base_shape="sphere",
        num_sections=15
    )

    scad_code = nurbs_surface_to_openscad(vertices, faces, "sculpture")
    r = int(color_hex[1:3], 16) / 255
    g = int(color_hex[3:5], 16) / 255
    b = int(color_hex[5:7], 16) / 255

    scad_code += f"color([{r:.2f}, {g:.2f}, {b:.2f}]) sculpture;\n"
    return scad_code
