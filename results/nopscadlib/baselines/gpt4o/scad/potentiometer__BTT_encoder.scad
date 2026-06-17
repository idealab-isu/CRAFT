module potentiometer() {
    difference() {
        union() {
            // Main body
            cylinder(h = 12, d = 11, $fn = 64);
            // Knob
            translate([0, 0, 12])
                cylinder(h = 6, d = 6, $fn = 64);
        }
        // Shaft hole
        translate([0, 0, -1])
            cylinder(h = 13, d = 0.5, $fn = 64);
    }
}

potentiometer();