$fn = 128;

// HT 50 pipe: OD 50 mm, length 500 mm (approx wall 1.8 mm)
pipe_length = 500;
od = 50;
wall = 1.8;
id = od - 2*wall;

module ht_pipe(len, od, id) {
    // Orient pipe along X so front/back/left/right show length (not end ring)
    rotate([0, 90, 0])
        difference() {
            cylinder(h = len, d = od, center = true);
            cylinder(h = len + 2, d = id, center = true); // +2 ensures clean through-cut
        }
}

ht_pipe(pipe_length, od, id);