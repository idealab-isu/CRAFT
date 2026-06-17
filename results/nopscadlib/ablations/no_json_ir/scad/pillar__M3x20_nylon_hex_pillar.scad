// Standoff pillar: M3 (3.0mm) external thread, 20.0mm long, 9.0mm body diameter.
// One connected solid with visible helical thread geometry.

$fn = 128;

// Parameters
pillar_length   = 20.0;   // overall length
pillar_diameter = 9.0;    // body diameter (interpreting "Nonemm" as 9.0mm)
thread_major_d  = 3.0;    // M3 major diameter
thread_pitch    = 0.5;    // M3 coarse pitch
thread_length   = 20.0;   // threaded full length

// Thread geometry tuning (visual + printable)
thread_depth     = 0.35;  // radial depth of thread ridge
thread_profile_w = 0.60;  // tangential width of ridge (bigger => more visible)
overlap          = 0.25;  // overlap to ensure manifold union

module external_thread_ridge(major_d, pitch, len, depth, prof_w) {
    turns  = len / pitch;
    base_d = major_d - 2*depth;

    union() {
        // Core cylinder up to minor diameter
        cylinder(h=len, d=base_d, center=false);

        // Helical ridge reaching major diameter
        linear_extrude(
            height=len,
            twist=turns*360,
            slices=max(ceil(turns*80), 200),
            center=false,
            convexity=10
        )
            translate([base_d/2 - overlap, -prof_w/2, 0])
                square([depth + 2*overlap, prof_w], center=false);
    }
}

module standoff() {
    union() {
        // Main body
        cylinder(h=pillar_length, d=pillar_diameter, center=false);

        // Threaded stud on-axis, connected by overlap (no floating)
        translate([0, 0, -overlap])
            external_thread_ridge(
                thread_major_d,
                thread_pitch,
                thread_length + 2*overlap,
                thread_depth,
                thread_profile_w
            );
    }
}

standoff();