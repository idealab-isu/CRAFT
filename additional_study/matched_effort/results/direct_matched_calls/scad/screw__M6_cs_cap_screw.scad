$fn = 96;

// Socket Head Cap Screw (approx. ISO 4762 / DIN 912 style)
// Given: shank diameter = 6.0 mm, head diameter = 12.0 mm, length under head = 10 mm

d_shank = 6.0;
L = 10.0;

d_head = 12.0;
h_head = 6.0;          // typical for M6 SHCS

// Hex socket (approx for M6)
socket_af = 5.0;       // across flats
socket_depth = 3.5;
socket_entry_chamfer = 0.6;

// Small edge chamfers
head_top_chamfer = 0.4;
head_bottom_chamfer = 0.3;
shank_tip_chamfer = 0.6;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module chamfered_cylinder(h, d, chamfer_top=0, chamfer_bottom=0) {
    // Creates a cylinder with optional 45-ish chamfers by using tapered sections
    // chamfer values are axial heights of the chamfer sections.
    d0 = d;
    d_top = max(0, d0 - 2*chamfer_top);
    d_bot = max(0, d0 - 2*chamfer_bottom);

    union() {
        // bottom chamfer
        if (chamfer_bottom > 0)
            cylinder(h=chamfer_bottom, d1=d_bot, d2=d0);

        // middle straight
        mid_h = h - chamfer_top - chamfer_bottom;
        if (mid_h > 0)
            translate([0,0,chamfer_bottom])
                cylinder(h=mid_h, d=d0);

        // top chamfer
        if (chamfer_top > 0)
            translate([0,0,h - chamfer_top])
                cylinder(h=chamfer_top, d1=d0, d2=d_top);
    }
}

difference() {
    union() {
        // Shank (unthreaded for simplicity)
        translate([0,0,0])
            chamfered_cylinder(h=L, d=d_shank, chamfer_top=0, chamfer_bottom=shank_tip_chamfer);

        // Head
        translate([0,0,L])
            chamfered_cylinder(h=h_head, d=d_head, chamfer_top=head_top_chamfer, chamfer_bottom=head_bottom_chamfer);
    }

    // Hex socket cut
    translate([0,0,L + h_head - socket_depth])
        hex_prism(socket_af, socket_depth + 0.01);

    // Socket entry chamfer (slight countersink)
    translate([0,0,L + h_head - socket_depth - socket_entry_chamfer])
        cylinder(h=socket_entry_chamfer + 0.02,
                 d1=(socket_af / sqrt(3))*2 + 2*socket_entry_chamfer,
                 d2=(socket_af / sqrt(3))*2);
}