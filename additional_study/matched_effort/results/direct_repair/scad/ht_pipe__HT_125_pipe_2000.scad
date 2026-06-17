$fn = 128;

// HT pipe parameters (mm)
pipe_dn = 125;          // nominal diameter label
pipe_length = 2000;     // length
outer_d = 125;          // assumed outer diameter for "HT 125"
wall = 3.2;             // typical HT wall thickness (approx)
inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od);
        translate([0,0,-0.5])
            cylinder(h = L + 1, d = id);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);