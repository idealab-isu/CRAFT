module hex_nut() {
    difference() {
        // Hexagonal prism for the nut
        scale([9.2/2, 9.2/2, 4.0/2])
            cylinder(h=4.0, r=1, $fn=6);
        
        // Cylindrical hole for the screw
        translate([0, 0, -1])
            cylinder(h=6.0, r=2.5, $fn=64);
    }
}

hex_nut();