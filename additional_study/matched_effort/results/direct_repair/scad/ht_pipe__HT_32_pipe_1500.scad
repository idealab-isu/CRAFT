$fn = 128;

// HT pipe parameters (approximate for HT 32)
outer_d = 32;          // mm
wall_th = 1.8;         // mm (typical range ~1.8-2.0 for 32mm; adjust if needed)
inner_d = outer_d - 2*wall_th;

length = 1500;         // mm

module ht_pipe(od, id, L) {
    difference() {
        cylinder(h = L, d = od);
        translate([0,0,-0.5])
            cylinder(h = L + 1.0, d = id);
    }
}

ht_pipe(outer_d, inner_d, length);