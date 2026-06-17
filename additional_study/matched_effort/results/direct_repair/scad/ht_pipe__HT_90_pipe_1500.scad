$fn = 128;

// HT 90 pipe 1500 mm (assumed: 90 mm outer diameter, 1500 mm length)
// Typical HT (house drainage) pipe wall thickness varies; choose a reasonable default.
pipe_length = 1500;      // mm
outer_diameter = 90;     // mm
wall_thickness = 3.2;    // mm (adjust if needed)

inner_diameter = outer_diameter - 2*wall_thickness;

module ht_pipe(len, od, id) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = len + 0.2, d = id, center = false);
    }
}

ht_pipe(pipe_length, outer_diameter, inner_diameter);