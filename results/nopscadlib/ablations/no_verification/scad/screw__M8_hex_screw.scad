// Hex head screw (single connected solid)
// Target: shaft Ø8.0mm, head Ø15.0mm (across flats), head height 5.65mm, shank length 10mm

shaft_diameter_mm = 8.0;
head_diameter_mm  = 15.0;   // interpreted as across-flats for hex head
head_height_mm    = 5.65;
length_mm         = 10.0;

threaded = 1;               // 0/1
thread_pitch_mm = 1.25;     // visual pitch
thread_depth_mm = 0.35;     // radial depth (visual)
thread_start_mm = 0.6;      // unthreaded under-head length
tip_length_mm   = 1.2;      // small chamfered tip length
overlap_mm      = 0.15;     // small overlap to ensure manifold union

$fn = 96;

// --- Helpers ---
module hex_prism_af(af, h, center=false) {
    // OpenSCAD cylinder(d=..., $fn=6) uses diameter across vertices.
    // Convert across-flats (AF) to across-vertices (AV): AV = AF / cos(30°)
    av = af / cos(30);
    cylinder(h=h, d=av, $fn=6, center=center);
}

module helical_thread_visual(d_major, pitch, depth, len, slices_per_turn=24) {
    // Simple visual thread: a small triangular ridge swept helically.
    // Not a true ISO profile; intended for appearance.
    turns = len / pitch;
    steps = max(8, ceil(turns * slices_per_turn));
    r_major = d_major/2;
    r_root  = r_major - depth;

    for (i = [0:steps-1]) {
        z0 = (i    ) * len/steps;
        z1 = (i + 1) * len/steps;
        a0 = (i    ) * 360 * turns/steps;
        a1 = (i + 1) * 360 * turns/steps;

        hull() {
            translate([0,0,z0]) rotate([0,0,a0])
                linear_extrude(height=overlap_mm, center=false, convexity=5)
                    polygon(points=[
                        [r_root, -pitch*0.18],
                        [r_major, 0],
                        [r_root,  pitch*0.18]
                    ]);

            translate([0,0,z1]) rotate([0,0,a1])
                linear_extrude(height=overlap_mm, center=false, convexity=5)
                    polygon(points=[
                        [r_root, -pitch*0.18],
                        [r_major, 0],
                        [r_root,  pitch*0.18]
                    ]);
        }
    }
}

// --- Main screw ---
module hex_head_screw() {
    // Coordinate system: head sits on Z>=0, shank extends to negative Z.
    // Head: z in [0, head_height]
    // Shank: z in [-length, 0]

    union() {
        // Hex head (across flats = head_diameter_mm)
        translate([0,0,head_height_mm/2])
            hex_prism_af(head_diameter_mm, head_height_mm, center=true);

        // Shank core (slightly overlaps into head)
        translate([0,0,-length_mm/2 + overlap_mm/2])
            cylinder(h=length_mm + overlap_mm, d=shaft_diameter_mm, center=true);

        // Tip chamfer (connected at shank end)
        translate([0,0,-length_mm + tip_length_mm/2])
            cylinder(h=tip_length_mm, r1=shaft_diameter_mm/2, r2=max(0.01, shaft_diameter_mm/2 - 0.9), center=true);

        // Visual threads (wrapped around shank)
        if (threaded) {
            thread_len = max(0, length_mm - thread_start_mm - tip_length_mm);
            if (thread_len > 0) {
                translate([0,0,-length_mm + tip_length_mm])
                    helical_thread_visual(
                        d_major = shaft_diameter_mm + 2*thread_depth_mm,
                        pitch   = thread_pitch_mm,
                        depth   = thread_depth_mm,
                        len     = thread_len
                    );
            }
        }
    }
}

hex_head_screw();