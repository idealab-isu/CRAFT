$fn = 128;

// HT pipe parameters (approximate for HT 32)
pipe_length = 500;          // mm
outer_diameter = 32;        // mm
wall_thickness = 1.8;       // mm (typical-ish for HT 32)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od);
        translate([0,0,-0.5])
            cylinder(h = L + 1, d = id);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);