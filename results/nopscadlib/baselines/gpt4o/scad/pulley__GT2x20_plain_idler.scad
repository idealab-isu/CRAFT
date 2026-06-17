module pulley() {
    difference() {
        // Outer cylinder
        cylinder(h=10, r=30, $fn=64);
        
        // Inner cylinder (hole)
        translate([0, 0, -1])
            cylinder(h=12, r=10, $fn=64);
        
        // Groove
        translate([0, 0, 2])
            cylinder(h=6, r=25, $fn=64);
    }
}

pulley();