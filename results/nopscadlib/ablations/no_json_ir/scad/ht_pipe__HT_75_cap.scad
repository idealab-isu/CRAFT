// HT 75 cap (end cap) - single connected solid

$fn = 160;

// Parameters (mm)
ht_pipe_outer_diameter = 75;   // OD of pipe that fits into cap
wall_thickness         = 3;    // radial wall thickness of cap
insertion_depth        = 20;   // socket depth
cap_end_thickness      = 5;    // closed end thickness

// Robustness for boolean ops
eps = 0.2;

// Derived
cap_outer_diameter = ht_pipe_outer_diameter + 2 * wall_thickness;
cap_total_height   = insertion_depth + cap_end_thickness;

module ht_75_cap() {
    difference() {
        // Outer body
        cylinder(h = cap_total_height, d = cap_outer_diameter, center = false);

        // Inner void (socket): starts at open end (z=0) and stops before closed end
        // Use a slightly smaller diameter to avoid coincident faces that can render "blank"
        translate([0, 0, -eps])
            cylinder(h = insertion_depth + eps, d = ht_pipe_outer_diameter - eps, center = false);
    }
}

ht_75_cap();