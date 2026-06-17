module potentiometer() {
    difference() {
        union() {
            // Main body
            cylinder(h=6.5, d=12, $fn=64);
            // Knob
            translate([0, 0, 6.5])
                cylinder(h=1.0, d=12, $fn=64);
        }
        // Shaft hole
        translate([0, 0, -1])
            cylinder(h=8, d=6, $fn=64);
    }
}

potentiometer();