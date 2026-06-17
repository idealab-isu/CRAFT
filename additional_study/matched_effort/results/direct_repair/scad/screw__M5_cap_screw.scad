$fn = 128;

d_shaft = 5.0;
L = 10.0;

d_head = 8.5;
h_head = 5.0;

hex_flat = 4.0;          // approximate for M5 socket
hex_depth = 3.0;         // approximate socket depth
hex_chamfer = 0.6;       // slight lead-in chamfer

module hex_prism(flat, h) {
    // Regular hex with given across-flats dimension
    r = flat / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(h=L, d=d_shaft);

            // Head
            translate([0,0,L])
                cylinder(h=h_head, d=d_head);
        }

        // Hex socket cut
        translate([0,0,L + h_head - hex_depth])
            hex_prism(hex_flat, hex_depth + 0.02);

        // Lead-in chamfer for socket
        translate([0,0,L + h_head - hex_depth - hex_chamfer])
            cylinder(h=hex_chamfer + 0.02, r1=(hex_flat/sqrt(3))*1.15, r2=(hex_flat/sqrt(3)), $fn=6);
    }
}

socket_head_cap_screw();