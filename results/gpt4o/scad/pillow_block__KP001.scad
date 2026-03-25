module pillow_block_bearing() {
    difference() {
        union() {
            // Base
            translate([-35.5, -28, 0])
                cube([71, 56, 10]);
            
            // Bearing housing
            translate([0, 0, 10])
                cylinder(h=30, d=40, $fn=64);
            
            // Shaft hole
            translate([0, 0, 10])
                cylinder(h=30, d=12, $fn=64);
        }
        
        // Mounting holes
        translate([-25, -18, 0])
            cylinder(h=10, d=8, $fn=64);
        translate([25, -18, 0])
            cylinder(h=10, d=8, $fn=64);
        translate([-25, 18, 0])
            cylinder(h=10, d=8, $fn=64);
        translate([25, 18, 0])
            cylinder(h=10, d=8, $fn=64);
    }
}

pillow_block_bearing();