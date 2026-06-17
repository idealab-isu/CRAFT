module hex_nut() {
    difference() {
        // Hexagonal prism for the nut
        scale([1, 1, 7.9/2]) 
            cylinder(d=7.7, h=2, $fn=6);
        
        // Cylindrical hole for the screw
        translate([0, 0, -10])
            cylinder(d=6, h=20, $fn=64);
    }
}

hex_nut();