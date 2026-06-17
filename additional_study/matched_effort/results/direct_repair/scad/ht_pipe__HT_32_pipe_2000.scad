$fn = 128;

// HT pipe parameters (approx. for HT 32)
outer_d = 32;        // mm
wall_th = 1.8;       // mm (typical range ~1.8-2.0)
inner_d = outer_d - 2*wall_th;

length = 2000;       // mm

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od, center = false);
        translate([0,0,-0.1])
            cylinder(h = L + 0.2, d = id, center = false);
    }
}

ht_pipe(outer_d, inner_d, length);