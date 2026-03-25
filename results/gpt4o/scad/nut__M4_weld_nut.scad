module hex_nut() {
    difference() {
        // Hexagonal prism for the nut
        scale([5.3/2, 5.3/2, 6.3/2])
            cylinder(h=6.3, r=1, $fn=6);
        
        // Cylindrical hole for the screw
        translate([0, 0, -1])
            cylinder(h=8.3, r=2, $fn=64);
    }
}

hex_nut();