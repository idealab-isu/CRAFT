$fn=96;

d_shank = 5.0;
l_shank = 10.0;

d_head = 10.0;
h_head = 5.0;

hex_flat = 4.0;
hex_depth = 3.0;

module hex_prism(flat=4, h=3) {
    r = flat / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw(d=5, l=10, dh=10, hh=5, hex_flat=4, hex_depth=3) {
    difference() {
        union() {
            translate([0,0,-l/2]) cylinder(h=l, d=d);
            translate([0,0,l/2]) cylinder(h=hh, d=dh);
        }
        translate([0,0,l/2 + hh - hex_depth]) hex_prism(flat=hex_flat, h=hex_depth + 0.2);
    }
}

socket_head_cap_screw(d=d_shank, l=l_shank, dh=d_head, hh=h_head, hex_flat=hex_flat, hex_depth=hex_depth);