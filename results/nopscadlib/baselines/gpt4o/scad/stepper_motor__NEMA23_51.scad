module stepper_motor() {
    // Motor body
    difference() {
        cube([56.4, 56.4, 51.2], center = true);
        // Shaft hole
        translate([0, 0, 25.6])
            cylinder(h = 51.2, d = 6.35, $fn = 64);
    }
    
    // Shaft
    translate([0, 0, 25.6])
        cylinder(h = 20, d = 6.35, $fn = 64);
    
    // Mounting holes
    for (x = [-23.55, 23.55])
        for (y = [-23.55, 23.55])
            translate([x, y, 0])
                cylinder(h = 51.2, d = 3, $fn = 64);
}

stepper_motor();