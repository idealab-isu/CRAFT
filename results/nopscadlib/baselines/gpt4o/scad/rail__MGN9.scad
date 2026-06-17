module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -4.5, -3])
            cube([100, 9, 6]);
        
        // Cutouts for the rail
        for (i = [-45, -15, 15, 45]) {
            translate([i, -4.5, -3])
                cube([10, 9, 3]);
        }
    }
}

linear_guide_rail();