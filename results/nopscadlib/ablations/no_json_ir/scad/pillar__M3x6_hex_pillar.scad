// Standoff pillar with internal M3 (3.0mm nominal) thread geometry,
// 6.0mm long. Outer diameter is unspecified in the request ("Nonemm"),
// so it is parameterized and defaults to 6.0mm.
// One connected solid.

$fn = 128;

// Parameters
outer_diameter   = 6.0;   // mm (OD not provided; set as needed)
length           = 6.0;   // mm

// M3 coarse thread (approx.)
thread_major_d   = 3.0;   // mm (nominal major diameter)
thread_pitch     = 0.5;   // mm (M3 coarse pitch)
thread_depth     = 0.27;  // mm (approx. radial depth for printable internal thread)
thread_clearance = 0.10;  // mm (extra clearance for fit/printing)

// Small overlap to avoid coincident faces
eps = 0.05;

// Internal thread cutter (helical triangular profile)
module internal_thread_cutter(major_d, pitch, depth, h, clearance=0) {
    minor_d = major_d - 2*depth;

    // Ensure sane geometry
    minor_d2 = max(0.2, minor_d - 2*clearance);
    major_d2 = max(minor_d2 + 0.2, major_d + 2*clearance);

    turns = (h + 2*eps) / pitch;

    // 2D profile in X-Y, then twisted along Z
    // Profile is a triangle spanning from minor radius to major radius.
    linear_extrude(height = h + 2*eps, twist = -360*turns, slices = max(24, ceil(turns*48)), center = true)
        polygon(points=[
            [minor_d2/2, -pitch*0.30],
            [major_d2/2,  0],
            [minor_d2/2,  pitch*0.30]
        ]);
}

module standoff_pillar(od, h) {
    difference() {
        // Outer body
        cylinder(h = h, d = od, center = true);

        // Internal helical thread cut
        internal_thread_cutter(
            major_d   = thread_major_d,
            pitch     = thread_pitch,
            depth     = thread_depth,
            h         = h,
            clearance = thread_clearance
        );

        // Relief bore to guarantee through-hole and avoid end artifacts
        // (kept slightly under major diameter so thread remains visible)
        cylinder(h = h + 4*eps, d = thread_major_d - 2*thread_depth + 2*thread_clearance, center = true);
    }
}

standoff_pillar(outer_diameter, length);