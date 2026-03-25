module linear_guide_rail() {
    difference() {
        // Main body of the rail
        cube([100, 15, 15], center = true);
        
        // Cut out the rail groove
        translate([-50, -7.5, -7.5])
            cube([100, 5, 5], center = false);
        
        // Cut out the side grooves
        translate([-50, -7.5, 2.5])
            cube([100, 5, 5], center = false);
        
        translate([-50, 2.5, -7.5])
            cube([100, 5, 5], center = false);
    }
}

linear_guide_rail();