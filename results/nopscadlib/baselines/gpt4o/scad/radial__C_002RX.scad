module radial() {
    difference() {
        cylinder(h = 6, r1 = 2, r2 = 2, $fn = 64);
        translate([0, 0, -1])
            cylinder(h = 8, r1 = 0, r2 = 0, $fn = 64);
    }
}

radial();