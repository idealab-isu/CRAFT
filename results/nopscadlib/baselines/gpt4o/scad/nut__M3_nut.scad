module hex_nut() {
    difference() {
        // Hexagonal prism for the nut
        scale([1, 1, 2.4/2]) 
            cylinder(d=6.4, h=1, $fn=6);
        // Hole for the screw
        translate([0, 0, -1])
            cylinder(d=3.0, h=4, $fn=64);
    }
}

hex_nut();