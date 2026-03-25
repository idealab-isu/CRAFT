module hex_nut() {
    difference() {
        // Hexagonal prism
        scale([10/2, 10/2, 3.2/2])
            cylinder(h=3.2, r=1, $fn=6);
        // Circular hole
        translate([0, 0, -1])
            cylinder(h=5, r=3, $fn=64);
    }
}

hex_nut();