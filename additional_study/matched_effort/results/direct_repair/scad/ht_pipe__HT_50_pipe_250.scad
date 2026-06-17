$fn = 128;

// HT 50 pipe (approx.): DN 50, length 250 mm
// Typical HT dimensions (approx):
// - Outer diameter: 50 mm
// - Wall thickness: 1.8 mm  -> inner diameter: 46.4 mm
// Adjust if you need exact manufacturer dimensions.

length = 250;
od = 50;
wall = 1.8;
id = od - 2*wall;

module ht_pipe(L=250, OD=50, ID=46.4) {
    difference() {
        cylinder(h=L, d=OD);
        translate([0,0,-0.1]) cylinder(h=L+0.2, d=ID);
    }
}

ht_pipe(length, od, id);