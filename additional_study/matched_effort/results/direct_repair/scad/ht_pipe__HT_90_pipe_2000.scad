$fn = 128;

// HT 90 pipe 2000 mm (interpreted as: DN90 sewer pipe, 2000 mm length)
// Typical HT DN90 dimensions (approx):
// - Outer diameter: 90 mm
// - Wall thickness: 2.7 mm
// Adjust as needed.
od = 90;
t  = 2.7;
id = od - 2*t;
L  = 2000;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h=L, d=od);
        translate([0,0,-0.5])
            cylinder(h=L+1, d=id);
    }
}

ht_pipe(od, id, L);