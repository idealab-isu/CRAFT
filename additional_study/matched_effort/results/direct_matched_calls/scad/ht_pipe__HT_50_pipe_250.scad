$fn = 128;

// HT pipe parameters (approx. for HT 50)
outer_d = 50;          // mm (nominal outer diameter)
wall = 1.8;            // mm (typical HT wall thickness)
inner_d = outer_d - 2*wall;

length = 250;          // mm

module ht_pipe(od, id, h) {
    difference() {
        cylinder(h = h, d = od);
        translate([0,0,-0.5])
            cylinder(h = h + 1, d = id);
    }
}

ht_pipe(outer_d, inner_d, length);