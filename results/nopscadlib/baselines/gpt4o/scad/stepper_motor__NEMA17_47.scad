module stepper_motor() {
    difference() {
        // Main body of the stepper motor
        translate([-21.15, -21.15, -23.5])
            cube([42.3, 42.3, 47.0]);

        // Shaft hole
        translate([0, 0, 23.5])
            cylinder(h=47.0, d=5.0, $fn=64);

        // Mounting holes
        for (x = [-15.5, 15.5])
            for (y = [-15.5, 15.5])
                translate([x, y, 0])
                    cylinder(h=47.0, d=3.0, $fn=64);
    }
}

stepper_motor();