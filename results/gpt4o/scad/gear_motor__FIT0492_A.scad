module gear_motor() {
    difference() {
        union() {
            // Main body of the motor
            translate([0, 0, -7.35])
                cylinder(h=14.7, d=12, $fn=64);
            // Gear part
            translate([0, 0, 7.35])
                cylinder(h=5.5, d=6, $fn=64);
        }
        // Shaft hole
        translate([0, 0, -7.35])
            cylinder(h=20, d=2, $fn=64);
    }
}

gear_motor();