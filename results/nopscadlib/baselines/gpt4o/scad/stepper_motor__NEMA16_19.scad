module stepper_motor() {
    // Motor body
    difference() {
        cube([39.5, 39.5, 19.2], center=true);
        // Mounting holes
        translate([-15.5, -15.5, 0])
            cylinder(h=19.2, d=3, center=true, $fn=64);
        translate([15.5, -15.5, 0])
            cylinder(h=19.2, d=3, center=true, $fn=64);
        translate([-15.5, 15.5, 0])
            cylinder(h=19.2, d=3, center=true, $fn=64);
        translate([15.5, 15.5, 0])
            cylinder(h=19.2, d=3, center=true, $fn=64);
    }
    
    // Shaft
    translate([0, 0, 9.6])
        cylinder(h=10, d=5, center=false, $fn=64);
}

stepper_motor();