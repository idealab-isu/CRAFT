module servo_motor() {
    // Main body of the servo motor
    difference() {
        union() {
            // Main rectangular body
            translate([-20, -10, 0])
                cube([40, 20, 30]);
            // Top cylindrical part
            translate([0, 0, 30])
                cylinder(h=10, r=10, $fn=64);
        }
        // Shaft hole
        translate([0, 0, 30])
            cylinder(h=15, r=2, $fn=64);
    }
    
    // Mounting flanges
    translate([-25, -15, 0])
        cube([5, 40, 5]);
    translate([20, -15, 0])
        cube([5, 40, 5]);
    
    // Mounting holes
    translate([-22.5, -12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
    translate([-22.5, 12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
    translate([22.5, -12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
    translate([22.5, 12.5, 2.5])
        cylinder(h=5, r=1.5, $fn=64);
}

servo_motor();