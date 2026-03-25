module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -10, -8.75])
            cube([100, 20, 17.5]);
        
        // Cutout for the rail groove
        translate([-50, -5, -8.75])
            cube([100, 10, 10]);
        
        // Holes for mounting
        for (x = [-40, -20, 0, 20, 40]) {
            translate([x, 0, 0])
                rotate([90, 0, 0])
                    cylinder(h=20, r=1.5, $fn=64);
        }
    }
}

linear_guide_rail();