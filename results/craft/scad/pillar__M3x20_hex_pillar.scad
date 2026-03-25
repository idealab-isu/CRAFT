// Standoff pillar with external M3 threads on both ends
// Target: 3.0mm thread, 20.0mm long, diameter unspecified -> keep parametric

// Parameters
thread_diameter_mm = 3.0;          // M3 major diameter
length_mm = 20.0;                  // overall length
outer_diameter_mm = 6.0;           // pillar body diameter (parametric)
top_thread_length_mm = 6.0;
bottom_thread_length_mm = 6.0;

// Thread geometry (approx ISO metric external thread)
thread_pitch_mm = 0.5;             // M3 coarse pitch
thread_depth_mm = 0.30;            // radial height of thread (visual/printable approximation)

$fn = 128;

// Helical external thread (approx) using linear_extrude(twist)
// Built as a swept "tooth" that reaches the major diameter so it is visible.
module external_thread(d_major, pitch, len, depth) {
    turns = len / pitch;
    twist_deg = 360 * turns;

    // Place the tooth so its OUTER edge reaches d_major/2
    // (center of square at radius = d_major/2 - depth/2)
    linear_extrude(height=len, twist=twist_deg, slices=max(ceil(turns*60), 120), convexity=10)
        translate([d_major/2 - depth/2, 0, 0])
            square([depth, pitch*0.60], center=true);
}

module standoff() {
    eps = 0.25; // overlap to guarantee connectivity

    // Ensure the body is at least as large as the thread major diameter
    body_d = max(outer_diameter_mm, thread_diameter_mm);

    // Core under threads: slightly under major diameter so ridges protrude
    thread_core_d = thread_diameter_mm - 2*thread_depth_mm;

    union() {
        // Main pillar body (centered)
        cylinder(d=body_d, h=length_mm, center=true);

        // Core cylinders for threaded sections (connected with overlap)
        translate([0, 0, length_mm/2 - top_thread_length_mm/2 - eps/2])
            cylinder(d=thread_core_d, h=top_thread_length_mm + eps, center=true);

        translate([0, 0, -length_mm/2 + bottom_thread_length_mm/2 + eps/2])
            cylinder(d=thread_core_d, h=bottom_thread_length_mm + eps, center=true);

        // Helical thread ridges (top) - start exactly at top end of body
        translate([0, 0, length_mm/2 - top_thread_length_mm - eps])
            external_thread(thread_diameter_mm, thread_pitch_mm, top_thread_length_mm + 2*eps, thread_depth_mm);

        // Helical thread ridges (bottom) - end exactly at bottom end of body
        translate([0, 0, -length_mm/2 - eps])
            external_thread(thread_diameter_mm, thread_pitch_mm, bottom_thread_length_mm + 2*eps, thread_depth_mm);
    }
}

standoff();