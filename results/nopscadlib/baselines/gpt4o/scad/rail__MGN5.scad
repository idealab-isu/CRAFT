module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -2.5, -1.8])
            cube([100, 5, 3.6]);
        
        // Cutouts for the rail
        translate([-50, -2.5, -1.8])
            for (i = [0:10:90]) {
                translate([i, 0, 0])
                    cube([10, 5, 1.2]);
            }
    }
}

linear_guide_rail();