// Standoff pillar: M3 (3.0mm) external thread, 6.0mm long
// Outer diameter was unspecified ("Nonemm") -> keep as parameter.
thread_diameter_mm = 3.0;   //[1.5:6:0.1]
length_mm          = 6.0;   //[3:12:0.5]
outer_diameter_mm  = 6.0;   //[4:12:0.5]

// Visual thread approximation (not true ISO profile)
thread_pitch_mm    = 0.5;   //[0.3:1.5:0.05]
thread_depth_mm    = 0.25;  //[0.1:0.6:0.05]
overlap_mm         = 0.25;  //[0.05:0.8:0.05]

$fn = 128;

module helical_thread_external(d_major, pitch, depth, len, fn=96) {
    turns = (len <= 0) ? 0 : (len / pitch);
    twist_deg = 360 * turns;

    r_major = d_major/2;
    r_minor = r_major - depth;

    // Core + helical rib, both centered on Z for easy alignment
    union() {
        cylinder(h=len, r=r_minor, center=true, $fn=fn);

        linear_extrude(
            height=len,
            twist=twist_deg,
            slices=max(ceil(turns*40), 40),
            center=true,
            convexity=10
        )
        polygon(points=[
            [r_minor, -pitch*0.22],
            [r_major,  0],
            [r_minor,  pitch*0.22]
        ]);
    }
}

module standoff_pillar() {
    body_r = outer_diameter_mm/2;

    // Ensure thread fits on the body
    effective_thread_d = min(thread_diameter_mm, outer_diameter_mm);
    effective_depth = min(thread_depth_mm, (effective_thread_d/2) * 0.45);

    // One connected solid: body + external thread (thread protrudes beyond body)
    union() {
        // Main body (centered)
        cylinder(h=length_mm, r=body_r, center=true);

        // External thread (centered, same length, overlaps slightly for watertight union)
        helical_thread_external(
            d_major=effective_thread_d,
            pitch=thread_pitch_mm,
            depth=effective_depth,
            len=length_mm + overlap_mm,
            fn=96
        );
    }
}

standoff_pillar();