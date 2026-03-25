$fn = 128;

// Target dimensions (mm)
shaft_diameter_mm      = 8.0;   // major diameter
length_under_head_mm   = 10.0;  // shank length (under head)
head_diameter_mm       = 13.0;
head_height_mm         = 8.0;

// Socket (approx for M8 SHCS)
socket_hex_af_mm       = 6.0;   // across flats
socket_depth_mm        = 5.0;

// Thread visual (simple helical ridge, not ISO-accurate)
thread_pitch_mm        = 1.25;
thread_depth_mm        = 0.45;  // radial height of ridge

// Small overlap to ensure watertight unions/differences
overlap_mm             = 0.25;

function hex_R_from_AF(af) = af / (2 * cos(30)); // circumradius for a hex with given AF

module hex_socket_cutter(af, depth) {
    // Hex prism used as a cutter (recessed socket)
    cylinder(h = depth, r = hex_R_from_AF(af), $fn = 6, center = false);
}

module thread_ridge(major_d, pitch, length, depth) {
    // Helical ridge to suggest threads; built as a connected solid
    turns = length / pitch;
    rotate_extrude(angle = 360 * turns, convexity = 10)
        translate([major_d/2 - depth/2, 0, 0])
            circle(d = depth, $fn = 24);
}

module screw() {
    head_r  = head_diameter_mm/2;
    shank_r = shaft_diameter_mm/2;

    // Coordinate convention:
    // Under-head plane at z=0
    // Head spans z=[0, head_height]
    // Shank spans z=[-length_under_head, 0]
    difference() {
        union() {
            // Head (connected to shank at z=0)
            translate([0, 0, head_height_mm/2])
                cylinder(r = head_r, h = head_height_mm, center = true);

            // Shank core (minor diameter) for thread ridge to sit on
            minor_d = shaft_diameter_mm - 2*thread_depth_mm;
            translate([0, 0, -length_under_head_mm/2])
                cylinder(d = minor_d, h = length_under_head_mm + overlap_mm, center = true);

            // Thread ridge along full shank length, starting at z=-length and ending at z=0
            // rotate_extrude builds along +Z, so place base at z=-length
            translate([0, 0, -length_under_head_mm])
                thread_ridge(shaft_diameter_mm, thread_pitch_mm, length_under_head_mm, thread_depth_mm);
        }

        // Recessed hex socket cut from the top face downwards
        translate([0, 0, head_height_mm - socket_depth_mm])
            hex_socket_cutter(socket_hex_af_mm, socket_depth_mm + overlap_mm);
    }
}

screw();