module linear_bearing_block() {
    difference() {
        // Main block
        cube([40, 68, 20], center = true);
        
        // Shaft hole
        translate([0, 0, 0])
            cylinder(h = 20, d = 8, $fn = 64, center = true);
    }
}

linear_bearing_block();