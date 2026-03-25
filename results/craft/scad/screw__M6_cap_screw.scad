// Socket head cap screw (single connected solid)
// Requested: 6.0mm shank dia, 10.0mm head dia, 6.0mm head height, 10.0mm length under head

shaft_diameter_mm     = 6.0;   // shank diameter
length_under_head_mm  = 10.0;  // length under head
head_diameter_mm      = 10.0;  // head diameter
head_height_mm        = 6.0;   // head height

// Hex socket (typical for M6 SHCS is 5mm AF; keep parametric)
socket_af_mm          = 5.0;   // across flats
socket_depth_mm       = 4.0;   // socket depth
clearance_mm          = 0.10;  // small clearance for visible cut
overlap_mm            = 0.20;  // overlap to ensure robust boolean

$fn = 96;

// Convert hex across-flats to circumradius (distance center->vertex)
function hex_circumradius(af) = af / sqrt(3);

module socket_head_cap_screw() {
    head_r  = head_diameter_mm/2;
    shank_r = shaft_diameter_mm/2;

    // Place underside of head at z=0, head extends +Z, shank extends -Z
    difference() {
        union() {
            // Head
            translate([0, 0, head_height_mm/2])
                cylinder(h=head_height_mm, r=head_r, center=true);

            // Shank (connected to head with slight overlap)
            translate([0, 0, -length_under_head_mm/2 + overlap_mm/2])
                cylinder(h=length_under_head_mm + overlap_mm, r=shank_r, center=true);
        }

        // Hex socket cut from top face downward
        socket_r = hex_circumradius(socket_af_mm + clearance_mm);
        translate([0, 0, head_height_mm - socket_depth_mm/2])
            cylinder(h=socket_depth_mm + overlap_mm, r=socket_r, center=true, $fn=6);
    }
}

socket_head_cap_screw();