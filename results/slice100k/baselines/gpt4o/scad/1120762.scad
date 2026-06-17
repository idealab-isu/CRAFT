module rounded_cube(size, radius, $fn=64) {
    minkowski() {
        cube(size - 2 * radius);
        sphere(r=radius, $fn=$fn);
    }
}

module star_hub() {
    union() {
        // Central hub
        translate([-6.6, -6.0, -3.15])
            rounded_cube([13.2, 12.0, 6.3], 1.0);

        // Arms
        for (angle = [0, 72, 144, 216, 288]) {
            rotate([0, 0, angle])
                translate([6.6, 0, -1.5])
                    rounded_cube([6.0, 2.0, 3.0], 0.5);
        }
    }
}

star_hub();