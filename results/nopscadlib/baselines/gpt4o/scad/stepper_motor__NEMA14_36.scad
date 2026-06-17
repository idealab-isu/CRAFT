module stepper_motor() {
    difference() {
        union() {
            // Main body of the motor
            translate([-17.6, -17.6, -18])
                cube([35.2, 35.2, 36.0]);
            
            // Shaft
            translate([0, 0, 18])
                cylinder(h=10, d=5.0, $fn=64);
        }
        
        // Mounting holes
        translate([-13, -13, -18])
            cylinder(h=36.0, d=3.0, $fn=64);
        translate([13, -13, -18])
            cylinder(h=36.0, d=3.0, $fn=64);
        translate([-13, 13, -18])
            cylinder(h=36.0, d=3.0, $fn=64);
        translate([13, 13, -18])
            cylinder(h=36.0, d=3.0, $fn=64);
    }
}

stepper_motor();