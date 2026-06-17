// HT 40 cap (end cap) - one connected solid

$fn = 120;

// Parameters
wall_thickness = 3;                 // radial wall thickness
ht_pipe_outer_diameter = 40;        // cap outside diameter
cap_length = 20;                    // total cap height
bottom_thickness = 3;               // closed-end thickness

// Derived
ht_pipe_inner_diameter = ht_pipe_outer_diameter - 2 * wall_thickness;
inner_h = cap_length - bottom_thickness;
eps = 0.2;

module ht_40_cap() {
    // Build centered to avoid view/camera issues and ensure robust boolean
    difference() {
        // Outer body
        cylinder(h = cap_length, d = ht_pipe_outer_diameter, center = true);

        // Inner socket void (leaves a closed end of bottom_thickness)
        // Outer spans z: [-cap_length/2, +cap_length/2]
        // Inner spans z: [-cap_length/2 + bottom_thickness, +cap_length/2]
        translate([0, 0, (-cap_length/2 + bottom_thickness) + inner_h/2])
            cylinder(h = inner_h + 2*eps, d = ht_pipe_inner_diameter, center = true);
    }
}

ht_40_cap();