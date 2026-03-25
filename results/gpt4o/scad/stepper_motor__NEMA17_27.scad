module stepper_motor() {
    // Motor body
    difference() {
        cube([42.3, 42.3, 26.5], center = true);
        // Shaft hole
        translate([0, 0, 13.25])
            cylinder(h = 26.5, d = 5.0, $fn = 64);
    }
    
    // Mounting holes
    translate([-15.5, -15.5, 0])
        for (x = [0, 31.0])
            for (y = [0, 31.0])
                translate([x, y, 0])
                    cylinder(h = 26.5, d = 3.0, $fn = 64);
}

stepper_motor();