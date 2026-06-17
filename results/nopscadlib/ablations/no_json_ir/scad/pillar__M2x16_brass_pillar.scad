$fn = 120;

// =====================
// Target dimensions (mm)
// =====================
outer_diameter = 3.17;   // standoff body OD
length         = 16.0;   // overall length

// =====================
// Thread spec (approx. M2 external)
// =====================
thread_major_d = 2.0;    // major diameter
thread_pitch   = 0.4;    // pitch
thread_depth   = 0.22;   // radial depth (visual/printable)
thread_flat    = 0.12;   // flat at crest/root (mm)

// =====================
// Standoff layout
// =====================
// Make it a standoff pillar: smooth body with short threaded ends.
thread_end_len = 4.0;    // thread length on each end (mm)
mid_body_len   = length - 2*thread_end_len;

eps = 0.02;

// Derived radii
outer_r      = outer_diameter/2;
thread_r_maj = thread_major_d/2;
thread_r_min = thread_r_maj - thread_depth;

// Clamp to keep thread within the 3.17mm OD envelope
thread_r_maj_clamped = min(thread_r_maj, outer_r - eps);
thread_r_min_clamped = min(thread_r_min, thread_r_maj_clamped - eps);

// External helical thread (single-start) built by twisting a 2D profile along Z
module external_thread(major_r, pitch, len, minor_r, flat=0.12) {
    // 2D profile in (radius, z) plane; swept around Z with twist
    profile = [
        [minor_r, 0],
        [major_r, flat],
        [major_r, pitch - flat],
        [minor_r, pitch]
    ];

    linear_extrude(
        height = len,
        twist  = 360*len/pitch,
        slices = max(12, ceil(len*30)),
        convexity = 10
    )
        polygon(points=profile);
}

// Standoff pillar: smooth body + threaded ends, one connected solid
module standoff_pillar() {
    union() {
        // Main smooth standoff body (full OD)
        cylinder(h=length, r=outer_r, center=true);

        // Add external thread on bottom end (overlaps into body for connectivity)
        translate([0, 0, -length/2 - eps])
            external_thread(
                major_r = thread_r_maj_clamped,
                pitch   = thread_pitch,
                len     = thread_end_len + 2*eps,
                minor_r = thread_r_min_clamped,
                flat    = thread_flat
            );

        // Add external thread on top end (overlaps into body for connectivity)
        translate([0, 0, length/2 - thread_end_len - eps])
            external_thread(
                major_r = thread_r_maj_clamped,
                pitch   = thread_pitch,
                len     = thread_end_len + 2*eps,
                minor_r = thread_r_min_clamped,
                flat    = thread_flat
            );
    }
}

// Ensure OD is exactly 3.17mm everywhere
intersection() {
    standoff_pillar();
    cylinder(h=length + 2*eps, d=outer_diameter, center=true);
}