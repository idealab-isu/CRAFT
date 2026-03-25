// Dome head screw with threads (single connected solid)
// Requested: shaft Ø8.0mm, head Ø14.0mm, head height 4.4mm, length 10mm

shaft_diameter_mm = 8.0;   //[4.0:16.0:0.1]
head_diameter_mm  = 14.0;  //[7.0:28.0:0.1]
head_height_mm    = 4.4;   //[2.2:8.8:0.1]
length_mm         = 10.0;  //[5.0:20.0:0.5]
overlap_mm        = 0.2;   //[0.05:1.0:0.05]

thread_pitch_mm   = 1.25;  //[0.6:2.5:0.05]
thread_depth_mm   = 0.55;  //[0.2:1.2:0.05]
thread_starts     = 1;     //[1:4]
thread_fn         = 24;    //[12:64]

$fn = 128;

module helical_thread(major_r, pitch, depth, len, starts=1, fn=24) {
    // Creates an external thread by sweeping a small triangular profile along a helix.
    // The thread is unioned with a core cylinder to ensure a single connected solid.
    turns = len / pitch;
    steps = max(8, ceil(turns * fn));
    twist_total = 360 * turns;

    // Triangular profile (in XY), positioned at the major radius.
    // Base at major_r, tip at (major_r - depth).
    module tooth2d() {
        polygon(points=[
            [major_r, -pitch*0.22],
            [major_r,  pitch*0.22],
            [major_r - depth, 0]
        ]);
    }

    union() {
        // Core cylinder up to minor radius
        cylinder(r=max(0.01, major_r - depth), h=len, center=false);

        // Thread ridge(s)
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(height=len, twist=twist_total, slices=steps, convexity=10)
                    tooth2d();
        }
    }
}

module dome_head_profile(head_r, head_h) {
    // Revolved profile for a dome head (underside at z=0, top at z=head_h)
    // Uses a circular arc to form a true dome rather than a flat cylinder.
    // Choose a sphere radius that yields a dome within the given height.
    // Ensure R >= head_r and dome height <= head_h.
    R = max(head_r, (head_r*head_r + head_h*head_h) / (2*head_h)); // sphere radius producing height head_h
    zc = head_h - R; // sphere center z

    // Build 2D profile in XZ plane for rotate_extrude (x>=0)
    // Points: start at axis, go to underside edge, then follow arc to top, then back to axis.
    n = 48;
    pts_arc = [
        for (i = [0:n])
            let(x = head_r * (i/n))
            let(z = zc + sqrt(max(0, R*R - x*x)))
            [x, z]
    ];

    // Ensure underside is flat at z=0 out to head_r
    pts = concat(
        [[0,0], [head_r,0]],
        reverse(pts_arc),   // from [head_r, z_at_edge] back to [0, head_h]
        [[0, head_h]]
    );

    rotate_extrude(convexity=10)
        polygon(points=pts);
}

module dome_head_screw() {
    shaft_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Coordinate system:
    // underside of head at z=0
    // threaded shaft extends down to z=-length_mm
    union() {
        // Dome head (true dome via rotate_extrude profile)
        dome_head_profile(head_r, head_height_mm);

        // Threaded shaft (connected with overlap into head)
        translate([0,0,-length_mm - overlap_mm])
            helical_thread(
                major_r = shaft_r,
                pitch   = thread_pitch_mm,
                depth   = min(thread_depth_mm, shaft_r*0.45),
                len     = length_mm + overlap_mm,
                starts  = thread_starts,
                fn      = thread_fn
            );
    }
}

dome_head_screw();