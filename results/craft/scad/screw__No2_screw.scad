// Pan head screw (single connected solid)
// Target: 2.2mm shank dia, 4.2mm head dia, 1.7mm head height, 10mm overall length

$fn = 128;

// Parameters (mm)
shaft_diameter_mm = 2.2;
length_mm         = 10.0;   // overall length including head
head_diameter_mm  = 4.2;
head_height_mm    = 1.7;

// Thread (visual approximation)
thread_pitch_mm   = 0.55;
thread_depth_mm   = 0.18;   // radial depth
thread_start_mm   = 0.6;    // unthreaded under-head length
thread_end_mm     = 0.2;    // unthreaded at tip

// Tip
tip_length_mm     = 1.0;

// Overlap to guarantee manifold unions (requirement: 1–2mm)
overlap_mm        = 1.2;

// Derived
shank_r    = shaft_diameter_mm/2;
head_r     = head_diameter_mm/2;
shank_len  = length_mm - head_height_mm;                 // length below head (z<=0)
thread_len = max(0, shank_len - thread_start_mm - thread_end_mm);

// Coordinate system: z=0 at underside of head; shank extends to negative z; head extends to positive z.

module pan_head_profile(r_head, h_head) {
    // Simple pan head: flat underside, cylindrical skirt, rounded top
    // Profile is a 2D polygon in (radius, z) for rotate_extrude.
    skirt_h = 0.55 * h_head;                 // cylindrical portion
    dome_h  = h_head - skirt_h;              // rounded portion
    dome_r  = max(0.01, dome_h);             // quarter-circle radius for top rounding

    // Ensure dome doesn't exceed head radius
    dome_r = min(dome_r, r_head * 0.9);

    arc_steps = 24;
    arc_pts = [
        for (i = [0:arc_steps])
            let(a = i * 90/arc_steps)
            [ r_head - dome_r + dome_r * cos(a), skirt_h + dome_r * sin(a) ]
    ];

    pts = concat(
        [[0,0], [r_head,0], [r_head,skirt_h]],
        arc_pts,
        [[0,h_head]]
    );

    rotate_extrude(convexity=10)
        polygon(points=pts);
}

module helical_thread_ridge(minor_r, depth, pitch, len, turns) {
    // Ridge created by twisting a small triangle located at the minor radius.
    // NOTE: This is a visual approximation.
    slices = max(80, ceil(turns * 120));
    linear_extrude(height=len, twist=-360*turns, slices=slices, convexity=10, center=false)
        polygon(points=[
            [minor_r,                 -pitch*0.18],
            [minor_r + depth,          0],
            [minor_r,                  pitch*0.18]
        ]);
}

module pan_head_screw() {
    // Use a slightly smaller core so the thread ridge intersects it radially.
    minor_r = max(0.01, shank_r - thread_depth_mm);

    // --- FIX: ensure thread is NOT floating and overlaps the shank axially ---
    // Thread should start at z = -thread_start_mm and extend downward by thread_len.
    // We extend by overlap_mm at both ends so it intersects the unthreaded region and the tip region.
    thread_z_top = -thread_start_mm + overlap_mm;                 // slightly into unthreaded region
    thread_h     = max(0, thread_len + 2*overlap_mm);             // extend both ends for guaranteed union
    thread_turns = (thread_h > 0) ? (thread_h / thread_pitch_mm) : 0;

    union() {
        // --- Head ---
        pan_head_profile(head_r, head_height_mm);

        // --- Shank core (minor diameter) ---
        // Extend into the head by overlap_mm to guarantee attachment at z=0.
        translate([0,0,-shank_len])
            cylinder(r=minor_r, h=shank_len + overlap_mm, center=false);

        // --- Tip (slight cone) ---
        // Overlap into shank core by overlap_mm to avoid any seam.
        translate([0,0, -(shank_len - overlap_mm)])
            cylinder(r1=minor_r, r2=0.05, h=tip_length_mm + overlap_mm, center=false);

        // --- Threads (physically attached to shank) ---
        // FIX: place thread at the correct z (below head), not above it.
        // The ridge is built at minor_r and extends outward by depth, so it intersects the core.
        if (thread_h > 0 && thread_turns > 0) {
            translate([0,0, thread_z_top - thread_h])  // bottom-anchored so the thread spans downward from near the head
                helical_thread_ridge(minor_r, thread_depth_mm, thread_pitch_mm, thread_h, thread_turns);
        }
    }
}

pan_head_screw();