$fn = 128;

// HT pipe parameters (approximate, in mm)
od = 75;          // outer diameter
len = 250;        // length
wall = 2.7;       // typical HT 75 wall thickness (approx.)
id = od - 2*wall; // inner diameter

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
    }
}

ht_pipe(od, id, len);