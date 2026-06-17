$fn = 128;

// HT 75 pipe, length 2000 mm (approx. DN75)
// Typical HT pipe outer diameter ~75 mm; wall thickness ~2.7 mm (approx.)
od = 75;
wall = 2.7;
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