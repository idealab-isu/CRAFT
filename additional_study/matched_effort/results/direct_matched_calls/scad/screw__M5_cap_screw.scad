$fn = 96;

d_shaft = 5.0;
L = 10.0;

d_head = 8.5;
h_head = 5.0;

// Approximate hex socket for M5 socket head cap screw
socket_af = 4.0;          // across flats
socket_depth = 3.0;       // depth
socket_corner_r = socket_af / sqrt(3); // circumradius for hex

module hex_prism(r, h) {
    cylinder(r=r, h=h, $fn=6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(d=d_shaft, h=L);

            // Head
            translate([0,0,L])
                cylinder(d=d_head, h=h_head);
        }

        // Hex socket cut
        translate([0,0,L + h_head - socket_depth])
            hex_prism(socket_corner_r, socket_depth + 0.2);
    }
}

socket_head_cap_screw();