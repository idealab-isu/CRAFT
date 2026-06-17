$fn = 96;

// Socket Head Cap Screw (approx. ISO 4762)
// Parameters (mm)
d_shank = 3.0;
L = 10.0;

d_head = 6.0;
h_head = 3.0;

hex_af = 2.5;          // typical for M3
hex_depth = 1.6;       // typical for M3
hex_corner_r = 0.15;   // slight rounding

// Small edge chamfers
head_top_chamfer = 0.35;
head_bottom_chamfer = 0.25;
shank_tip_chamfer = 0.25;

module hex_prism(af, h) {
    // Regular hex with across-flats = af
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module socket_head_cap_screw() {
    union() {
        // Shank
        translate([0,0,0])
        cylinder(h=L, d=d_shank);

        // Shank tip chamfer
        translate([0,0,0])
        cylinder(h=shank_tip_chamfer, d1=d_shank*0.6, d2=d_shank);

        // Head (with slight bottom chamfer)
        translate([0,0,L])
        cylinder(h=h_head, d=d_head);

        // Bottom chamfer on head
        translate([0,0,L])
        cylinder(h=head_bottom_chamfer, d1=d_head*0.92, d2=d_head);

        // Top chamfer on head
        translate([0,0,L + h_head - head_top_chamfer])
        cylinder(h=head_top_chamfer, d1=d_head, d2=d_head*0.92);
    }
}

module screw_with_socket() {
    difference() {
        socket_head_cap_screw();

        // Hex socket cut
        translate([0,0, L + h_head - hex_depth])
        minkowski() {
            hex_prism(hex_af - 2*hex_corner_r, hex_depth + 0.02);
            sphere(r=hex_corner_r, $fn=24);
        }

        // Slight lead-in at socket opening
        translate([0,0, L + h_head - 0.6])
        cylinder(h=0.6 + 0.02, d1=hex_af*1.15, d2=hex_af*0.98, $fn=48);
    }
}

screw_with_socket();