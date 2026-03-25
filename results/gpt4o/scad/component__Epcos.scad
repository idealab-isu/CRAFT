module thermistor() {
    difference() {
        union() {
            // Main body of the thermistor
            translate([0, 0, -1])
                cylinder(h=3, r=1.5, $fn=64);
            // Leads of the thermistor
            translate([-0.5, 0, -4])
                cylinder(h=3, r=0.25, $fn=32);
            translate([0.5, 0, -4])
                cylinder(h=3, r=0.25, $fn=32);
        }
        // Flatten the bottom of the main body
        translate([0, 0, -1.5])
            cube([3, 3, 1], center=true);
    }
}

thermistor();