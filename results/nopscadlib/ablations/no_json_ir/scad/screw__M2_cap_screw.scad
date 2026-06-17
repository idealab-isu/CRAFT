// Socket head cap screw (M2-like) with internal hex socket
// Dimensions: shank Ø2.0, head Ø3.8, head height 2.0, overall length 10.0

$fn = 128;

// Parameters (mm)
shank_diameter = 2.0;
overall_length = 10.0;

head_diameter = 3.8;
head_height   = 2.0;

// Hex socket (across flats) and depth (kept within head height)
hex_socket_af    = 1.5;
hex_socket_depth = 1.4;   // <= head_height
socket_top_wall  = 0.3;   // material above socket

// Small overlap to avoid coplanar faces in boolean ops
eps = 0.02;

// Derived
shank_length = overall_length - head_height;

// Hex prism by across-flats
module hex_prism_af(af, h, center=false) {
    // For a regular hexagon: across flats = sqrt(3) * R (circumradius)
    R = af / sqrt(3);
    cylinder(h=h, r=R, $fn=6, center=center);
}

module socket_head_cap_screw() {
    difference() {
        // ONE connected solid: shank + cylindrical head
        union() {
            // Shank
            cylinder(d=shank_diameter, h=shank_length + eps, center=false);

            // Head, connected at z = shank_length (slight overlap via eps)
            translate([0, 0, shank_length - eps])
                cylinder(d=head_diameter, h=head_height + eps, center=false);
        }

        // Internal hex socket cut from the top of the head downward
        // Top of head at z = overall_length
        socket_depth = min(hex_socket_depth, head_height - socket_top_wall);
        socket_z0 = overall_length - socket_top_wall - socket_depth;

        translate([0, 0, socket_z0 - eps])
            hex_prism_af(hex_socket_af, socket_depth + 2*eps, center=false);
    }
}

socket_head_cap_screw();