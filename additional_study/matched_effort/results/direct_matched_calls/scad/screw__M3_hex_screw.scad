$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_flat_d = 6.4;      // across flats
head_h = 2.125;

module hex_prism(af, h) {
    // Regular hexagon: across flats = 2 * apothem
    r = af / sqrt(3);   // circumradius
    cylinder(h = h, r = r, $fn = 6);
}

union() {
    // Shaft
    cylinder(h = length, d = shaft_d);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_flat_d, head_h);
}