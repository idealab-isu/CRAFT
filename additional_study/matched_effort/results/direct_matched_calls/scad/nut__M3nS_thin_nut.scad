$fn = 96;

across_flats = 5.5;   // mm
thickness    = 1.8;   // mm
screw_d      = 3.0;   // mm (clearance hole)

clearance = 0.25;     // mm added to screw diameter for clearance
hole_d = screw_d + clearance;

module hex_prism_af(af, h) {
    // For a regular hexagon, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h = h, r = R, $fn = 6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.1])
        cylinder(h = thickness + 0.2, d = hole_d, $fn = 96);
}