$fn = 160;

// Standoff pillar: 3.0mm thread, 20.0mm long, 8.0mm diameter
thread_d = 3.0;   // nominal thread major diameter (mm)
length   = 20.0;  // overall length (mm)
outer_d  = 8.0;   // pillar diameter (mm)

// Visible internal thread representation (helical groove) for render verification
pitch        = 0.5;   // M3 coarse pitch (mm)
thread_depth = 0.30;  // deeper groove so it is clearly visible in renders
minor_d      = thread_d - 2*thread_depth;

eps = 0.05;

module internal_thread_bore(d_major, d_minor, h, p) {
    turns  = h / p;
    groove_w = p * 0.65;                 // axial width of groove
    groove_r = (d_major - d_minor) / 2;  // radial depth of groove

    difference() {
        // Base cylindrical bore at minor diameter
        translate([0,0,-eps]) cylinder(d=d_minor, h=h + 2*eps);

        // Helical groove cut (triangular-ish) to suggest threads up to major diameter
        translate([0,0,-eps])
            linear_extrude(
                height = h + 2*eps,
                twist  = -360 * turns,
                slices = max(ceil(turns * 120), 200),
                convexity = 10
            )
                translate([d_minor/2, 0, 0])
                    polygon(points=[
                        [0, -groove_w/2],
                        [groove_r, 0],
                        [0,  groove_w/2]
                    ]);
    }
}

difference() {
    // Outer pillar
    cylinder(d=outer_d, h=length);

    // Threaded bore through entire length (connected via difference)
    internal_thread_bore(thread_d, minor_d, length, pitch);
}