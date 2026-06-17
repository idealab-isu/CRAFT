module brushless_dc_motor() {
    difference() {
        // Outer casing of the motor
        cylinder(h=12.0, d=23.0, $fn=64);
        
        // Hollow inside for the stator
        translate([0, 0, 1])
            cylinder(h=10.0, d=20.0, $fn=64);
    }
}

brushless_dc_motor();