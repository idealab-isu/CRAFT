$fn=96;

// Dimensions (mm)
shaft_d = 6.0;
shaft_r = shaft_d/2;

head_flat_d = 11.5;          // across flats
head_h = 4.15;

length_under_head = 10.0;    // shaft length (excluding head)

// Helpers
module hex_prism(af, h){
    // Regular hexagon: across flats = 2*apothem
    // For a regular hexagon, circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

union() {
    // Shaft (under head)
    translate([0,0,-length_under_head])
        cylinder(h=length_under_head, r=shaft_r);

    // Hex head
    hex_prism(head_flat_d, head_h);
}