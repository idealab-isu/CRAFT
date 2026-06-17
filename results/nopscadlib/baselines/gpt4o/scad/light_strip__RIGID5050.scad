module light_strip(length = 100, width = 10, height = 2) {
    difference() {
        cube([length, width, height], center = true);
        translate([0, 0, height / 2])
            cube([length - 2, width - 2, height], center = true);
    }
}

light_strip();