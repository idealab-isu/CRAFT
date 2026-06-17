// Standoff pillar: M3 external thread, 13mm long, diameter unspecified -> default body diameter
$fn = 128;

// Parameters
thread_diameter_mm = 3.0;          // M3 major diameter
length_mm = 13.0;                  // overall length
outer_diameter_mm = 6.0;           // default pillar OD (set as needed)

// Thread parameters (visible helical external thread approximation)
thread_pitch_mm = 0.5;             // M3 coarse pitch
thread_depth_mm = 0.30;            // radial depth (slightly exaggerated for visibility)
thread_length_mm = length_mm;      // fully threaded
thread_starts = 1;

// Small overlaps to ensure watertight union
overlap_mm = 0.25;

// Helical external thread using linear_extrude(twist) of a triangular profile
module external_thread(d_major, pitch, length, depth, starts=1) {
    turns = length / pitch;
    d_minor = d_major - 2*depth;

    // Triangular ridge profile (approx 60° thread form), swept helically
    // Built around the minor cylinder so the ridge reaches the major diameter.
    union() {
        // Minor diameter core
        cylinder(h=length, r=d_minor/2, center=false);

        // Helical ridge
        for (s = [0:starts-1]) {
            rotate([0, 0, s*360/starts])
                linear_extrude(
                    height=length,
                    twist=turns*360,
                    slices=max(ceil(turns*80), 120),
                    center=false,
                    convexity=10
                )
                translate([d_minor/2, 0, 0])
                    polygon(points=[
                        [0, -pitch*0.45],
                        [depth, 0],
                        [0,  pitch*0.45]
                    ]);
        }
    }
}

// Main standoff pillar (one connected solid)
module standoff_pillar() {
    // Ensure body is at least as large as the thread major diameter
    body_d = max(outer_diameter_mm, thread_diameter_mm);

    union() {
        // Body cylinder (full length)
        cylinder(h=length_mm, r=body_d/2, center=false);

        // External thread (full length), aligned to body with slight overlap
        translate([0, 0, -overlap_mm/2])
            external_thread(
                thread_diameter_mm,
                thread_pitch_mm,
                length_mm + overlap_mm,
                thread_depth_mm,
                thread_starts
            );
    }
}

standoff_pillar();