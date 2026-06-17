module servo_motor() {
    difference() {
        // Main body of the servo motor
        translate([-20, -10, 0])
        cube([40, 20, 40]);

        // Shaft of the servo motor
        translate([0, 0, 40])
        cylinder(h=10, r=2.5, $fn=64);

        // Mounting flanges
        translate([-25, -15, 0])
        cube([5, 40, 5]);
        translate([20, -15, 0])
        cube([5, 40, 5]);

        // Holes in the mounting flanges
        translate([-22.5, -12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
        translate([22.5, -12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
        translate([-22.5, 12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
        translate([22.5, 12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
    }
}

servo_motor();