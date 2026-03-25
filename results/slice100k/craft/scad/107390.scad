// Dimension-calibrated (target: 3.00 x 1.20 x 9.00 mm)
scale([1.000000, 0.999168, 2.502628])
{
// Curved C-shaped clamp/brace segment (structurally corrected)
// Target bounding box: 3.0 x 1.2 x 9.0 mm (X x Y x Z), elongated along Z

// ---------------- Parameters ----------------
bbox_L = 9.0;   // Z length
bbox_W = 3.0;   // X width
bbox_H = 1.2;   // Y thickness

// Ring radii (must fit within bbox_W/2 = 1.5)
arc_outer_R = 1.5;
arc_inner_R = 1.05;

// Arc span (C-shape)
arc_angle_deg = 220.0;

// End tabs (squared-off, slightly thickened)
tab_len = 0.7;          // along Z
tab_W = 3.0;            // along X
tab_H = 1.2;            // along Y
tab_thicken = 0.15;     // extra thickness on +Y face

// Faceting (outer surface)
facet_count = 10;

// Overlap for robust unions/differences (kept small at this scale)
overlap = 0.25;

// Optional small relief notches (kept on tabs only)
notch_W = 0.35;         // along X
notch_L = 0.25;         // along Z
notch_H = 0.5;          // along Y

// ---------------- Derived ----------------
mid_R   = (arc_outer_R + arc_inner_R) / 2;
rad_thk = (arc_outer_R - arc_inner_R);
arc_start = -arc_angle_deg/2;

// ---------------- Helpers ----------------
module arc_ring_segment() {
    // Build a partial ring in the XY plane (rotate_extrude about Z),
    // then rotate it so the arc runs along Z (elongated axis).
    rotate([90,0,0])  // map original Y -> Z so length becomes along Z
        rotate([0,0,arc_start])
            rotate_extrude(angle=arc_angle_deg, $fn=facet_count)
                translate([mid_R, 0, 0])
                    square([rad_thk, bbox_H], center=true);
}

module inner_channel_cut() {
    // Subtract a concave inner channel (cylindrical-like) along the same arc.
    rotate([90,0,0])
        rotate([0,0,arc_start])
            rotate_extrude(angle=arc_angle_deg, $fn=max(64, facet_count*8))
                translate([arc_inner_R, 0, 0])
                    square([2*rad_thk + 2*overlap, bbox_H + 2*overlap], center=true);
}

module end_tabs() {
    // Place tabs at the two arc ends using the actual end positions of the rotated arc.
    // After rotate([90,0,0]), a point (x,y,0) becomes (x,0,y), so Z comes from original Y.
    a1 = arc_start;
    a2 = arc_start + arc_angle_deg;

    // Endpoints of the mid-radius centerline in original XY:
    // (x,y) = (mid_R*cos(a), mid_R*sin(a))
    // After rotation, Z = y.
    z1 = mid_R * sin(a1);
    z2 = mid_R * sin(a2);

    // Ensure tabs overlap into the arc body for connectivity
    tab_len_eff = tab_len + 2*overlap;

    union() {
        for (z = [z1, z2]) {
            // Base tab (squared-off)
            translate([0, 0, z])
                cube([tab_W, tab_H, tab_len_eff], center=true);

            // Thickening pad on +Y face
            translate([0, bbox_H/2 - tab_thicken/2, z])
                cube([tab_W, tab_thicken, tab_len_eff], center=true);
        }
    }
}

module tab_notches_cut() {
    // Cut notches only where tabs exist (at tab Z centers).
    a1 = arc_start;
    a2 = arc_start + arc_angle_deg;

    z1 = mid_R * sin(a1);
    z2 = mid_R * sin(a2);

    x1 = -bbox_W/2 + notch_W/2;
    x2 =  bbox_W/2 - notch_W/2;

    union() {
        for (z = [z1, z2]) {
            for (x = [x1, x2]) {
                translate([x, 0, z])
                    cube([notch_W, notch_H, notch_L], center=true);
            }
        }
    }
}

module trim_to_bbox() {
    cube([bbox_W, bbox_H, bbox_L], center=true);
}

// ---------------- Build ----------------
module clamp_segment() {
    difference() {
        // Keep everything connected as one solid, then trim to bbox.
        intersection() {
            union() {
                difference() {
                    arc_ring_segment();
                    inner_channel_cut();
                }
                end_tabs();
            }
            trim_to_bbox();
        }
        tab_notches_cut();
    }
}

// Final output
clamp_segment();
}
