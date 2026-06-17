$fn = 180;

// HT pipe parameters (mm)
outer_d = 160;
length  = 1500;

// Typical HT (house drainage) wall thickness approximation (mm)
wall = 4.7;

inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = L + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, length);