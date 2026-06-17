$fn = 96;

d_shaft = 4.0;
L = 10.0;

d_head = 7.0;
h_head = 4.0;

// Typical ISO 4762 M4 socket dimensions (approx)
hex_af = 3.0;          // across flats
hex_depth = 2.2;       // socket depth
hex_corner_d = hex_af / cos(30); // across corners for a hex prism

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shaft (under-head length)
            translate([0,0,-L])
                cylinder(h=L, d=d_shaft);

            // Head
            cylinder(h=h_head, d=d_head);
        }

        // Hex socket cut
        translate([0,0,h_head - hex_depth])
            cylinder(h=hex_depth + 0.2, d=hex_corner_d, $fn=6);
    }
}

socket_head_cap_screw();