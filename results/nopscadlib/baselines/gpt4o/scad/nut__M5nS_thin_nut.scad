module hex_nut() {
    difference() {
        // Hexagon shape
        scale([1, 1, 2.7/2]) 
            cylinder(d=8.0, h=2.7, $fn=6);
        // Hole for the screw
        translate([0, 0, -1])
            cylinder(d=5.0, h=4.7, $fn=64);
    }
}

hex_nut();