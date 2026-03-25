module pulley() {
    difference() {
        // Outer cylinder
        cylinder(h=10, r=30, $fn=64);
        // Inner cylinder (hole)
        translate([0, 0, -1])
            cylinder(h=12, r=10, $fn=64);
        // Groove
        translate([0, 0, 3])
            cylinder(h=4, r1=25, r2=20, $fn=64);
    }
}

pulley();