$fn = 128;

// HT pipe parameters (approximate for HT 75)
// Nominal DN 75: outer diameter ~75 mm, typical wall thickness ~2.7 mm
pipe_length = 2000;      // mm
outer_d = 75;            // mm
wall = 2.7;              // mm
inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = L + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, pipe_length);