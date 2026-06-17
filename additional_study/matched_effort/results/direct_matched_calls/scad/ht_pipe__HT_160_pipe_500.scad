$fn = 180;

// HT pipe parameters (mm)
outer_d = 160;     // nominal HT 160 outer diameter
length  = 500;     // pipe length
wall    = 4.7;     // typical HT wall thickness (approx.)
inner_d = outer_d - 2*wall;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od);
        translate([0,0,-0.1]) cylinder(h = L + 0.2, d = id);
    }
}

ht_pipe(outer_d, inner_d, length);