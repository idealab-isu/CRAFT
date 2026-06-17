$fn = 128;

// HT 90 pipe 1000 mm (approximation)
// Assumptions (typical HT DN90):
// - Outer diameter: 90 mm
// - Wall thickness: 2.7 mm
// - Length: 1000 mm

length = 1000;
od = 90;
wall = 2.7;
id = od - 2*wall;

module ht_pipe(len=1000, outer_d=90, inner_d=84.6) {
    difference() {
        cylinder(h=len, d=outer_d, center=false);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=inner_d, center=false);
    }
}

ht_pipe(length, od, id);