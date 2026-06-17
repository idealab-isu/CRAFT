// Socket head cap screw (M3-ish) — single connected solid
// Requested: 3.0mm shank dia, 5.5mm head dia, 2.0mm head height, 10mm long

$fn = 96;

// Parameters
thread_diameter_mm   = 3.0;
length_mm            = 10.0;   // under-head length
head_diameter_mm     = 5.5;
head_height_mm       = 2.0;

// Hex socket (approx for M3 SHCS; adjustable)
hex_socket_af_mm     = 2.5;    // across flats
hex_socket_depth_mm  = 1.5;

// Small overlap to ensure watertight unions
overlap_mm = 0.05;

// Derived
shank_r = thread_diameter_mm/2;
head_r  = head_diameter_mm/2;

// Convert hex across-flats to circumscribed radius for a 6-sided polygon
hex_r = hex_socket_af_mm / (2*cos(30));

module socket_head_cap_screw() {
    // Z=0 at top of head; screw extends in -Z
    difference() {
        union() {
            // Head: from z=-head_height to z=0
            translate([0,0,-head_height_mm/2])
                cylinder(r=head_r, h=head_height_mm, center=true);

            // Shank: from z=-(head_height+length) to z=-head_height
            translate([0,0,-head_height_mm - length_mm/2 + overlap_mm/2])
                cylinder(r=shank_r, h=length_mm + overlap_mm, center=true);
        }

        // Hex socket recess in head (open at top), depth into head
        translate([0,0,-hex_socket_depth_mm/2 + overlap_mm/2])
            cylinder(r=hex_r, h=hex_socket_depth_mm + overlap_mm, center=true, $fn=6);
    }
}

socket_head_cap_screw();