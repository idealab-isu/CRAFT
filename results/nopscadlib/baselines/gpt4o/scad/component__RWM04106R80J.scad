module resistor() {
    $fn = 64;
    // Main body of the resistor
    cylinder(h = 10, r = 3, center = true);
    
    // End caps
    translate([0, 0, 5])
        cylinder(h = 2, r1 = 3, r2 = 2, center = false);
    translate([0, 0, -7])
        cylinder(h = 2, r1 = 2, r2 = 3, center = false);
    
    // Wires
    translate([0, 0, 7])
        cylinder(h = 15, r = 0.5, center = false);
    translate([0, 0, -17])
        cylinder(h = 15, r = 0.5, center = false);
}

resistor();