$fn = 96;

shaft_d = 4.0;
length = 10.0;

head_flat_d = 8.1;      // across flats
head_h = 2.925;

module hex_prism(af, h) {
    // For a regular hexagon: across-flats = sqrt(3) * circumradius
    r = af / sqrt(3);
    cylinder(h = h, r = r, $fn = 6);
}

union() {
    // Shaft (unthreaded)
    cylinder(h = length, d = shaft_d);

    // Hex head on top
    translate([0, 0, length])
        hex_prism(head_flat_d, head_h);
}