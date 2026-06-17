$fn = 96;

screw_d = 4.0;          // nominal screw diameter (mm)
clearance = 0.4;        // typical clearance for M4-ish hole (mm)
hole_d = screw_d + clearance;

across_flats = 7.0;     // mm
thickness = 2.2;        // mm

module hex_prism_af(af, h) {
    // For a regular hexagon: across flats = 2 * apothem
    // Circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h = h, r = R, $fn = 6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0, 0, -0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 96);
}