$fn = 96;

shaft_d = 8.0;
shaft_len = 10.0;

head_flat_d = 15.0;   // across flats
head_h = 5.65;

module hex_prism(af, h) {
    // Regular hexagon: across-flats = 2*apothem
    // Circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

union() {
    // Shaft
    cylinder(d = shaft_d, h = shaft_len);

    // Hex head on top of shaft
    translate([0,0,shaft_len])
        hex_prism(head_flat_d, head_h);
}