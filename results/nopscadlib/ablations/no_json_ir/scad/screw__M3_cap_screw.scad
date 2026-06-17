// Socket head cap screw (M3-ish) — dimensions in mm
thread_diameter = 3.0;     // shank major diameter
overall_length  = 10.0;    // length under head
head_diameter   = 5.5;     // cylindrical head diameter
head_height     = 3.0;     // head height
hex_socket_af   = 2.5;     // hex socket across flats
socket_depth    = 2.2;     // typical depth (kept < head_height)

$fn = 96;

// Hex prism sized by across-flats (AF)
module hex_prism_af(af, h) {
    // For a regular hex: AF = 2 * apothem; circumradius R = AF / sqrt(3)
    cylinder(h = h, r = af / sqrt(3), $fn = 6);
}

module socket_head_cap_screw() {
    eps = 0.02;

    union() {
        // Head with internal hex socket
        difference() {
            // Head sits from z=0 to z=head_height
            cylinder(h = head_height, d = head_diameter);

            // Socket cut from top face downward
            translate([0, 0, head_height - socket_depth])
                hex_prism_af(hex_socket_af, socket_depth + eps);
        }

        // Shank (connected to underside of head at z=0)
        translate([0, 0, -overall_length + eps])  // slight overlap into head for watertight union
            cylinder(h = overall_length, d = thread_diameter);
    }
}

socket_head_cap_screw();