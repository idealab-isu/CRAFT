module centrifugal_blower_fan() {
    difference() {
        // Outer casing
        translate([-20, -20, -4.75])
            cube([40, 40, 9.5]);

        // Inner cavity
        translate([-18, -18, -5])
            cube([36, 36, 10]);

        // Air outlet
        translate([0, -20, -4.75])
            cube([20, 10, 9.5]);

        // Fan blades
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([0, 0, -4.75])
                    fan_blade();
        }
    }
}

module fan_blade() {
    difference() {
        translate([-1, -10, 0])
            cube([2, 20, 9.5]);
        translate([-1, -10, -1])
            rotate([0, 0, 45])
                cube([2, 20, 10]);
    }
}

centrifugal_blower_fan();