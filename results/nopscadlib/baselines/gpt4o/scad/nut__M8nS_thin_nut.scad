module hex_nut() {
    difference() {
        // Hexagon shape
        scale([13.0/2, 13.0/2, 4.0/2])
            cylinder(h=4.0, r=1, $fn=6);
        // Central hole
        translate([0, 0, -1])
            cylinder(h=6.0, r=4.0, $fn=64);
    }
}

hex_nut();