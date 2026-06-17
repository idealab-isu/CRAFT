$fn = 96;

shaft_d = 6.0;
length = 10.0;

head_flat_d = 11.5;   // across flats
head_h = 4.15;

module hex_prism(af, h) {
    // Regular hexagon: across-flats = 2*apothem => circumradius = af / sqrt(3)
    r = af / sqrt(3);
    linear_extrude(height = h)
        polygon(points = [for (i = [0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

union() {
    // Shaft
    cylinder(d = shaft_d, h = length);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_flat_d, head_h);
}