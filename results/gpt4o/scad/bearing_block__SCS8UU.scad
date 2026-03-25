module linear_bearing_block() {
    difference() {
        // Main block
        cube([34, 30, 10], center = true);
        
        // Shaft hole
        translate([0, 0, -5])
            cylinder(h = 20, d = 6, $fn = 64);
    }
}

linear_bearing_block();