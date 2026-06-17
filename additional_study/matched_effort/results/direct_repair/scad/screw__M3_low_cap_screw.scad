$fn = 96;

d_shaft = 3.0;
L = 10.0;

d_head = 5.5;
h_head = 2.0;

hex_flat = 2.5;          // approximate for M3 socket
hex_depth = 1.5;         // approximate recess depth
hex_corner = hex_flat / cos(30);

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
            cylinder(r = hex_corner/2, h = hex_depth + 0.02, $fn = 6);
    }
}

socket_head_cap_screw();