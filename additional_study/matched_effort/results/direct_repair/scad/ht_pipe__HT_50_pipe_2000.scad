$fn = 128;

// HT 50 pipe (approx.): OD 50 mm, wall 1.8 mm, length 2000 mm
od = 50;
wall = 1.8;
id = od - 2*wall;
len = 2000;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = len + 0.2, d = id, center = false);
    }
}

ht_pipe(od, id, len);