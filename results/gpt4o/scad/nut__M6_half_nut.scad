module hex_nut() {
    difference() {
        // Hexagon shape
        scale([1, 1, 0.5])
            cylinder(d=11.5, h=3.0, $fn=6);
        // Central hole for 6.0mm screw
        translate([0, 0, -1])
            cylinder(d=6.0, h=5.0, $fn=64);
    }
}

hex_nut();