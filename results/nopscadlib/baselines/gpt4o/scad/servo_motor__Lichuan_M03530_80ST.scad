module servo_motor() {
    difference() {
        // Main body of the servo motor
        translate([-20, -10, 0])
        cube([40, 20, 30]);

        // Shaft hole
        translate([0, 0, 15])
        cylinder(h=15, r=2, $fn=64);
    }
    
    // Mounting flanges
    translate([-25, -15, 0])
    cube([5, 40, 5]);
    
    translate([20, -15, 0])
    cube([5, 40, 5]);
    
    // Shaft
    translate([-2, -2, 30])
    cylinder(h=10, r=2, $fn=64);
}

servo_motor();