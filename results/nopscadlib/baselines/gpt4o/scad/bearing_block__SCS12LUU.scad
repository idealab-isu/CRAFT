module linear_bearing_block() {
    difference() {
        // Main block
        cube([42, 70, 20], center = true);
        
        // Shaft hole
        translate([0, 0, 0])
            rotate([90, 0, 0])
            cylinder(h = 42, r = 4, center = true, $fn = 64);
    }
}

linear_bearing_block();