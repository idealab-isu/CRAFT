$fn = 128;

// HT pipe parameters (approximate for HT 32)
length = 1000;          // mm
outer_d = 32;           // mm
wall = 1.8;             // mm (typical-ish for HT 32; adjust if needed)
inner_d = outer_d - 2*wall;

module ht_pipe(len=1000, od=32, id=28.4) {
    difference() {
        cylinder(h=len, d=od);
        translate([0,0,-0.5])
            cylinder(h=len+1, d=id);
    }
}

ht_pipe(length, outer_d, inner_d);