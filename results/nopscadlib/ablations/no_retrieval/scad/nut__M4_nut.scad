$fn = 96;

// Parameters (mm)
across_flats   = 8.1;   // hex width across flats
thickness      = 3.2;   // nut thickness
hole_diameter  = 4.0;   // through hole
chamfer_size   = 0.3;   // lead-in
overlap        = 0.8;   // boolean safety

// Derived
hole_r = hole_diameter/2;

// For a regular hex: across_flats = 2*apothem, apothem = R*cos(30) => R = across_flats/sqrt(3)
hex_R = across_flats / sqrt(3);

module hex_prism(h, R) {
    // 6-flat hex prism, centered
    rotate([0,0,30]) cylinder(h=h, r=R, $fn=6, center=true);
}

module hole_with_chamfers() {
    union() {
        // Straight through-hole
        cylinder(h=thickness + 2*overlap, r=hole_r, center=true);

        // Top chamfer (connected via overlap)
        translate([0, 0, thickness/2 - chamfer_size/2])
            cylinder(h=chamfer_size + overlap, r1=hole_r + chamfer_size, r2=hole_r, center=true);

        // Bottom chamfer
        translate([0, 0, -thickness/2 + chamfer_size/2])
            cylinder(h=chamfer_size + overlap, r1=hole_r, r2=hole_r + chamfer_size, center=true);
    }
}

difference() {
    // Ensure correct orientation for all orthographic views (Z is thickness axis)
    hex_prism(thickness, hex_R);
    hole_with_chamfers();
}