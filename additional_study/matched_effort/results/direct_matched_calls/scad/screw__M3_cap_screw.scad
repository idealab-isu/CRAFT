$fn = 96;

d_shaft = 3.0;
L = 10.0;

d_head = 5.5;
h_head = 3.0;

hex_af = 2.5;          // typical for M3 socket
hex_depth = 1.6;       // typical socket depth
hex_corner_d = hex_af / cos(30);  // across corners for regular hex

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft
            cylinder(d = d_shaft, h = L);

            // Head
            translate([0,0,L])
                cylinder(d = d_head, h = h_head);
        }

        // Hex socket recess
        translate([0,0,L + h_head - hex_depth])
            cylinder(d = hex_corner_d, h = hex_depth + 0.02, $fn = 6);
    }
}

socket_head_cap_screw();