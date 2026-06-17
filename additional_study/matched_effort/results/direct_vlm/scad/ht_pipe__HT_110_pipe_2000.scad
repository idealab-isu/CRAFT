$fn = 128;

// HT pipe parameters (approximate for HT 110)
pipe_length = 2000;          // mm
outer_diameter = 110;        // mm (nominal HT 110)
wall_thickness = 3.2;        // mm (typical for HT indoor drainage)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = len + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);