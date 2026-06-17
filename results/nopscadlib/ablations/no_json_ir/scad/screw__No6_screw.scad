// Pan head screw (connected solid)
// Target dimensions:
// - Shank (major) diameter: 3.5 mm
// - Length under head:      10 mm
// - Head diameter:          6.7 mm
// - Head height:            2.2 mm

$fn = 128;

// Parameters
shaft_diameter = 3.5;
shaft_length   = 10;

head_diameter  = 6.7;
head_height    = 2.2;

// Thread (visual/approx)
thread_pitch   = 0.7;
thread_depth   = 0.25;   // radial height of thread ridge
thread_starts  = 1;

// Derived
shaft_r = shaft_diameter/2;
head_r  = head_diameter/2;

// Helical thread ridge wrapped around a core cylinder.
// Ensures major diameter ~= (core_r + depth)*2
module helical_thread(core_r, length, pitch, depth, starts=1) {
    turns = length / pitch;
    overlap = 0.08; // overlap into core for watertight union

    union() {
        // Core (minor diameter approx)
        cylinder(h=length, r=core_r, center=false);

        // Thread ridge(s)
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(
                    height=length,
                    twist=turns*360,
                    slices=max(ceil(turns*80), 120),
                    center=false,
                    convexity=10
                )
                    translate([core_r - overlap, 0, 0])
                        polygon(points=[
                            [0, -pitch*0.22],
                            [depth, 0],
                            [0,  pitch*0.22]
                        ]);
        }
    }
}

// True-ish pan head: cylindrical side with domed top (not conical/countersunk).
// Built as a rotate_extrude profile with a vertical outer wall and rounded crown.
module pan_head(d, h) {
    r = d/2;

    // Shape controls (kept proportional, but constrained to requested d/h)
    crown_h = h * 0.55;                 // dome height portion
    cyl_h   = h - crown_h;              // straight cylindrical wall height
    fillet_r = min(h*0.12, r*0.10);      // small under-head fillet

    // Ensure non-negative
    crown_h2 = max(crown_h, 0.01);
    cyl_h2   = max(cyl_h,   0.01);

    rotate_extrude(convexity=10)
        polygon(points=[
            // Axis
            [0, 0],

            // Under-head fillet into shank area (keeps head from looking countersunk)
            [r - fillet_r, 0],
            [r, fillet_r],

            // Straight cylindrical side up to start of crown
            [r, cyl_h2],

            // Rounded crown (quarter-ish arc approximation with a few points)
            [r*0.985, cyl_h2 + crown_h2*0.25],
            [r*0.940, cyl_h2 + crown_h2*0.55],
            [r*0.820, cyl_h2 + crown_h2*0.82],
            [r*0.620, cyl_h2 + crown_h2*0.95],
            [r*0.420, h],
            [0, h]
        ]);
}

// Complete screw (one connected solid)
module screw() {
    overlap = 0.10;

    // Choose core radius so major diameter matches shaft_diameter
    core_r = shaft_r - thread_depth;

    union() {
        // Threaded shank (under head)
        helical_thread(core_r=core_r, length=shaft_length, pitch=thread_pitch, depth=thread_depth, starts=thread_starts);

        // Pan head connected at z = shaft_length with overlap
        translate([0, 0, shaft_length - overlap])
            pan_head(d=head_diameter, h=head_height + overlap);
    }
}

screw();