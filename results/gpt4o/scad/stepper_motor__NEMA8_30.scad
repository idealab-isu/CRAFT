module stepper_motor() {
    // Motor body
    difference() {
        union() {
            // Main body
            translate([0, 0, -15])
                cube([20, 20, 30], center=true);
            // Shaft
            translate([0, 0, 15])
                cylinder(h=10, d=4, $fn=64);
        }
        // Mounting holes
        for (x = [-8, 8], y = [-8, 8]) {
            translate([x, y, 0])
                cylinder(h=30, d=2, center=true, $fn=64);
        }
    }
}

stepper_motor();