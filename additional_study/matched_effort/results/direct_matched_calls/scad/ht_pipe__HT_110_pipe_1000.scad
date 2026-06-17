$fn = 128;

// HT pipe parameters (approximate for HT 110)
pipe_length = 1000;          // mm
outer_diameter = 110;        // mm (nominal)
wall_thickness = 3.2;        // mm (typical for HT 110)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = L + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);