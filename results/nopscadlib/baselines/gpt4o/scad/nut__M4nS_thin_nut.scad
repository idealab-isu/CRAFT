module hex_nut() {
    difference() {
        // Hexagon shape
        scale([1, 1, 2.2/2]) 
            cylinder(d=7.0, h=2.2, $fn=6);
        // Hole for the screw
        translate([0, 0, -1])
            cylinder(d=4.0, h=4.2, $fn=64);
    }
}

hex_nut();