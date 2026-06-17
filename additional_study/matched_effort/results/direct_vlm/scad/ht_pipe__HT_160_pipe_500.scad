$fn = 128;

// HT pipe parameters (approximate for HT 160)
outer_d = 160;      // mm
wall_th = 4.9;      // mm (typical for DN160 HT pipe; adjust if needed)
length = 500;       // mm

inner_d = outer_d - 2*wall_th;

module ht_pipe(od, id, h) {
    difference() {
        cylinder(h = h, d = od);
        translate([0,0,-0.5])
            cylinder(h = h + 1, d = id);
    }
}

ht_pipe(outer_d, inner_d, length);