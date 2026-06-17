$fn = 128;

// Standoff pillar with external thread
// Specs: 2.0mm thread (major dia), 16.0mm long, 3.17mm pillar diameter

length   = 16.0;   // overall length (mm)
outer_d  = 3.17;   // pillar diameter (mm)
thread_d = 2.0;    // thread major diameter (mm)

// Approximate ISO M2 external thread parameters
pitch        = 0.40;   // mm
thread_depth = 0.18;   // radial depth (visible but still within pillar)
minor_d      = thread_d - 2*thread_depth;

eps = 0.02;

assert(minor_d > 0, "Thread minor diameter must be > 0. Reduce thread_depth.");
assert(thread_d <= outer_d + 1e-6, "Thread major diameter must be <= pillar diameter.");

module external_thread_ridge(d_major, d_minor, h, p, slices_per_turn=48) {
    turns = h / p;
    steps = max(16, ceil(turns * slices_per_turn));
    twist_deg = 360 * turns;

    // 2D ridge profile in (radius, z-within-one-pitch)
    // Slightly asymmetric to avoid degeneracy and improve visibility
    profile = [
        [d_minor/2, -p/2],
        [d_major/2, -p/8],
        [d_major/2,  p/8],
        [d_minor/2,  p/2]
    ];

    linear_extrude(height=h, twist=twist_deg, slices=steps, convexity=10)
        polygon(points=profile);
}

union() {
    // Main pillar body
    cylinder(h=length, d=outer_d, center=false);

    // Thread ridge: start slightly below and extend slightly above for guaranteed overlap
    translate([0, 0, -eps])
        external_thread_ridge(thread_d, minor_d, length + 2*eps, pitch, slices_per_turn=56);
}