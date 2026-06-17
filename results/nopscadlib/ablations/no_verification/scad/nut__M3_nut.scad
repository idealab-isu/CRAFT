// Hex nut for M3 screw
// Target: 6.4mm across flats, 2.4mm thick, ~3.0mm internal hole (with clearance)

thread_diameter_mm   = 3.0;  // nominal screw diameter
across_flats_mm      = 6.4;  // AF
thickness_mm         = 2.4;  // height
hole_clearance_mm    = 0.2;  // radial clearance for printed hole
eps_mm               = 0.05; // small overlap for robust boolean ops

// Derived radii
hex_circumradius_mm = across_flats_mm / sqrt(3);                 // R such that AF = sqrt(3)*R
hole_radius_mm      = (thread_diameter_mm + hole_clearance_mm)/2;

module hex_nut() {
    difference() {
        // Hex body (one connected solid)
        cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);

        // Through hole (slightly taller to guarantee clean cut)
        cylinder(r=hole_radius_mm, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
}

hex_nut();