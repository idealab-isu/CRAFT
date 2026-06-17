// HT 32 pipe end cap (one connected solid)

// Parameters
pipe_outer_diameter = 32;     // OD of pipe
pipe_wall_thickness = 3;      // not directly used (kept for reference)
cap_wall_thickness  = 4;      // radial wall thickness of cap
insertion_depth     = 20;     // socket depth
lead_in_chamfer     = 2;      // chamfer height

// Robustness / rendering
$fn = 128;
eps = 0.05;

// Derived
cap_outer_diameter = pipe_outer_diameter + 2 * cap_wall_thickness;
cap_height         = insertion_depth + cap_wall_thickness;

// Main module
module ht_pipe_end_cap() {
    difference() {
        // Outer solid
        cylinder(h = cap_height, d = cap_outer_diameter, center = false);

        // Inner socket: start at opening (z=0) and stop before the closed end,
        // leaving a bottom thickness of cap_wall_thickness.
        cylinder(h = insertion_depth + eps, d = pipe_outer_diameter, center = false);

        // Lead-in chamfer at the opening (z=0..lead_in_chamfer)
        cylinder(
            h  = lead_in_chamfer + eps,
            d1 = pipe_outer_diameter + 2 * lead_in_chamfer,
            d2 = pipe_outer_diameter,
            center = false
        );
    }
}

ht_pipe_end_cap();