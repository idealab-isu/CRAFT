module pillow_block_bearing() {
    difference() {
        union() {
            // Base
            translate([-27.5, -21, 0])
                cube([55, 42, 5]);
            
            // Bearing holder
            translate([-15, -15, 5])
                cylinder(h=20, r=15, $fn=64);
        }
        
        // Shaft hole
        translate([0, 0, 5])
            cylinder(h=20, r=4, $fn=64);
        
        // Mounting holes
        translate([-20, -15, 0])
            cylinder(h=5, r=3, $fn=32);
        translate([20, -15, 0])
            cylinder(h=5, r=3, $fn=32);
        translate([-20, 15, 0])
            cylinder(h=5, r=3, $fn=32);
        translate([20, 15, 0])
            cylinder(h=5, r=3, $fn=32);
    }
}

pillow_block_bearing();