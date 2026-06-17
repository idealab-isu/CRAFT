$fn = 128;

// HT pipe parameters (approximate for HT 75)
od = 75;          // outer diameter (mm)
wall = 2.7;       // wall thickness (mm) typical for HT DN75
len = 250;        // length (mm)

id = od - 2*wall;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.1])
            cylinder(h = len + 0.2, d = id);
    }
}

ht_pipe(od, id, len);