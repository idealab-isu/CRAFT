module brushless_dc_motor() {
    difference() {
        // Outer cylinder representing the stator
        cylinder(h = 14.5, d = 17.75, $fn = 64);
        
        // Inner cylinder representing the hollow part
        translate([0, 0, -1]) // Slightly extend to ensure complete cut
        cylinder(h = 16.5, d = 10, $fn = 64);
    }
}

brushless_dc_motor();