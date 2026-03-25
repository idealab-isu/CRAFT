module stepper_motor() {
    difference() {
        union() {
            // Motor body
            translate([0, 0, -15])
                cube([20, 20, 30], center=true);
            // Shaft
            translate([0, 0, 15])
                cylinder(h=10, d=5, center=false, $fn=64);
        }
        // Mounting holes
        translate([-8, -8, 0])
            cylinder(h=30, d=3, center=true, $fn=64);
        translate([8, -8, 0])
            cylinder(h=30, d=3, center=true, $fn=64);
        translate([-8, 8, 0])
            cylinder(h=30, d=3, center=true, $fn=64);
        translate([8, 8, 0])
            cylinder(h=30, d=3, center=true, $fn=64);
    }
}

stepper_motor();