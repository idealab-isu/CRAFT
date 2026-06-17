// Thin hex nut: 5.0mm through-hole, 8.0mm across flats, 2.7mm thick

module hex_nut(af=8.0, thickness=2.7, hole_d=5.0) {
    // For a regular hex, across-flats = 2 * apothem = sqrt(3) * R (circumradius)
    R = af / sqrt(3);
    eps = 0.02;

    difference() {
        // Centered body for robust boolean operations and clear side views
        cylinder(h=thickness, r=R, $fn=6, center=true);

        // Through-hole (slightly extended to guarantee a clean cut)
        cylinder(h=thickness + 2*eps, r=hole_d/2, $fn=64, center=true);
    }
}

hex_nut();