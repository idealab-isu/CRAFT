module panel_meter() {
    difference() {
        // Main body
        translate([-30, -15, 0])
        cube([60, 30, 10]);

        // Display cutout
        translate([-20, -10, -1])
        cube([40, 20, 11]);

        // Terminal cutouts
        translate([-28, -15, -1])
        cube([8, 30, 11]);
        translate([20, -15, -1])
        cube([8, 30, 11]);
    }
}

panel_meter();