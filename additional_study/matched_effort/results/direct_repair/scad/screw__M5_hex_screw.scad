$fn = 96;

shaft_d = 5.0;
length = 10.0;

head_flat_to_flat = 9.2;
head_h = 3.65;

module hex_prism(flat_to_flat, h) {
    // For a regular hexagon: flat-to-flat = sqrt(3) * R (circumradius)
    R = flat_to_flat / sqrt(3);
    cylinder(h = h, r = R, $fn = 6);
}

union() {
    // Shaft
    cylinder(h = length, d = shaft_d);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_flat_to_flat, head_h);
}