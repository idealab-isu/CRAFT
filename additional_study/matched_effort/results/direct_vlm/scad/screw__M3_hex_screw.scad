$fn = 96;

shaft_d = 3.0;
length = 10.0;

head_flat_to_flat = 6.4;   // across flats
head_h = 2.125;

module hex_prism(flat_to_flat, h){
    // For a regular hexagon: across flats = 2*apothem = sqrt(3)*R (circumradius)
    R = flat_to_flat / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

union() {
    // Shaft (under-head length)
    cylinder(h=length, d=shaft_d);

    // Hex head on top
    translate([0,0,length])
        hex_prism(head_flat_to_flat, head_h);
}