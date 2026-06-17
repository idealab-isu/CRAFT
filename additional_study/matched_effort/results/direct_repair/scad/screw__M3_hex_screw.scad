$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_flat_d = 6.4;      // across flats
head_h = 2.125;

module hex_prism(af, h) {
    // Regular hexagon: across-flats = 2*apothem = af
    // Circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

union() {
    // Shaft
    cylinder(d = shaft_d, h = length);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_flat_d, head_h);
}