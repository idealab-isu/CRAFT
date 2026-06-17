$fn = 128;

// HT pipe (approx.) - HT 40, length 2000 mm
// Typical HT 40 dimensions (approx): OD 40 mm, wall 1.8 mm
// Adjust if you have exact manufacturer specs.
od = 40;
wall = 1.8;
id = od - 2*wall;
len = 2000;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.5])
            cylinder(h = len + 1, d = id);
    }
}

ht_pipe(od, id, len);