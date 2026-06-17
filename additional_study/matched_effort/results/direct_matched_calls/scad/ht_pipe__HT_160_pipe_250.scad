$fn = 180;

// HT pipe parameters (approximation)
od = 160;          // outer diameter in mm
length = 250;      // pipe length in mm
wall = 4.9;        // typical HT 160 wall thickness (approx.)
id = od - 2*wall;  // inner diameter

module ht_pipe(od, id, length) {
    difference() {
        cylinder(h = length, d = od);
        translate([0,0,-0.5])
            cylinder(h = length + 1, d = id);
    }
}

ht_pipe(od, id, length);