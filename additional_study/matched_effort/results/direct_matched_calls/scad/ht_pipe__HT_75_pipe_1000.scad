$fn = 128;

// HT 75 pipe, length 1000 mm
// Assumptions (typical for HT DN75):
// - Outer diameter: 75 mm
// - Wall thickness: 2.7 mm
// - Straight pipe (no socket), centered at origin along Z

od = 75;
t  = 2.7;
id = od - 2*t;
L  = 1000;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = true);
        cylinder(h = L + 2, d = id, center = true);
    }
}

ht_pipe(od, id, L);