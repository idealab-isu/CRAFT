module resistor() {
    // Main body of the resistor
    cylinder(h=10, d=5, $fn=64);
    
    // Left lead
    translate([-7.5, 0, 0])
        cylinder(h=5, d=1, $fn=32);
    
    // Right lead
    translate([7.5, 0, 0])
        cylinder(h=5, d=1, $fn=32);
}

resistor();