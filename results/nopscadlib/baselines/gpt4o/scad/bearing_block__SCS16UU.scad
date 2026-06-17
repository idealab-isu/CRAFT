module linear_bearing_block() {
    difference() {
        // Main block
        cube([50, 44, 20], center = true);
        
        // Shaft hole
        translate([0, 0, -10])
            cylinder(h = 40, d = 9, $fn = 64, center = true);
    }
}

linear_bearing_block();