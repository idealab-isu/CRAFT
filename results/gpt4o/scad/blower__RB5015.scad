module centrifugal_blower_fan() {
    difference() {
        // Main body of the blower
        translate([-25.65, -25.5, -7.5])
            cube([51.3, 51.0, 15.0]);

        // Air outlet
        translate([0, 25.5, -7.5])
            cube([20.0, 10.0, 15.0]);

        // Inner cylinder for the fan
        translate([0, 0, -7.5])
            cylinder(h=15.0, r=10.0, $fn=64);

        // Central hole
        translate([0, 0, -7.5])
            cylinder(h=15.0, r=3.0, $fn=64);
    }
}

centrifugal_blower_fan();