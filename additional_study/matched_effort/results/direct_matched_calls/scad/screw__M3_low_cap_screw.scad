$fn = 96;

d_shaft = 3.0;
L = 10.0;

d_head = 5.5;
h_head = 2.0;

hex_flat = 2.5;          // approximate for M3 socket
hex_depth = 1.5;         // approximate socket depth
chamfer = 0.25;

module hex_prism(flat, h) {
    // flat-to-flat = flat
    r = flat / sqrt(3);  // circumradius for regular hex
    cylinder(h = h, r = r, $fn = 6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(h = L, d = d_shaft);

            // Head
            translate([0,0,L])
            cylinder(h = h_head, d = d_head);

            // Small top chamfer (adds a slight bevel by adding a frustum)
            translate([0,0,L + h_head - chamfer])
            cylinder(h = chamfer, d1 = d_head, d2 = d_head - 2*chamfer);
        }

        // Hex socket
        translate([0,0,L + h_head - hex_depth])
        hex_prism(hex_flat, hex_depth + 0.01);
    }
}

socket_head_cap_screw();