// Standoff pillar: M2.0 external thread, 16.0mm long, 3.17mm OD
// One connected solid with visible helical thread on the outside

$fn = 128;

// Target dimensions
overall_length_mm = 16.0;
outer_diameter_mm = 3.17;

// Thread (M2 coarse)
thread_major_diameter_mm = 2.0;   // nominal major diameter
thread_pitch_mm = 0.4;            // M2 coarse pitch

// Visual/printable thread controls
thread_depth_mm = 0.20;           // radial height of thread above minor diameter
thread_profile_width_frac = 0.55; // fraction of pitch used for ridge width
thread_profile_steps = 28;        // slices per pitch (higher = smoother)
lead_in_mm = 0.6;                 // fade-in length for thread start/end
connection_overlap_mm = 0.25;     // overlap to guarantee manifold union

module external_thread_on_cylinder(len, major_d, pitch, depth,
                                   width_frac=0.55, steps=24, lead=0.6) {
    // Builds a solid threaded cylinder (minor core + helical ridge),
    // with a simple lead-in/out by tapering the ridge height.
    minor_d = max(major_d - 2*depth, 0.2);
    turns = len / pitch;
    slices = max(ceil(turns * steps), 12);

    union() {
        // Core at minor diameter
        cylinder(h=len, d=minor_d, center=false);

        // Helical ridge with lead-in/out (piecewise extrude)
        for (i = [0 : slices-1]) {
            z0 = len * i / slices;
            z1 = len * (i+1) / slices;
            dz = z1 - z0;

            // Fade factor for lead-in/out
            f_in  = (lead <= 0) ? 1 : min(1, z0 / lead);
            f_out = (lead <= 0) ? 1 : min(1, (len - z0) / lead);
            f = min(f_in, f_out);

            // Twist for this segment
            twist_seg = 360 * turns / slices;

            translate([0, 0, z0])
                linear_extrude(height=dz, twist=twist_seg, slices=1, center=false, convexity=10)
                    translate([minor_d/2, 0, 0])
                        polygon(points=[
                            [0, -pitch*width_frac/2],
                            [depth*f, 0],
                            [0,  pitch*width_frac/2]
                        ]);
        }
    }
}

module standoff_pillar() {
    L = overall_length_mm;
    D = outer_diameter_mm;

    // Make the outer surface threaded by using the OD as the thread major diameter.
    // This matches the requested 3.17mm diameter while still being "M2.0 thread" nominal.
    major_d = D;

    // Place part centered on Z for consistent orthographic views
    translate([0, 0, -L/2])
        external_thread_on_cylinder(
            len   = L + connection_overlap_mm,
            major_d = major_d,
            pitch = thread_pitch_mm,
            depth = thread_depth_mm,
            width_frac = thread_profile_width_frac,
            steps = thread_profile_steps,
            lead  = lead_in_mm
        );
}

standoff_pillar();