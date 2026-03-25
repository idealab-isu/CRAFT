module stepper_motor() {
    // Motor body
    difference() {
        cube([42.3, 42.3, 34.0], center=true);
        // Shaft hole
        translate([0, 0, 17.0])
            cylinder(h=34.0, d=5.0, $fn=64);
    }
    
    // Shaft
    translate([0, 0, 17.0])
        cylinder(h=10.0, d=5.0, $fn=64);
    
    // Mounting holes
    for (x = [-15.5, 15.5])
        for (y = [-15.5, 15.5])
            translate([x, y, 0])
                cylinder(h=34.0, d=3.0, $fn=64);
}

stepper_motor();