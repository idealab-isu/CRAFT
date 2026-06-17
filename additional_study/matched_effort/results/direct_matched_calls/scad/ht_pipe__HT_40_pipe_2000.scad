$fn = 128;

// HT pipe (approximation): DN40, length 2000 mm
// Typical HT DN40 dimensions: OD ~ 40 mm, wall ~ 1.8 mm (varies by manufacturer)
pipe_length = 2000;
outer_d = 40;
wall = 1.8;
inner_d = outer_d - 2*wall;

module ht_pipe(len, od, id) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = len + 1, d = id, center = false);
    }
}

ht_pipe(pipe_length, outer_d, inner_d);