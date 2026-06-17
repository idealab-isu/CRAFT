module radial() {
    for (i = [0 : 3]) {
        rotate([0, 0, i * 90])
        translate([10.2, 0, 0])
        cylinder(h = 1, r1 = 5.3, r2 = 10.8, $fn = 64);
    }
}

radial();