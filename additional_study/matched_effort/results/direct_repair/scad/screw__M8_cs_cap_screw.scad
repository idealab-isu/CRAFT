$fn = 128;

// Socket Head Cap Screw (approx. ISO 4762 style)
// Given: shank diameter = 8.0 mm, head diameter = 16.0 mm, length under head = 10 mm

d_shank = 8.0;
l_shank = 10.0;

d_head  = 16.0;
h_head  = 8.0;          // typical for M8 socket head cap screw

d_socket = 6.0;         // typical hex socket across flats ~6 mm for M8
socket_depth = 5.0;     // typical

// Small edge chamfers (approximated as short tapers)
chamfer_h = 0.6;
chamfer_delta = 1.0;

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank (unthreaded cylinder)
            translate([0,0,0])
                cylinder(h = l_shank, d = d_shank);

            // Head with slight top chamfer
            translate([0,0,l_shank])
                union() {
                    // Main head body
                    cylinder(h = h_head - chamfer_h, d = d_head);

                    // Top chamfer (taper)
                    translate([0,0,h_head - chamfer_h])
                        cylinder(h = chamfer_h, d1 = d_head, d2 = d_head - chamfer_delta);
                }

            // Under-head fillet/chamfer approximation (taper from shank to head)
            translate([0,0,l_shank - chamfer_h])
                cylinder(h = chamfer_h, d1 = d_shank, d2 = d_head);
        }

        // Hex socket cut
        translate([0,0,l_shank + h_head - socket_depth])
            cylinder(h = socket_depth + 0.2, d = (d_socket / cos(30)), $fn = 6);
    }
}

socket_head_cap_screw();