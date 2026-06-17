$fn = 96;

// Target dimensions
af = 5.5;          // across flats (mm)
thickness = 1.8;   // nut thickness (mm)
hole_d = 3.0;      // through-hole diameter for M3 clearance (mm)

// Derived
hex_R = af / sqrt(3);          // circumradius for a hex with given across-flats
hole_r = hole_d / 2;
eps = 0.02;

module hex_prism(af, h) {
    // Use cylinder with $fn=6; r is circumradius. Rotate so flats are horizontal.
    rotate([0, 0, 30])
        cylinder(h = h, r = af / sqrt(3), center = true, $fn = 6);
}

module through_hole(r, h) {
    cylinder(h = h, r = r, center = true);
}

module nut() {
    difference() {
        hex_prism(af, thickness);

        // Ensure the cut fully passes through (no coplanar faces)
        through_hole(hole_r, thickness + 2*eps);
    }
}

nut();