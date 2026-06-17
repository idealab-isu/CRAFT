$fn = 120;

across_flats = 8.1;   // mm
thickness    = 3.2;   // mm
hole_d       = 4.0;   // mm (clearance as specified)

module hex_prism_af(af, h) {
    // For a regular hexagon: across_flats = sqrt(3) * circumradius
    r = af / sqrt(3);
    cylinder(h = h, r = r, $fn = 6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(h = thickness + 0.2, d = hole_d, $fn = 120);
}