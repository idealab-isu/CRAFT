$fn = 180;

// HT pipe parameters (approximate for HT 110)
outer_d = 110;      // mm
wall = 3.2;         // mm (typical HT/SML-like wall thickness approximation)
length = 500;       // mm

inner_d = outer_d - 2*wall;

module ht_pipe(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2, center=false);
    }
}

ht_pipe(outer_d, inner_d, length);