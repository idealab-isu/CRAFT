module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -7.5, -6.25])
            cube([100, 15, 12.5]);

        // Cut out the rail groove
        translate([-50, -3.5, -6.25])
            cube([100, 7, 6.25]);

        // Cut out the side grooves
        translate([-50, -7.5, 0])
            cube([100, 2, 6.25]);
        translate([-50, 5.5, 0])
            cube([100, 2, 6.25]);
    }
}

linear_guide_rail();