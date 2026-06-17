$fn = 128;

// HT pipe parameters (mm)
outer_d = 160;
length  = 1000;

// Typical HT pipe wall thickness (approx). Adjust if needed.
wall = 4.7;

inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od);
        translate([0,0,-0.1]) cylinder(h = L + 0.2, d = id);
    }
}

ht_pipe(outer_d, inner_d, length);