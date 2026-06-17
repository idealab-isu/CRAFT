module panel_meter() {
    difference() {
        // Main body of the panel meter
        translate([-50, -25, 0])
            cube([100, 50, 10]);

        // Display cutout
        translate([-30, -10, -1])
            cube([60, 20, 11]);

        // Button cutouts
        translate([-45, 15, -1])
            cylinder(h=11, r=3, $fn=64);
        translate([-30, 15, -1])
            cylinder(h=11, r=3, $fn=64);
        translate([-15, 15, -1])
            cylinder(h=11, r=3, $fn=64);
    }
}

panel_meter();