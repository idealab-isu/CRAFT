// Socket head cap screw (single connected solid)
// Specs: shank Ø2.5mm, head Ø4.5mm, head height 2.5mm, length under head 10mm

shank_diameter_mm      = 2.5;
length_under_head_mm   = 10;
head_diameter_mm       = 4.5;
head_height_mm         = 2.5;

// Hex socket (typical for M2.5 is ~2.0mm AF; keep as given)
hex_socket_af_mm       = 2.0;
hex_socket_depth_mm    = 1.5;

// Small overlap to ensure watertight boolean operations
overlap_mm             = 0.05;

$fn = 64;

module socket_head_cap_screw() {
    shank_r = shank_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Convert across-flats (AF) to circumscribed radius for a hex polygon
    hex_r = (hex_socket_af_mm/2) / cos(30);

    difference() {
        union() {
            // Shank: from z = -length_under_head to z = 0 (under head)
            translate([0, 0, -length_under_head_mm/2])
                cylinder(r=shank_r, h=length_under_head_mm, center=true);

            // Head: from z = 0 to z = head_height
            translate([0, 0, head_height_mm/2])
                cylinder(r=head_r, h=head_height_mm, center=true);
        }

        // Hex socket recess: cut from top face downward
        // Top face at z = head_height_mm
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2 + overlap_mm/2])
            cylinder(r=hex_r, h=hex_socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
}

socket_head_cap_screw();