$fn = 64;

module hex_nut() {
    difference() {
        // Create a hexagonal prism for the nut
        cylinder(h = 1.6, r = 2.5, $fn = 6, center = true);
        // Subtract the cylindrical thread bore
        translate([0, 0, -0.8])
            cylinder(h = 3.2, r = 1, $fn = 64);
    }
}

// Call the hex_nut module to render the nut
hex_nut();