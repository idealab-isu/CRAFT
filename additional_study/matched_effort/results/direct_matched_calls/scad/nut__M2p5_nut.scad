$fn = 120;

across_flats = 5.8;   // mm
thickness    = 2.2;   // mm
hole_d       = 2.7;   // mm (clearance for M2.5 screw)

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = 2 * apothem
    // apothem = R * cos(30°) where R is circumradius (vertex radius)
    R = af / (2 * cos(30));
    cylinder(h = h, r = R, $fn = 6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0, 0, -0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 80);
}