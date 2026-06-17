$fn = 96;

// Target dimensions
across_flats = 6.4;   // mm
thickness    = 2.4;   // mm
hole_d       = 3.0;   // mm (clearance/through hole)

// Derived
R = across_flats / sqrt(3);  // circumradius for a hex with given across-flats
eps = 0.02;

module hex_prism(af, h) {
    linear_extrude(height=h, center=true)
        circle(r=af/sqrt(3), $fn=6);
}

module nut() {
    difference() {
        // One connected solid: simple hex prism at exact size
        hex_prism(across_flats, thickness);

        // Through hole (extend beyond thickness to guarantee cut)
        cylinder(h=thickness + 2*eps, d=hole_d, center=true);
    }
}

nut();