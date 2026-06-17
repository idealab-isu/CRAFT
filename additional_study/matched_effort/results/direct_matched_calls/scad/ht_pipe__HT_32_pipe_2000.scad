$fn = 128;

// HT pipe parameters (approx. for HT 32)
pipe_length = 2000;          // mm
outer_diameter = 32;         // mm (nominal)
wall_thickness = 1.8;        // mm (typical for HT 32; adjust if needed)

inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = len + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);