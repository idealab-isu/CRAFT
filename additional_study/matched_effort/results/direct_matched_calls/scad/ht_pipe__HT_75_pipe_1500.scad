$fn = 128;

// HT pipe parameters (approximate for HT 75)
pipe_length = 1500;          // mm
outer_diameter = 75;         // mm (nominal)
wall_thickness = 2.7;        // mm (typical HT pipe wall)
inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = len + 1, d = id, center = false);
    }
}

ht_pipe(outer_diameter, inner_diameter, pipe_length);