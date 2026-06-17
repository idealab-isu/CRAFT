$fn = 120;

across_flats = 6.4;   // mm
thickness    = 2.4;   // mm
hole_d       = 3.0;   // mm (clearance as specified)

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = sqrt(3) * circumradius
    r = af / sqrt(3);
    cylinder(h = h, r = r, $fn = 6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 90);
}