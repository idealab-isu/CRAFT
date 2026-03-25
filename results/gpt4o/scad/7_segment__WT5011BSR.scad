module segment() {
    difference() {
        cube([12.7, 19, 8.2], center = true);
        translate([-6.35, -9.5, -4.1])
            cube([10.7, 17, 8.2], center = true);
    }
}

translate([0, 0, 0])
    segment();