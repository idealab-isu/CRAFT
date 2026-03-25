module plate_with_boss() {
    difference() {
        // Main plate
        translate([-0.2, -0.25, 0])
        cube([0.4, 0.5, 0.05]);
        
        // Cutout for boss
        translate([-0.1, -0.15, 0.05])
        cube([0.2, 0.3, 0.05]);
    }
    // Boss
    translate([-0.1, -0.15, 0.05])
    cube([0.2, 0.3, 0.1]);
}

plate_with_boss();