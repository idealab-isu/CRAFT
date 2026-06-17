$fn = 120;

// Target dimensions
af = 11.5;          // across flats (mm)
thk = 3.0;          // thickness (mm)
screw_d = 6.0;      // through-hole diameter (mm)

// Small overlap to ensure watertight boolean ops
eps = 0.02;

// Derived
R = af / sqrt(3);   // circumradius for a true hex with given across-flats

module hex_prism(h) {
    // Use cylinder with $fn=6 for a crisp hex profile
    cylinder(h=h, r=R, $fn=6, center=true);
}

module through_hole(h) {
    cylinder(h=h, r=screw_d/2, center=true);
}

module hex_nut() {
    difference() {
        hex_prism(thk);
        through_hole(thk + 2*eps);
    }
}

hex_nut();