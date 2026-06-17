$fn = 96;

screw_d = 4.0;          // nominal screw diameter (M4)
clearance = 0.4;        // typical clearance for printed parts
hole_d = screw_d + clearance;

across_flats = 7.0;     // hex nut AF
thickness = 2.2;

module hex_prism_af(af, h) {
    // For a regular hexagon, circumradius R = AF / sqrt(3)
    R = af / sqrt(3);
    cylinder(h = h, r = R, $fn = 6);
}

difference() {
    hex_prism_af(across_flats, thickness);
    translate([0,0,-0.2])
        cylinder(h = thickness + 0.4, d = hole_d, $fn = 96);
}