module axial() {
    difference() {
        cylinder(h = 0.3, r1 = 1.7, r2 = 1.7, $fn = 64);
        translate([0, 0, -0.1])
            cylinder(h = 0.5, r1 = 1.4, r2 = 1.4, $fn = 64);
    }
}

translate([0, 0, 0.15])
    rotate([0, 0, 90])
        scale([3.4, 1.75, 1])
            axial();