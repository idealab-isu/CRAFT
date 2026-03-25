module hex_nut() {
    difference() {
        // Hexagon shape
        scale([11.5/2, 11.5/2, 5.0/2])
            cylinder(h=5.0, r=1, $fn=6);
        // Central hole for the screw
        translate([0, 0, -1])
            cylinder(h=7.0, r=3.0, $fn=64);
    }
}

hex_nut();