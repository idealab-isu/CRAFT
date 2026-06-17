// Socket Head Cap Screw (M2-ish) — 2.0mm shank dia, 3.8mm head dia, 10mm long
// One connected solid, cylindrical head with internal hex socket, visible simplified threads.

$fn = 96;

// --- Requested dimensions ---
shaft_diameter_mm = 2.0;
length_mm         = 10.0;   // under-head length
head_diameter_mm  = 3.8;
head_height_mm    = 2.0;

// Socket (internal hex)
socket_hex_af_mm  = 1.5;    // across flats
socket_depth_mm   = 1.2;

// Threads (visual approximation)
thread_pitch_mm   = 0.4;
thread_length_mm  = 8.0;    // threaded portion length from tip upward
thread_major_diameter_mm = 2.0;  // major = shank dia for M2
thread_minor_diameter_mm = 1.6;  // visual minor dia

// Small overlaps to ensure watertight unions/differences
overlap_mm = 0.05;

// --- Helpers ---
function hex_radius_from_af(af) = af / (2*cos(30)); // circumradius for 6-sided polygon

module hex_prism(af, h, center=false) {
    cylinder(h=h, r=hex_radius_from_af(af), $fn=6, center=center);
}

// Simplified external thread: helical triangular ridge around a minor-diameter core
module simplified_thread(major_d, minor_d, pitch, len) {
    turns = len / pitch;
    ridge_h = (major_d - minor_d) / 2;

    union() {
        // Core
        cylinder(h=len, r=minor_d/2, center=false);

        // Helical ridge (triangular section)
        linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*24), 60), center=false)
            translate([minor_d/2, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [ridge_h, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module socket_head_cap_screw() {
    // Coordinate system: z=0 at underside of head; shank extends to -length_mm; head extends to +head_height_mm
    difference() {
        union() {
            // Head (cylindrical)
            translate([0,0,0])
                cylinder(h=head_height_mm, r=head_diameter_mm/2, center=false);

            // Unthreaded shank portion (if any)
            unthreaded_len = max(length_mm - thread_length_mm, 0);
            if (unthreaded_len > 0)
                translate([0,0,-unthreaded_len])
                    cylinder(h=unthreaded_len + overlap_mm, r=shaft_diameter_mm/2, center=false);

            // Threaded portion at the tip (connected to shank)
            translate([0,0,-length_mm])
                simplified_thread(thread_major_diameter_mm, thread_minor_diameter_mm, thread_pitch_mm, thread_length_mm + overlap_mm);
        }

        // Internal hex socket cut into head from top
        translate([0,0,head_height_mm - socket_depth_mm])
            hex_prism(socket_hex_af_mm, socket_depth_mm + overlap_mm, center=false);
    }
}

socket_head_cap_screw();