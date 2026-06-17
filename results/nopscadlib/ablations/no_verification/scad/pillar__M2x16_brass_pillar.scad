// Standoff pillar with external M2.0-style thread
// Target: 2.0mm thread (major diameter), 16.0mm long, 3.17mm body diameter

$fn = 160;

// Parameters
thread_major_d_mm   = 2.0;   // M2 major diameter
thread_pitch_mm     = 0.4;   // coarse-ish visual pitch
length_mm           = 16.0;
body_d_mm           = 3.17;

threaded_length_mm  = 16.0;  // external thread length along the pillar
thread_depth_mm     = 0.20;  // radial height of thread above major diameter
thread_ridge_w_mm   = 0.35;  // ridge width (approx)
overlap_mm          = 0.25;  // small overlap to ensure watertight union

module external_thread(major_d, pitch, len, depth, ridge_w) {
    major_r = major_d/2;
    turns   = len / pitch;

    // Helical ridge: twist a small rectangle around Z at radius = major_r
    // Centered on Z=0 so it can be placed with a single translate.
    linear_extrude(
        height     = len + overlap_mm,
        twist      = 360 * turns,
        slices     = max(ceil(turns * 60), 120),
        convexity  = 10,
        center     = true
    )
        translate([major_r, 0, 0])
            square([depth, ridge_w], center = true);
}

module standoff_pillar() {
    tlen = min(threaded_length_mm, length_mm);

    union() {
        // Main body: exact required outer diameter and length
        cylinder(h = length_mm, d = body_d_mm, center = true);

        // External M2 thread ridge, centered and connected (overlaps body)
        if (tlen > 0)
            external_thread(
                major_d = thread_major_d_mm,
                pitch   = thread_pitch_mm,
                len     = tlen,
                depth   = thread_depth_mm,
                ridge_w = thread_ridge_w_mm
            );
    }
}

standoff_pillar();