$fn = 96;

// Target dimensions (mm)
shaft_diameter     = 6.0;    // shank major diameter
length_under_head  = 10.0;   // length from under-head bearing surface to tip
head_diameter      = 11.5;   // across flats (hex)
head_height        = 4.15;   // head thickness

// Small overlap to guarantee a single connected solid
eps = 0.05;

// ISO-ish coarse pitch for M6 (visual threads)
thread_pitch = 1.0;

// Helical thread (external) using linear_extrude(twist=...)
module external_thread(d_major, pitch, len, depth=0.35, starts=1) {
    r_major = d_major/2;
    r_minor = r_major - depth;

    // Keep sane geometry
    depth2 = max(min(depth, r_major*0.45), 0.05);
    r_minor2 = r_major - depth2;

    turns = len / pitch;
    slices = max(ceil(turns * 40), 80);

    // A simple triangular thread profile placed at the major radius
    // and swept helically. Unioned with a minor cylinder to form a solid.
    union() {
        // Core at minor diameter
        cylinder(h=len + eps, r=r_minor2, center=false);

        // Thread ridge
        for (s = [0:starts-1]) {
            rotate([0, 0, s * 360/starts])
                linear_extrude(height=len + eps, twist=turns*360, slices=slices, center=false, convexity=10)
                    translate([r_minor2, 0, 0])
                        polygon(points=[
                            [0, -pitch*0.25],
                            [depth2, 0],
                            [0,  pitch*0.25]
                        ]);
        }
    }
}

// Hex head screw (one connected solid), oriented with under-head at z=0 and tip at z=-L
module hex_head_screw(d=6.0, L=10.0, af=11.5, hh=4.15, pitch=1.0) {
    // Across-flats to circumscribed radius for a 6-sided polygon
    hex_R = af / (2 * cos(30));

    // Small under-head transition height
    trans_h = 0.6;

    union() {
        // Threaded shank: from z=-L to z=0
        translate([0, 0, -L])
            external_thread(d_major=d, pitch=pitch, len=L, depth=0.35);

        // Under-head chamfer/fillet transition to ensure robust connection
        // Spans z=0..trans_h
        translate([0, 0, trans_h/2])
            cylinder(h=trans_h + eps, r1=d/2, r2=hex_R*0.98, center=true);

        // Hex head: from z=0..hh
        translate([0, 0, hh/2])
            cylinder(h=hh + eps, r=hex_R, $fn=6, center=true);

        // Tip chamfer at the end of the shank (near z=-L)
        tip_h = 0.8;
        translate([0, 0, -L + tip_h/2])
            cylinder(h=tip_h + eps, r1=d/2, r2=max(d/2 - 0.8, 0.2), center=true);
    }
}

hex_head_screw(shaft_diameter, length_under_head, head_diameter, head_height, thread_pitch);