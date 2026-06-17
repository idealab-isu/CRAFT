$fn = 96;

// Socket head cap screw (approximate)
// Threaded shank: 2.0 mm diameter, 10 mm long
// Head: 3.8 mm diameter, 2.0 mm tall
// Hex socket: sized approximately for M2 (1.5 mm across flats)

d_shank = 2.0;
L_shank = 10.0;

d_head  = 3.8;
h_head  = 2.0;

// Hex socket (approx.)
hex_af = 1.5;          // across flats
hex_depth = 1.2;       // socket depth
hex_corner_d = 2*hex_af/sqrt(3); // circumscribed diameter for hex

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank
            cylinder(d = d_shank, h = L_shank);

            // Head
            translate([0,0,L_shank])
                cylinder(d = d_head, h = h_head);
        }

        // Hex socket cut
        translate([0,0,L_shank + h_head - hex_depth])
            cylinder(d = hex_corner_d, h = hex_depth + 0.05, $fn = 6);
    }
}

socket_head_cap_screw();