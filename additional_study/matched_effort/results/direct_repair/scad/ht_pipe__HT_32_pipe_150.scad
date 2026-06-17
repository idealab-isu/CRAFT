$fn = 128;

// HT pipe parameters (approximate for HT 32)
outer_d = 32;          // mm
wall = 1.8;            // mm (typical thin-wall HT)
inner_d = outer_d - 2*wall;
length = 150;          // mm

module ht_pipe(od, id, h) {
    difference() {
        cylinder(d=od, h=h);
        translate([0,0,-0.1]) cylinder(d=id, h=h+0.2);
    }
}

ht_pipe(outer_d, inner_d, length);