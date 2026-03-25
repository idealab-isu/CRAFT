module hex_nut() {
    difference() {
        // Create hexagonal prism
        scale([1, 1, 1.8/2])  // Scale to thickness
        rotate([0, 0, 30])  // Align flat sides horizontally
        cylinder(r=5.5/sqrt(3), h=2, $fn=6);  // Hexagon with 5.5mm across flats

        // Subtract cylindrical hole
        translate([0, 0, -1])
        cylinder(r=3.0/2, h=4, $fn=64);  // 3.0mm diameter hole
    }
}

hex_nut();