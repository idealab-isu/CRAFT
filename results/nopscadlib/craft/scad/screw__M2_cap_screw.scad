// Socket head cap screw (M2-ish) per request:
// shank Ø2.0 mm, head Ø3.8 mm, head height 2.0 mm, overall length 10 mm

$fn = 96;

// --- Parameters (mm) ---
shaft_diameter_mm = 2.0;
overall_length_mm = 10.0;     // under-head length
head_diameter_mm  = 3.8;
head_height_mm    = 2.0;

// Hex socket (approx for M2)
socket_hex_af_mm  = 1.5;      // across flats
socket_depth_mm   = 1.2;

// Simple cosmetic thread (helical ridge) parameters
thread_length_mm  = overall_length_mm; // thread along full shank
thread_pitch_mm   = 0.4;
thread_ridge_h_mm = 0.12;     // radial height of ridge
thread_ridge_w_mm = 0.22;     // tangential width of ridge

// Small overlaps to ensure one connected solid
overlap_mm = 0.05;

// --- Helpers ---
function hex_circumradius_from_af(af) = (af/2) / cos(30); // r for $fn=6 cylinder

module hex_socket_cut(af, depth) {
    // Cut from top face downward
    translate([0,0, head_height_mm - depth/2 + overlap_mm/2])
        cylinder(h=depth + overlap_mm, r=hex_circumradius_from_af(af), $fn=6, center=true);
}

module threaded_shank(d, len, pitch, ridge_h, ridge_w) {
    // Base cylinder + helical ridge (cosmetic, not standards-accurate)
    union() {
        cylinder(h=len, r=d/2, center=false);

        // Helical ridge: extrude a small rectangle around the cylinder
        // Place rectangle at radius (d/2 - ridge_h) so it protrudes to ~d/2 + small amount
        linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(len*12), 60), center=false)
            translate([d/2 - ridge_h, 0, 0])
                square([ridge_h*2, ridge_w], center=true);
    }
}

module socket_head_cap_screw() {
    // Coordinate system:
    // z=0 at underside of head; head extends to +head_height_mm; shank extends to -overall_length_mm
    difference() {
        union() {
            // Head
            translate([0,0,0])
                cylinder(h=head_height_mm, r=head_diameter_mm/2, center=false);

            // Shank + threads (connected to head with slight overlap)
            translate([0,0,-overall_length_mm + overlap_mm])
                threaded_shank(shaft_diameter_mm, overall_length_mm + overlap_mm, thread_pitch_mm, thread_ridge_h_mm, thread_ridge_w_mm);
        }

        // Hex socket
        hex_socket_cut(socket_hex_af_mm, socket_depth_mm);
    }
}

socket_head_cap_screw();