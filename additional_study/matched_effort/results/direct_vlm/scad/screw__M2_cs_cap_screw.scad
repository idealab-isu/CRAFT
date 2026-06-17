$fn = 96;

d_shaft = 2.0;
L = 10.0;

d_head = 3.8;
h_head = 2.0;

socket_af = 1.5;      // hex across flats (approx for M2)
socket_depth = 1.2;   // socket depth
socket_chamfer = 0.25;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3);
    cylinder(h = h, r = r, $fn = 6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            translate([0,0,-L])
                cylinder(h = L, d = d_shaft);

            // Head (slight top edge chamfer)
            cylinder(h = h_head, d = d_head);
            translate([0,0,h_head-0.25])
                cylinder(h = 0.25, d1 = d_head, d2 = d_head - 0.4);
        }

        // Hex socket
        translate([0,0,h_head - socket_depth])
            hex_prism(socket_af, socket_depth + 0.02);

        // Small lead-in chamfer for socket
        translate([0,0,h_head - socket_depth - 0.001])
            cylinder(h = socket_chamfer, d1 = socket_af*1.25, d2 = socket_af*1.05, $fn = 48);
    }
}

socket_head_cap_screw();