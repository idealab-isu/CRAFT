// Dimension-calibrated (target: 3.50 x 1.70 x 9.07 mm)
scale([0.724707, 1.008629, 1.000441])
{
// Curved C-shaped hollow sleeve segment (partial ring/pipe section)
// Target bounding box: ~3.5 x 1.7 x 9.1 mm (X x Y x Z), elongated along Z

// --- Parameters (kept from original, but made consistent) ---
L = 9.07;                 // length along Z
W = 3.5;                  // overall diameter across outer surface (X/Y)
H = 1.7;                  // radial thickness (outer radius - inner radius)*2? (used to derive radii)
t = 0.35;                 // wall thickness (radial)
arc_deg = 220;            // arc angle of the clamp segment (open ends)
outer_facets = 12;        // faceted outer surface
overlap = 0.2;            // small overlap for robust booleans
mark_r = 0.18;
mark_h = 0.25;

// --- Derived dimensions ---
// Use W as outer diameter => outer radius:
R_out = W/2;              // 1.75 mm
// Use H as radial build (approx) and t as wall thickness; ensure valid:
R_in  = max(0.2, R_out - H);          // inner radius (concave)
R_void = max(0.1, R_out - t);         // inner void radius to create constant wall thickness

// Keep void inside the sleeve wall; if parameters conflict, clamp:
R_void = min(R_void, R_out - 0.05);
R_in   = min(R_in,  R_void - 0.05);

// --- Modules ---
module c_segment_sleeve() {
    // Create a faceted outer cylinder segment and subtract a smooth inner cylinder segment
    // Both are made with rotate_extrude(angle=arc_deg) around Z, then extruded along Z by using 2D profile in (radius, z).
    difference() {
        // Outer: faceted by using low $fn on rotate_extrude
        rotate_extrude(angle=arc_deg, $fn=outer_facets)
            polygon(points=[
                [0,   -L/2],
                [R_out, -L/2],
                [R_out,  L/2],
                [0,    L/2]
            ]);

        // Inner void: smooth (higher $fn) to keep concave inner radius
        rotate_extrude(angle=arc_deg, $fn=max(48, outer_facets*4))
            polygon(points=[
                [0,     -L/2 - overlap],
                [R_void, -L/2 - overlap],
                [R_void,  L/2 + overlap],
                [0,      L/2 + overlap]
            ]);

        // Remove the central core so it is a sleeve (ensures concave inner surface starts at R_in)
        // This also prevents any accidental fill near the axis from the outer polygon.
        cylinder(r=R_in, h=L + 2*overlap, center=true, $fn=96);
    }
}

module alignment_mark_cut() {
    // Small cylindrical dimple on the outer surface near one end
    // Place at mid-angle of the arc, on outer radius.
    ang = arc_deg/2;
    rpos = R_out - mark_r*0.6; // slightly inset so it cuts into the surface
    zpos = L/2 - mark_h/2 - overlap;

    rotate([0,0,ang])
        translate([rpos, 0, zpos])
            cylinder(r=mark_r, h=mark_h, center=true, $fn=32);
}

// --- Final solid (one connected body) ---
difference() {
    // Center the arc around +X direction by rotating so the opening is symmetric about X axis
    rotate([0,0,-arc_deg/2])
        c_segment_sleeve();

    // Optional small mark (subtractive), does not disconnect the part
    rotate([0,0,-arc_deg/2])
        alignment_mark_cut();
}
}
