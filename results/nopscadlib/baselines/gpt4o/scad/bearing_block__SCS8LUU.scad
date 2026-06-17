module linear_bearing_block() {
    difference() {
        // Main block
        cube([34, 58, 20], center = true);
        
        // Shaft hole
        translate([0, 0, 0])
            rotate([90, 0, 0])
            cylinder(h = 34, d = 6, center = true, $fn = 64);
    }
}

linear_bearing_block();