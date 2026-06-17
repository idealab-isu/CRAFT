$fn = 128;

// Standoff pillar: 8.0mm OD, 20.0mm long, M4 (4.0mm) internal thread (visualized)
thread_d = 4.0;   // nominal internal thread major diameter (mm)
length   = 20.0;  // overall length (mm)
outer_d  = 8.0;   // pillar outer diameter (mm)

// M4 coarse pitch (approx)
pitch        = 0.7;   // mm
thread_depth = 0.35;  // mm (visual groove depth)
turns        = length / pitch;

// Helical groove cutter (subtracted from the bore wall)
module internal_thread_groove(d_major, h, p, depth) {
    // Place a small "cutter" circle at the bore radius and twist it along Z
    // so it carves a visible helical groove.
    linear_extrude(height=h, twist=(h/p)*360, slices=ceil((h/p)*32), convexity=10)
        translate([d_major/2 - depth/2, 0, 0])
            circle(d=depth, $fn=24);
}

difference() {
    // Outer body (single connected solid)
    cylinder(h=length, d=outer_d, center=false);

    // Through bore (minor diameter approximation)
    // Extend slightly beyond ends to guarantee a clean cut.
    translate([0, 0, -0.2])
        cylinder(h=length + 0.4, d=thread_d - 2*thread_depth, center=false);

    // Visible internal thread groove (also extended slightly to avoid end artifacts)
    translate([0, 0, -0.2])
        internal_thread_groove(thread_d, length + 0.4, pitch, thread_depth);
}