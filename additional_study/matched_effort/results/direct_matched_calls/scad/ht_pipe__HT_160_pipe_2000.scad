$fn = 128;

// HT pipe parameters (mm)
outer_d = 160;
length  = 2000;

// Typical HT (house drainage) wall thickness for DN160 is ~4.9 mm.
// Adjust if you need a different standard.
wall_th = 4.9;

inner_d = outer_d - 2*wall_th;

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.5])
            cylinder(h = L + 1, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, length);