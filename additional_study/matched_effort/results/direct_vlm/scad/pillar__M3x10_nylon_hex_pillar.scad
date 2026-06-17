$fn = 96;

// Standoff pillar, M3 internal thread, 10mm long.
// Outer diameter was unspecified ("Nonemm"), so a common M3 standoff OD is used.
length   = 10.0;   // mm
outer_d  = 6.0;    // mm (typical for M3 standoffs; adjust if needed)

// Internal M3 coarse approximation
thread_d = 3.0;    // mm (nominal major diameter)
pitch    = 0.5;    // mm
thread_depth = 0.30;                 // radial depth (visual/printable approximation)
minor_d = thread_d - 2*thread_depth; // internal thread minor diameter approximation

eps = 0.02;

// 2D profile for a simple triangular thread ridge (radius vs z), then twisted along Z
module thread_ridge_2d(major_r, minor_r, pitch) {
    polygon(points=[
        [minor_r, 0],
        [major_r, pitch/2],
        [minor_r, pitch]
    ]);
}

// Creates a "tap-like" solid that represents the internal thread volume to subtract
module internal_thread_cutter(d_major, d_minor, h, pitch) {
    major_r = d_major/2;
    minor_r = d_minor/2;

    turns = h / pitch;
    twist_deg = 360 * turns;

    union() {
        // Core at minor diameter (ensures a continuous bore)
        cylinder(h=h, d=d_minor);

        // Helical ridge out to major diameter (creates thread form when subtracted)
        linear_extrude(height=h, twist=twist_deg, slices=max(ceil(turns*24), 24), convexity=10)
            thread_ridge_2d(major_r, minor_r, pitch);
    }
}

// One connected solid: cylindrical standoff body with internal M3 thread
difference() {
    // Outer spacer body
    cylinder(h=length, d=outer_d);

    // Internal threaded bore (slightly extended to guarantee clean cut-through)
    translate([0, 0, -eps])
        internal_thread_cutter(thread_d, minor_d, length + 2*eps, pitch);
}