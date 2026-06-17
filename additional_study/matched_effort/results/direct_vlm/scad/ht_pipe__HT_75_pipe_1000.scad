$fn = 128;

// HT 75 pipe, length 1000 mm (typical OD 75 mm, wall ~2.7 mm)
pipe_length = 1000;
outer_d = 75;
wall = 2.7;
inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = L + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);