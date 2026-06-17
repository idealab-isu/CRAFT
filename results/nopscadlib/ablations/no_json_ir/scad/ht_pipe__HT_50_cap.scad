// HT 50 pipe cap (socket end cap) - single connected solid

$fn = 160;

// Parameters (mm)
cap_diameter        = 63;   // outer diameter of cap
pipe_outer_diameter = 50;   // socket diameter (fits over pipe OD)
insertion_depth     = 20;   // socket depth
wall_thickness      = (cap_diameter - pipe_outer_diameter) / 2; // radial wall
top_thickness       = wall_thickness; // closed end thickness
chamfer_size        = 2;    // lead-in chamfer height

eps = 0.05;

cap_height = insertion_depth + top_thickness;

module ht50_cap() {
    // Build from z=0 (mouth) to z=cap_height (closed top)
    difference() {
        // Outer body
        cylinder(h = cap_height, d = cap_diameter, center = false);

        // Inner socket void: starts at mouth and stops before the top thickness
        translate([0, 0, -eps])
            cylinder(h = insertion_depth + eps, d = pipe_outer_diameter, center = false);

        // Lead-in chamfer at the mouth (bottom), limited to chamfer height
        translate([0, 0, -eps])
            cylinder(h = chamfer_size + eps,
                     d1 = pipe_outer_diameter + 2*chamfer_size,
                     d2 = pipe_outer_diameter,
                     center = false);
    }
}

ht50_cap();