$fn = 128;

// HT 50 pipe (approx.): DN50, length 1000 mm
// Typical HT dimensions (approx):
// - Outer diameter: 50 mm
// - Wall thickness: 1.8 mm
// - Inner diameter: 46.4 mm
// Adjust as needed.

length = 1000;
od = 50;
wall = 1.8;
id = od - 2*wall;

module ht_pipe(len=length, outer_d=od, inner_d=id) {
    difference() {
        cylinder(h=len, d=outer_d, center=false);
        translate([0,0,-0.1]) cylinder(h=len+0.2, d=inner_d, center=false);
    }
}

ht_pipe();