// Socket Head Cap Screw (M4 x 10) — single connected solid with external threads
// Target: 4.0mm major diameter, 8.0mm head diameter, 10.0mm under-head length

// --- Parameters (fixed to requested dimensions) ---
nominal_diameter_mm = 4.0;     // major thread diameter
length_mm           = 10.0;    // under-head length
head_diameter_mm    = 8.0;
head_height_mm      = 4.0;

socket_hex_af_mm    = 3.0;     // across flats (typical for M4)
socket_depth_mm     = 2.5;

thread_pitch_mm     = 0.7;     // typical M4 coarse
thread_depth_mm     = 0.35;    // radial thread height (visual/approx)
overlap_mm          = 0.15;

// Quality
$fn = 96;

// --- Helpers ---
function hex_r_from_af(af) = af / (2 * cos(30)); // circumradius for $fn=6

// Helical external thread approximation using linear_extrude(twist=...)
module external_thread(major_d, pitch, length, depth, slices_per_turn=24) {
    major_r = major_d/2;
    minor_r = max(0.01, major_r - depth);

    turns = length / pitch;
    slices = max(ceil(turns * slices_per_turn), 12);

    // 2D profile in XY, then twisted along Z
    // Profile: a small "tooth" wedge that reaches major radius and roots at minor radius.
    linear_extrude(height=length, twist=turns*360, slices=slices, convexity=10)
        polygon(points=[
            [minor_r, -pitch*0.22],
            [major_r,  0],
            [minor_r,  pitch*0.22]
        ]);
}

// --- Main screw ---
module socket_head_cap_screw() {
    major_r = nominal_diameter_mm/2;

    // Place under-head plane at z=0, shank goes to negative Z, head to positive Z
    difference() {
        union() {
            // Core shank (minor diameter) to ensure a solid body under the thread
            // Minor radius approximated as major - thread_depth
            minor_r = max(0.01, major_r - thread_depth_mm);
            translate([0,0,-length_mm/2])
                cylinder(h=length_mm, r=minor_r, center=true);

            // External thread (adds material up to major diameter)
            translate([0,0,-length_mm])
                external_thread(nominal_diameter_mm, thread_pitch_mm, length_mm, thread_depth_mm);

            // Socket head, connected to shank with slight overlap
            translate([0,0, head_height_mm/2 - overlap_mm])
                cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);
        }

        // Hex socket cut from top face downward
        translate([0,0, head_height_mm - socket_depth_mm/2])
            cylinder(h=socket_depth_mm + 2*overlap_mm, r=hex_r_from_af(socket_hex_af_mm), center=true, $fn=6);
    }
}

socket_head_cap_screw();