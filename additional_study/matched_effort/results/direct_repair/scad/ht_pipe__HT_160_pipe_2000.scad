$fn = 128;

// HT pipe parameters (mm)
od = 160;          // outer diameter
length = 2000;     // pipe length
wall = 4.9;        // typical HT 160 wall thickness (approx.)
id = od - 2*wall;  // inner diameter

module ht_pipe(od, id, length) {
    difference() {
        cylinder(h = length, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = length + 0.2, d = id, center = false);
    }
}

ht_pipe(od, id, length);