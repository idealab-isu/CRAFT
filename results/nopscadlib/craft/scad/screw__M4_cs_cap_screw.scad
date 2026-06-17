// Socket Head Cap Screw (M4 x 10) with optional washer
// One connected solid (washer fused if enabled)

// -------- Parameters --------
thread_diameter = 4.0;          // mm (major diameter)
length = 10.0;                  // mm (under-head length)
head_diameter = 8.0;            // mm
head_height = 4.0;              // mm

hex_socket_af = 3.0;            // mm across flats (approx M4)
hex_socket_depth = 2.5;         // mm

thread_pitch = 0.7;             // mm (M4 coarse)
thread_ridge_depth = 0.25;      // mm (radial height of thread)
unthreaded_shank_length = 0.0;  // mm (set >0 for partial thread)
tip_chamfer_length = 0.8;       // mm

washer_enabled = 0;             // 0/1 (if 1, washer is fused to head)
washer_outer_diameter = 9.0;    // mm
washer_thickness = 1.0;         // mm
washer_hole_diameter = 4.5;     // mm

overlap = 0.2;                  // mm (small overlap to ensure connectivity)
$fn = 96;

// -------- Helpers --------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module hex_prism(af, h, center=false) {
    // Regular hex with given across-flats
    r = (af/2)/cos(30);
    cylinder(r=r, h=h, center=center, $fn=6);
}

// Simple helical thread approximation using linear_extrude twist.
// This is not a standards-accurate profile, but it is visibly threaded.
module helical_thread(d_major, pitch, length, ridge_depth) {
    r_major = d_major/2;
    r_minor = r_major - ridge_depth;
    turns = length / pitch;
    // 2D profile: a small radial "tooth" that will be twisted into a helix
    // Positioned at the minor radius so it builds up to the major radius.
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
        translate([r_minor, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [ridge_depth, 0],
                [0,  pitch*0.22]
            ]);
}

module screw() {
    // Coordinate system:
    // Head spans z=[0, head_height]
    // Shank spans z=[-length, 0]
    thread_len = clamp(length - unthreaded_shank_length, 0, length);

    difference() {
        union() {
            // Head
            cylinder(d=head_diameter, h=head_height, center=false);

            // Shank core (minor diameter) to support thread
            // Slight overlap into head to guarantee union
            translate([0, 0, -length - overlap])
                cylinder(d=thread_diameter - 2*thread_ridge_depth, h=length + overlap, center=false);

            // Unthreaded portion (major diameter) near head if requested
            if (unthreaded_shank_length > 0) {
                translate([0, 0, -unthreaded_shank_length - overlap])
                    cylinder(d=thread_diameter, h=unthreaded_shank_length + overlap, center=false);
            }

            // Helical thread on remaining length
            if (thread_len > 0) {
                translate([0, 0, -length])
                    helical_thread(thread_diameter, thread_pitch, thread_len, thread_ridge_depth);
            }

            // Tip chamfer (slight taper at end)
            translate([0, 0, -length])
                cylinder(d1=thread_diameter - 2*thread_ridge_depth, d2=max(thread_diameter - 2*thread_ridge_depth - 2*thread_ridge_depth, 0.5),
                         h=tip_chamfer_length, center=false);
        }

        // Hex socket recess (subtracted from head)
        translate([0, 0, head_height - hex_socket_depth])
            hex_prism(hex_socket_af, hex_socket_depth + overlap, center=false);
    }
}

module washer_fused() {
    // Washer fused to top of head (still one connected solid)
    // Placed so it overlaps slightly into head.
    translate([0, 0, head_height - overlap])
        difference() {
            cylinder(d=washer_outer_diameter, h=washer_thickness + overlap, center=false);
            translate([0, 0, -overlap])
                cylinder(d=washer_hole_diameter, h=washer_thickness + 3*overlap, center=false);
        }
}

// -------- Assembly (single connected solid) --------
union() {
    screw();
    if (washer_enabled) washer_fused();
}