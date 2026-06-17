module box_section() {
    difference() {
        cube([50.8, 38.1, 3.0], center=true);
        translate([1.5, 1.5, 0])
            cube([50.8 - 3.0, 38.1 - 3.0, 3.0], center=true);
    }
}

box_section();