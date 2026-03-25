// Socket head cap screw (M3 x 10) with hex recess
// Requested: 3.0mm shank diameter, 5.5mm head diameter, 2.0mm head height, 10mm long

thread_diameter_mm   = 3.0;
length_mm            = 10.0;   // under-head length
head_diameter_mm     = 5.5;
head_height_mm       = 2.0;

// Typical M3 socket: 2.5mm across flats, ~1.5mm deep (as provided)
hex_socket_af_mm     = 2.5;
hex_socket_depth_mm  = 1.5;

$fn = 96;

module socket_head_cap_screw() {
    head_r = head_diameter_mm/2;
    shank_r = thread_diameter_mm/2;

    // Place underside of head at z=0, head on +Z, shank on -Z
    difference() {
        union() {
            // Head
            translate([0, 0, head_height_mm/2])
                cylinder(r=head_r, h=head_height_mm, center=true);

            // Shank (under-head length)
            translate([0, 0, -length_mm/2])
                cylinder(r=shank_r, h=length_mm, center=true);
        }

        // Hex socket recess cut from top of head
        // Hex cylinder radius for given across-flats: R = AF / (2*cos(30))
        hex_R = hex_socket_af_mm / (2*cos(30));
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2])
            cylinder(r=hex_R, h=hex_socket_depth_mm, center=true, $fn=6);
    }
}

socket_head_cap_screw();