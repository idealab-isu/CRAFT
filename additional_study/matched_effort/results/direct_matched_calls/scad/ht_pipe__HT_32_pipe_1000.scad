$fn = 128;

// HT 32 pipe, length 1000 mm (approx. DN32)
// Typical HT pipe outer diameter ~ 32 mm; wall thickness ~ 1.8 mm (approx.)
od = 32;
wall = 1.8;
id = od - 2*wall;
len = 1000;

module ht_pipe(od, id, len) {
    difference() {
        cylinder(h = len, d = od);
        translate([0,0,-0.1]) cylinder(h = len + 0.2, d = id);
    }
}

ht_pipe(od, id, len);