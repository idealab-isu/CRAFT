$fn = 128;

// PVC aquarium tubing (hollow flexible tube)
inner_d = 6;          // mm
outer_d = 10;         // mm
length  = 200;        // mm

module tubing(od, id, h) {
    difference() {
        cylinder(h = h, d = od);
        translate([0,0,-0.5])
            cylinder(h = h + 1, d = id);
    }
}

tubing(outer_d, inner_d, length);