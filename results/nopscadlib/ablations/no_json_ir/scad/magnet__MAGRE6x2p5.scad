// Parameters
outer_diameter = 20; // Outer diameter of the magnet
height = 5;          // Height of the magnet
bore_diameter = 5;   // Diameter of the central bore
edge_rounding = 1;   // Edge rounding radius

// Magnet body with optional edge rounding
module magnet_body() {
    if (edge_rounding > 0) {
        cylinder(h = height - 2 * edge_rounding, d = outer_diameter - 2 * edge_rounding, center = true);
        translate([0, 0, -(height / 2 - edge_rounding)])
            cylinder(h = edge_rounding, d1 = outer_diameter, d2 = outer_diameter - 2 * edge_rounding, center = false);
        translate([0, 0, height / 2 - edge_rounding])
            cylinder(h = edge_rounding, d1 = outer_diameter - 2 * edge_rounding, d2 = outer_diameter, center = false);
    } else {
        cylinder(h = height, d = outer_diameter, center = true);
    }
}

// Optional central bore
module optional_center_bore() {
    if (bore_diameter > 0) {
        cylinder(h = height + 2, d = bore_diameter, center = true);
    }
}

// Complete magnet with optional bore
module magnet() {
    difference() {
        magnet_body();
        optional_center_bore();
    }
}

// Render the magnet
magnet();