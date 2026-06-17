$fn = 120;

screw_d      = 4.0;   // nominal screw diameter
clearance    = 0.3;   // clearance for through-bore
hole_d       = screw_d + clearance;

across_flats = 5.3;   // hex width across flats
thickness    = 6.3;   // nut thickness

eps = 0.02;

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = sqrt(3) * circumradius
    r = af / sqrt(3);
    cylinder(h = h, r = r, $fn = 6, center = true);
}

difference() {
    hex_prism_af(across_flats, thickness);
    cylinder(h = thickness + 2*eps, d = hole_d, $fn = 90, center = true);
}