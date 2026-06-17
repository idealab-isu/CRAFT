module brushless_dc_motor() {
    difference() {
        // Outer casing
        cylinder(h = 17.25, d = 28.0, $fn = 64);
        
        // Inner hollow part
        translate([0, 0, -1])
            cylinder(h = 19.25, d = 20.0, $fn = 64);
    }
}

brushless_dc_motor();