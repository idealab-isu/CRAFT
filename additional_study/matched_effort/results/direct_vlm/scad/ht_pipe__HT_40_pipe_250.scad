$fn = 128;

// HT 40 pipe (approx): DN40, OD 40 mm, typical wall ~1.8 mm
// Length: 250 mm
od = 40;
wall = 1.8;
id = od - 2*wall;
len = 250;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
    }
}

ht_pipe(od, id, len);