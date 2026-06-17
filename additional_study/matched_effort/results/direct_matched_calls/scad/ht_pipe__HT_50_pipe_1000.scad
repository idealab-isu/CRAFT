$fn = 128;

// HT 50 pipe (approx.): DN 50, length 1000 mm
// Typical HT 50 dimensions (approx):
// - Outer diameter: 50 mm
// - Wall thickness: 1.8 mm
// Adjust as needed.

od = 50;
wall = 1.8;
id = od - 2*wall;
len = 1000;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h=len, d=od);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id);
    }
}

ht_pipe(od, id, len);