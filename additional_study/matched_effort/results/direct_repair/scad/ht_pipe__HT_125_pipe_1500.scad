$fn = 128;

// HT pipe parameters (mm)
pipe_od = 125;        // outer diameter
pipe_length = 1500;   // length
wall_thickness = 3.2; // typical HT pipe wall thickness (approx.)
pipe_id = pipe_od - 2*wall_thickness;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = len + 1, d = id, center = false);
    }
}

ht_pipe(pipe_od, pipe_id, pipe_length);