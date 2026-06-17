$fn = 128;

// HT pipe (approx.): DN40, length 500 mm
// Typical dimensions used:
// - Outer diameter: 40 mm
// - Wall thickness: 1.8 mm (approx.)
// - Length: 500 mm

length = 500;
od = 40;
wall = 1.8;
id = od - 2*wall;

module ht_pipe(len=500, outer_d=40, inner_d=36.4) {
    difference() {
        cylinder(h=len, d=outer_d, center=false);
        translate([0,0,-0.1])
            cylinder(h=len+0.2, d=inner_d, center=false);
    }
}

ht_pipe(length, od, id);