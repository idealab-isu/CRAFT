$fn = 120;

across_flats = 7.7;   // mm
thickness    = 7.9;   // mm
hole_diam    = 6.0;   // mm (through-bore)

eps = 0.05;

module hex_prism_af(af, h) {
    // across-flats = 2*apothem; circumradius R = apothem / cos(30°)
    R = (af/2) / cos(30);
    cylinder(h=h, r=R, $fn=6, center=true);
}

difference() {
    hex_prism_af(across_flats, thickness);
    // Ensure a clean through-hole in all views by overcutting in Z
    cylinder(h=thickness + 2*eps, d=hole_diam, center=true, $fn=120);
}