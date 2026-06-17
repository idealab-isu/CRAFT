$fn = 96;

// Socket head cap screw (approx. ISO 4762)
// Given: shank diameter 6.0mm, head diameter 10.0mm, head height 6.0mm, length 10mm (under head)

d_shank = 6.0;
l_shank = 10.0;

d_head  = 10.0;
h_head  = 6.0;

// Hex socket (approx for M6): across flats ~5mm, depth ~4mm
af_socket = 5.0;
depth_socket = 4.0;

// Small edge chamfers
chamfer_head_top = 0.6;
chamfer_head_bottom = 0.3;
chamfer_shank_end = 0.4;

module hex_prism_across_flats(af, h) {
    // For a regular hexagon, across flats = 2 * apothem = sqrt(3) * R
    // So circumradius R = af / sqrt(3)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank (under head), with slight chamfer at free end
            translate([0,0,-l_shank])
            union() {
                cylinder(h=l_shank - chamfer_shank_end, d=d_shank);
                translate([0,0,l_shank - chamfer_shank_end])
                    cylinder(h=chamfer_shank_end, d1=d_shank, d2=d_shank - 2*chamfer_shank_end);
            }

            // Head with small bottom chamfer and top chamfer
            union() {
                // Main head body
                translate([0,0,chamfer_head_bottom])
                    cylinder(h=h_head - chamfer_head_bottom - chamfer_head_top, d=d_head);

                // Bottom chamfer (toward shank)
                cylinder(h=chamfer_head_bottom, d1=d_head - 2*chamfer_head_bottom, d2=d_head);

                // Top chamfer
                translate([0,0,h_head - chamfer_head_top])
                    cylinder(h=chamfer_head_top, d1=d_head, d2=d_head - 2*chamfer_head_top);
            }
        }

        // Hex socket cut
        translate([0,0,h_head - depth_socket])
            hex_prism_across_flats(af_socket, depth_socket + 0.2);
    }
}

socket_head_cap_screw();