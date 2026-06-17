$fn = 128;

// HT 90 pipe, length 1500 mm (approx. DN90: OD 90 mm, wall 3.2 mm)
pipe_length = 1500;
outer_d = 90;
wall = 3.2;
inner_d = outer_d - 2*wall;

module ht_pipe(len, od, id) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = len + 1, d = id, center = false);
    }
}

ht_pipe(pipe_length, outer_d, inner_d);