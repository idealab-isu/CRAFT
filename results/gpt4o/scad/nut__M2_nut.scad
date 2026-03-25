module hex_nut() {
    difference() {
        // Hexagon shape
        scale([4.9/2, 4.9/2, 1.6/2])
            cylinder(h=1.6, r=1, $fn=6);
        // Central hole for 2.0mm screw
        translate([0, 0, -1])
            cylinder(h=3.6, r=1.0, $fn=64);
    }
}

hex_nut();