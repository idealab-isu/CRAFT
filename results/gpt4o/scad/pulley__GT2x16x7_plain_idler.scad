module pulley() {
    difference() {
        // Outer cylinder for the pulley
        cylinder(h=20, r=50, $fn=64);
        
        // Inner cylinder to create the groove
        translate([0, 0, 5])
            cylinder(h=10, r=40, $fn=64);
        
        // Hole for the axle
        translate([0, 0, -5])
            cylinder(h=30, r=10, $fn=64);
    }
}

pulley();