module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -7.5, -5])
            cube([100, 15, 10]);
        
        // Cutouts for the rail
        translate([-50, -7.5, -5])
            cube([100, 5, 10]);
        
        translate([-50, 2.5, -5])
            cube([100, 5, 10]);
    }
}

linear_guide_rail();