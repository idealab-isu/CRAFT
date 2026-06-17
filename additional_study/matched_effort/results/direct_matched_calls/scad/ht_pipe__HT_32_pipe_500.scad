$fn = 128;

// HT pipe parameters (approximate for HT 32)
pipe_length = 500;          // mm
outer_diameter = 32;        // mm (nominal)
wall_thickness = 1.8;       // mm (typical for HT 32, approximate)

inner_diameter = outer_diameter - 2 * wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0, 0, -0.1])
            cylinder(h = len + 0.2, d = id);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);