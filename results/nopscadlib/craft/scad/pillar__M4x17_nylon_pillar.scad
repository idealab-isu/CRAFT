// Standoff pillar: 8.0mm OD, 20.0mm long, internal M4x0.7 thread (modeled)
// One connected solid (single part)

// -------- Parameters (mm) --------
length = 20.0;
outer_diameter = 8.0;

// Thread (M4 coarse)
thread_major_d   = 4.0;   // nominal major diameter
thread_pitch     = 0.7;   // M4x0.7
thread_depth     = 0.35;  // radial depth (visual/printable approximation)
thread_clearance = 0.15;  // extra radius for easier fit

// Lead-in chamfers
chamfer_height = 0.8;
chamfer_radial = 0.6;

// Resolution
$fn = 128;

// -------- Helpers --------
module internal_thread_tap(h, major_d, pitch, depth, clearance=0, starts=1) {
    // Helical "tap" volume to subtract (internal thread)
    // Uses a 2D profile in XY and twists along Z.
    r_maj = major_d/2 + clearance;
    r_min = max(0.01, r_maj - depth);

    turns = h / pitch;
    twist_deg = 360 * turns;

    // 2D profile: a narrow triangle spanning from r_min to r_maj
    profile = [
        [r_min, -pitch*0.18],
        [r_maj,  0],
        [r_min,  pitch*0.18]
    ];

    union() {
        // Core cylinder ensures a continuous through-hole in all views
        cylinder(h=h, r=r_min, center=true);

        // Helical ridge cutter
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(
                    height=h,
                    center=true,
                    twist=twist_deg,
                    slices=max(ceil(turns*48), 64),
                    convexity=10
                )
                    polygon(points=profile);
        }
    }
}

module standoff_pillar() {
    difference() {
        // Outer body
        cylinder(h=length, r=outer_diameter/2, center=true);

        // Internal threaded hole through (slightly longer to guarantee through-cut)
        internal_thread_tap(
            h = length + 1.0,
            major_d = thread_major_d,
            pitch = thread_pitch,
            depth = thread_depth,
            clearance = thread_clearance,
            starts = 1
        );

        // Lead-in chamfers on the hole (both ends)
        if (chamfer_height > 0) {
            translate([0,0,  length/2 - chamfer_height/2])
                cylinder(
                    h=chamfer_height,
                    r1=thread_major_d/2 + thread_clearance + chamfer_radial,
                    r2=thread_major_d/2 + thread_clearance,
                    center=true
                );
            translate([0,0, -length/2 + chamfer_height/2])
                cylinder(
                    h=chamfer_height,
                    r1=thread_major_d/2 + thread_clearance + chamfer_radial,
                    r2=thread_major_d/2 + thread_clearance,
                    center=true
                );
        }
    }
}

standoff_pillar();