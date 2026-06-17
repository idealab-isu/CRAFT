$fn = 96;

// Dimensions (mm)
shaft_d = 6.0;
shaft_r = shaft_d/2;

head_flat_d = 11.5;          // across flats
head_h = 4.15;

length_under_head = 10.0;    // shaft length below head

module hex_prism(af, h) {
    // Regular hexagon: across flats = 2 * apothem
    // For a regular hexagon, apothem = R * cos(30) where R is circumradius
    // So R = (af/2) / cos(30)
    R = (af/2) / cos(30);
    linear_extrude(height=h)
        polygon(points=[for (i=[0:5]) [R*cos(60*i), R*sin(60*i)]]);
}

module hex_head_screw() {
    union() {
        // Shaft (under head)
        translate([0,0,-length_under_head])
            cylinder(h=length_under_head, r=shaft_r);

        // Hex head
        hex_prism(head_flat_d, head_h);
    }
}

hex_head_screw();