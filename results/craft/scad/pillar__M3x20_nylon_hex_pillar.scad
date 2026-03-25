// Standoff pillar: M3 external thread both ends, 20mm overall length.
// "Nonemm diameter" is ambiguous; keep body diameter parametric (default 9mm).

// -------- Parameters --------
thread_diameter_mm = 3.0;          // M3 major diameter (visual)
length_mm = 20.0;                  // overall length

outer_diameter_mm = 9.0;           // "None mm" ambiguous -> parametric default 9mm
mid_body_length_mm = 8.0;          // unthreaded center section length

// Visual thread settings (not a true ISO thread; helical ridge)
thread_pitch_mm = 0.5;             // typical M3 pitch
thread_depth_mm = 0.25;            // ridge height
thread_fn = 96;                    // smoothness for thread

interface_overlap_mm = 0.6;        // ensures one connected solid

$fn = 96;

// -------- Helpers --------
module external_thread(d_major, pitch, depth, h, center=true) {
    r_core = d_major/2 - depth;
    turns = h / pitch;

    union() {
        cylinder(r=r_core, h=h, center=center, $fn=thread_fn);

        linear_extrude(
            height=h,
            twist=turns*360,
            center=center,
            convexity=10,
            slices=max(ceil(turns*28), 28)
        )
            translate([r_core, 0, 0])
                square([depth, pitch*0.55], center=true);
    }
}

// -------- Model --------
module standoff_pillar() {
    // Ensure the center section is valid and threads fit within overall length
    mid_h = min(max(mid_body_length_mm, 0), length_mm);
    thread_h_each = (length_mm - mid_h) / 2;

    // Clamp to non-negative
    th = max(thread_h_each, 0);

    // Z positions derived from dimensions (no arbitrary numbers)
    z_top =  (mid_h/2 + th/2) - interface_overlap_mm/2;
    z_bot = -(mid_h/2 + th/2) + interface_overlap_mm/2;

    union() {
        // Center body
        cylinder(r=outer_diameter_mm/2, h=mid_h, center=true);

        // Top external thread (overlaps into body to guarantee connectivity)
        if (th > 0)
            translate([0, 0, z_top])
                external_thread(
                    thread_diameter_mm,
                    thread_pitch_mm,
                    thread_depth_mm,
                    th + interface_overlap_mm,
                    center=true
                );

        // Bottom external thread (overlaps into body to guarantee connectivity)
        if (th > 0)
            translate([0, 0, z_bot])
                external_thread(
                    thread_diameter_mm,
                    thread_pitch_mm,
                    thread_depth_mm,
                    th + interface_overlap_mm,
                    center=true
                );
    }
}

standoff_pillar();