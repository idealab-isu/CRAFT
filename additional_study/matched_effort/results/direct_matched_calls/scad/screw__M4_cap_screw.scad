$fn = 96;

// Socket head cap screw (approximate)
// Shank diameter: 4.0 mm
// Head diameter: 7.0 mm
// Head height: 4.0 mm
// Overall length under head: 10.0 mm

d_shank = 4.0;
d_head  = 7.0;
h_head  = 4.0;
l_shank = 10.0;

// Hex socket (approximate for M4: 3 mm across flats)
socket_af = 3.0;
socket_depth = 2.6;
socket_entry_chamfer = 0.4;

// Small edge chamfers
head_top_chamfer = 0.35;
head_bottom_chamfer = 0.25;
tip_chamfer = 0.6;

module hex_prism(af, h) {
    // across flats = af => circumradius = af / sqrt(3)
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank (under head)
            translate([0,0,-l_shank])
                cylinder(h=l_shank, d=d_shank);

            // Tip chamfer
            translate([0,0,-l_shank])
                cylinder(h=tip_chamfer, d1=0.01, d2=d_shank);

            // Head body
            cylinder(h=h_head, d=d_head);

            // Head top chamfer
            translate([0,0,h_head-head_top_chamfer])
                cylinder(h=head_top_chamfer, d1=d_head, d2=d_head-2*head_top_chamfer);

            // Head bottom chamfer (at junction to shank)
            translate([0,0,0])
                cylinder(h=head_bottom_chamfer, d1=d_head-2*head_bottom_chamfer, d2=d_head);
        }

        // Hex socket cut
        translate([0,0,h_head - socket_depth])
            hex_prism(socket_af, socket_depth + 0.02);

        // Socket entry chamfer
        translate([0,0,h_head - socket_entry_chamfer])
            cylinder(h=socket_entry_chamfer + 0.02,
                     d1=(socket_af / sqrt(3))*2 + 2*socket_entry_chamfer,
                     d2=(socket_af / sqrt(3))*2,
                     $fn=48);
    }
}

socket_head_cap_screw();