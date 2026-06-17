// Socket Head Cap Screw (M6x10) - single connected solid
// Requested: shaft Ø6.0, head Ø10.0, head height 6.0, length under head 10.0

$fn = 96;

// Parameters (mm)
shaft_diameter_mm      = 6.0;
length_under_head_mm   = 10.0;

head_diameter_mm       = 10.0;
head_height_mm         = 6.0;

// Typical M6 socket (can be adjusted)
socket_hex_af_mm       = 5.0;   // across flats
socket_depth_mm        = 4.0;

// Small edge breaks
top_edge_chamfer_mm    = 0.4;
under_head_chamfer_mm  = 0.6;
tip_chamfer_mm         = 0.8;

// Robust overlap for boolean ops
eps = 0.02;

// Helpers
function hex_circumradius_from_af(af) = (af/2)/cos(30);

module hex_prism(h, af, center=false) {
    cylinder(h=h, r=hex_circumradius_from_af(af), $fn=6, center=center);
}

module socket_head_cap_screw() {
    r_shaft = shaft_diameter_mm/2;
    r_head  = head_diameter_mm/2;

    // Coordinate system:
    // z=0 at underside of head (bearing surface)
    // head extends to +head_height_mm
    // shank extends to -length_under_head_mm
    difference() {
        union() {
            // Head (with slight top chamfer)
            // Main head body
            translate([0,0, head_height_mm/2])
                cylinder(h=head_height_mm - top_edge_chamfer_mm, r=r_head, center=true);

            // Top chamfer ring
            translate([0,0, head_height_mm - top_edge_chamfer_mm/2])
                cylinder(h=top_edge_chamfer_mm, r1=r_head, r2=max(r_head - top_edge_chamfer_mm, 0.01), center=true);

            // Under-head chamfer (connects head to shank)
            translate([0,0, under_head_chamfer_mm/2])
                cylinder(h=under_head_chamfer_mm, r1=r_shaft, r2=r_head, center=true);

            // Shank (length under head)
            translate([0,0, -length_under_head_mm/2])
                cylinder(h=length_under_head_mm, r=r_shaft, center=true);

            // Tip chamfer
            translate([0,0, -length_under_head_mm + tip_chamfer_mm/2])
                cylinder(h=tip_chamfer_mm, r1=max(r_shaft - tip_chamfer_mm, 0.01), r2=r_shaft, center=true);
        }

        // Hex socket recess (cut from top)
        // Place so its top is flush with head top surface.
        translate([0,0, head_height_mm - socket_depth_mm/2 + eps])
            hex_prism(h=socket_depth_mm + 2*eps, af=socket_hex_af_mm, center=true);
    }
}

socket_head_cap_screw();