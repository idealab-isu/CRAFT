// Standoff pillar: 8.0mm OD, 20.0mm long, M3 (3.0mm) through threaded hole (visual thread)
// One connected solid (body with internal helical thread cut)

$fn = 96;

// Parameters
outer_diameter = 8.0;
length         = 20.0;

thread_diameter = 3.0;   // nominal major diameter (M3)
thread_pitch    = 0.5;   // pitch (visual)
clearance       = 0.15;  // small clearance for printable/visible internal thread

// Derived
body_r = outer_diameter/2;
hole_r = (thread_diameter + clearance)/2;

// Main
standoff_pillar();

module standoff_pillar() {
    difference() {
        // Pillar body (centered)
        cylinder(h=length, r=body_r, center=true);

        // Through threaded hole (centered, slightly longer to guarantee clean cut)
        internal_thread_cut(
            major_d = thread_diameter + clearance,
            pitch   = thread_pitch,
            depth   = length + 0.6
        );
    }
}

// Creates a helical "tap" shape to subtract from the body (internal thread appearance)
module internal_thread_cut(major_d, pitch, depth) {
    major_r = major_d/2;
    // Thread depth for ISO metric (approx). Keep conservative for robustness.
    thread_h = 0.60 * pitch;
    minor_r  = max(0.01, major_r - thread_h);

    // Helix parameters
    turns = depth / pitch;
    slices_per_turn = 28;
    steps = max(12, ceil(turns * slices_per_turn));
    twist_deg = 360 * turns;

    // Place centered along Z, extend a bit to ensure full cut
    translate([0, 0, -depth/2])
    union() {
        // Core cylinder to ensure a continuous through-hole
        cylinder(h=depth, r=minor_r, center=false);

        // Helical ridge to carve thread flanks
        // Use a small triangular profile at radius ~minor_r to major_r
        linear_extrude(height=depth, twist=twist_deg, slices=steps, convexity=10)
            translate([minor_r, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [thread_h, 0],
                    [0,  pitch*0.22]
                ]);
    }
}