module linear_guide_rail() {
    difference() {
        // Main body of the rail
        translate([-50, -6, -4])
            cube([100, 12, 8]);
        
        // Cutout for the rail groove
        translate([-50, -3, -4])
            cube([100, 6, 4]);
        
        // Holes for mounting
        for (x = [-40, -20, 0, 20, 40]) {
            translate([x, 0, 0])
                cylinder(h=8, r=1.5, $fn=64);
        }
    }
}

linear_guide_rail();