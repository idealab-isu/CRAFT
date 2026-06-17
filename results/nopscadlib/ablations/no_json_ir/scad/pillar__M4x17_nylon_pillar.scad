$fn = 160;

// ===== Target part =====
// Standoff pillar: 8.0mm OD, 20.0mm long, internal M4x0.7 thread
outer_d = 8.0;
length  = 20.0;

// ===== Thread parameters (M4 coarse) =====
thread_major_d = 4.0;   // internal thread major diameter
thread_pitch   = 0.7;

// Practical internal thread minor diameter (tap drill ~3.3mm)
thread_minor_d = 3.3;

// Extra length for clean through-cut
cut_extra = 0.6;

// ===== Internal thread cutter (subtract from body) =====
// Uses a helical "V" ridge swept along Z; subtracting it forms internal threads.
module internal_thread_cutter(major_d, minor_d, pitch, len) {
    turns = len / pitch;
    depth = (major_d - minor_d) / 2;

    // ISO-ish 60° V profile (approx) sized by depth
    // Place the profile at the major radius so it cuts from major down toward minor.
    linear_extrude(
        height = len,
        twist = -360 * turns,
        slices = max(ceil(turns * 80), 200),
        convexity = 20
    )
    translate([major_d/2 - depth, 0, 0])
        polygon(points=[
            [0,          -pitch*0.30],
            [depth,       0],
            [0,           pitch*0.30]
        ]);
}

module threaded_bore_M4(len) {
    union() {
        // Core hole to minor diameter (through)
        cylinder(h = len, d = thread_minor_d, center = true);

        // Helical cutter to create thread flanks up to major diameter
        internal_thread_cutter(thread_major_d, thread_minor_d, thread_pitch, len);
    }
}

module standoff_pillar() {
    difference() {
        // Outer pillar body: 8mm diameter, 20mm long
        cylinder(h = length, d = outer_d, center = true);

        // Through internal thread (centered; length extended to guarantee full cut)
        threaded_bore_M4(length + cut_extra);
    }
}

// Render
standoff_pillar();