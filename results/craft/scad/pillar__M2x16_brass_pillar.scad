// Standoff pillar: M2 internal thread, 16.0mm long, 3.17mm OD
// One connected solid (outer body minus internal helical thread cut)

thread_diameter_mm = 2.0;      // nominal major diameter (M2)
length_mm          = 16.0;
outer_diameter_mm  = 3.17;

// Thread geometry (approx ISO M2x0.4)
thread_pitch_mm = 0.4;
thread_depth_mm = 0.22;        // radial depth of thread cut (approx)
thread_starts   = 1;

// Printing/fit
core_clearance_mm     = 0.15;  // enlarge internal thread slightly
core_extra_length_mm  = 1.0;   // ensures clean through-cut

// Quality
$fn = 128;

// Small overlap to avoid coincident faces
eps = 0.02;

module internal_thread_cut(len, major_d, pitch, depth, clearance=0, starts=1) {
    major_r = (major_d + clearance)/2;
    minor_r = max(0.01, major_r - depth);

    turns = len / pitch;
    twist_deg = 360 * turns;

    // Build a true "thread void": a minor bore plus a helical ridge that reaches to major_r.
    // Subtracting this from the outer body leaves visible internal threading.
    union() {
        // Minor bore through
        cylinder(r=minor_r, h=len + 2*eps, center=true);

        // Helical ridge(s) that form the thread flanks
        for (s = [0:starts-1]) {
            rotate([0, 0, s*360/starts])
                linear_extrude(
                    height = len + 2*eps,
                    center = true,
                    twist  = twist_deg,
                    slices = max(ceil(turns*80), 160),
                    convexity = 10
                )
                    // 2D profile: a small triangular "tooth" located at the major radius.
                    // This creates a helical groove when subtracted.
                    translate([minor_r - eps, 0, 0])
                        polygon(points=[
                            [0, -pitch*0.30],
                            [major_r - minor_r + 2*eps, 0],
                            [0,  pitch*0.30]
                        ]);
        }
    }
}

module standoff() {
    difference() {
        // Outer body (exact OD and length), aligned along Z
        cylinder(r=outer_diameter_mm/2, h=length_mm, center=true);

        // Internal threaded bore (through), centered and slightly longer for clean cut
        internal_thread_cut(
            len       = length_mm + core_extra_length_mm,
            major_d   = thread_diameter_mm,
            pitch     = thread_pitch_mm,
            depth     = thread_depth_mm,
            clearance = core_clearance_mm,
            starts    = thread_starts
        );
    }
}

standoff();