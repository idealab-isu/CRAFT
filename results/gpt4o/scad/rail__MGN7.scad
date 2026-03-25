module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -3.5, -2.5])
            cube([100, 7, 5]);
        
        // Cutouts for the rail
        translate([-50, -3.5, -2.5])
            for (i = [0:10:90])
                translate([i, 0, 0])
                    cube([10, 7, 2.5]);
    }
}

linear_guide_rail();