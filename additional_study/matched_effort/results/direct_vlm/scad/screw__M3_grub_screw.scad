$fn=96;

// Simple parametric M3 grub screw (set screw) approximation.
// Not a standards-perfect thread, but sized to typical M3x0.5 and renderable.

module helical_thread(d_major=3, pitch=0.5, length=6, depth=0.27, flank=60, starts=1) {
    // Create an external V-thread by twisting a triangular profile along Z.
    // depth ~ 0.27mm is a reasonable approximation for M3.
    turns = length / pitch;
    r_major = d_major/2;
    r_root  = r_major - depth;

    // Triangle profile in (radius, z) plane, then rotate_extrude with twist.
    // Centered around z=0 for linear_extrude convenience.
    h = pitch; // one pitch height for profile scaling
    // Approximate V profile: tip at major radius, base at root radius.
    // Use small truncation to avoid zero-thickness.
    trunc = 0.05;

    for (s = [0:starts-1]) {
        rotate([0,0,360*s/starts])
            translate([0,0,0])
                rotate_extrude(angle=360, convexity=10)
                    // Build a "thread ring" by sweeping a 2D profile around Z,
                    // then twist it along Z with linear_extrude.
                    // We do this by first making a 2D profile in XY and then twisting via linear_extrude.
                    // However rotate_extrude can't be twisted; so instead we use linear_extrude of a 2D profile
                    // placed at radius and rely on twist to create helix.
                    // Implemented below outside this loop.
                    children();
    }
}

module external_v_thread(d_major=3, pitch=0.5, length=6, depth=0.27, starts=1) {
    turns = length / pitch;
    r_major = d_major/2;
    r_root  = r_major - depth;
    trunc = 0.05;

    // 2D profile in XY to be twisted: a small triangle located at radius.
    // We'll extrude along Z with twist to form a helical ridge.
    // Profile is in XY; X is radial direction, Y is tangential thickness.
    tang = pitch*0.35; // ridge thickness
    profile = [
        [r_root, -tang/2],
        [r_major-trunc, 0],
        [r_root,  tang/2]
    ];

    union() {
        for (s=[0:starts-1]) {
            rotate([0,0,360*s/starts])
                linear_extrude(height=length, twist=360*turns, slices=max(ceil(turns*40), 60), convexity=10)
                    polygon(points=profile);
        }
    }
}

module m3_grub(length=6, d_major=3, pitch=0.5, hex_socket_af=1.5, socket_depth=2.0, chamfer=0.25) {
    depth = 0.27; // approx for M3
    r_major = d_major/2;

    difference() {
        // Body core + thread
        union() {
            // Core cylinder slightly under major diameter so thread adds to major
            cylinder(h=length, r=r_major - depth*0.55);

            // Thread ridge
            external_v_thread(d_major=d_major, pitch=pitch, length=length, depth=depth, starts=1);

            // Small chamfers at ends (approx)
            if (chamfer > 0) {
                // top chamfer
                translate([0,0,length-chamfer])
                    cylinder(h=chamfer, r1=r_major, r2=r_major-chamfer);
                // bottom chamfer
                cylinder(h=chamfer, r1=r_major-chamfer, r2=r_major);
            }
        }

        // Hex socket (Allen) on top
        translate([0,0,length - socket_depth])
            cylinder(h=socket_depth+0.2, r=hex_socket_af/(2*cos(30)), $fn=6);

        // Slight cone at bottom to mimic cup point (optional subtle)
        translate([0,0,-0.01])
            cylinder(h=0.8, r1=r_major*0.55, r2=r_major*0.15);
    }
}

// Example: M3x6 grub screw
m3_grub(length=6);