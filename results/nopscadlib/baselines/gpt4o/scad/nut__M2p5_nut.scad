module hex_nut() {
    difference() {
        // Hexagon shape
        scale([5.8/2, 5.8/2, 2.2/2])
            cylinder(h=2.2, r=1, $fn=6);
        // Hole for the screw
        translate([0, 0, -1])
            cylinder(h=4, r=1.25, $fn=64);
    }
}

hex_nut();