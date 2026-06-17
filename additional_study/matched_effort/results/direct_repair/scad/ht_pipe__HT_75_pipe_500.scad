$fn = 128;

// HT pipe parameters (approximate for HT 75)
pipe_length = 500;          // mm
outer_diameter = 75;        // mm (nominal)
wall_thickness = 2.7;       // mm (typical HT wall)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od);
        translate([0,0,-0.5])
            cylinder(h = L + 1, d = id);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);