$fn = 128;

// HT 90 pipe 500 mm (approximation)
// Dimensions in mm
pipe_od = 90;        // outer diameter
pipe_id = 84;        // inner diameter (approx. 3 mm wall)
pipe_len = 500;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id, center = false);
    }
}

ht_pipe(pipe_od, pipe_id, pipe_len);