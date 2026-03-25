module stepper_motor() {
    difference() {
        // Main body of the motor
        translate([-21.15, -21.15, -20])
            cube([42.3, 42.3, 40], center=false);
        
        // Shaft
        translate([0, 0, 20])
            cylinder(h=10, d=5, $fn=64);
        
        // Mounting holes
        for (x = [-15.5, 15.5])
            for (y = [-15.5, 15.5])
                translate([x, y, 0])
                    cylinder(h=40, d=3, $fn=64);
    }
}

stepper_motor();