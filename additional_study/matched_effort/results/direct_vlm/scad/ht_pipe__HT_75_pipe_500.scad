$fn = 128;

// HT pipe parameters (approximate for HT 75)
od = 75;          // outer diameter (mm)
wall = 2.7;       // wall thickness (mm) typical for HT 75
len = 500;        // length (mm)

id = od - 2*wall;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.5])
            cylinder(h = len + 1, d = id);
    }
}

ht_pipe(od, id, len);