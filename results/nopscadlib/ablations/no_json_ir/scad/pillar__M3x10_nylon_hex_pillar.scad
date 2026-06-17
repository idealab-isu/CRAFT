// Standoff pillar, internal M3x0.5 thread (modeled as a helical cut), 10mm long
// Outer diameter unspecified ("Nonemm") -> parameterized default provided

$fn = 128;

pillar_length = 10.0;     // mm
outer_diameter = 6.0;     // mm (default; change as needed)

m3_pitch = 0.5;           // mm (M3 coarse)
m3_major_d = 3.0;         // mm
m3_minor_d = 2.4;         // mm (approx internal minor diameter for M3)
thread_depth = (m3_major_d - m3_minor_d) / 2;

overcut = 0.3;            // mm extra for clean booleans

module internal_thread(len, major_d, pitch, depth) {
    // Core hole up to minor diameter
    cylinder(h = len + 2*overcut, d = major_d - 2*depth, center = true);

    // Helical groove to represent thread
    // Use a triangular profile swept with linear_extrude(twist=...)
    turns = (len + 2*overcut) / pitch;
    linear_extrude(height = len + 2*overcut, twist = -360 * turns, center = true, convexity = 10)
        translate([major_d/2 - depth, 0, 0])
            polygon(points = [
                [0, -pitch/2],
                [depth, 0],
                [0,  pitch/2]
            ]);
}

module standoff_pillar(len, od) {
    difference() {
        cylinder(h = len, d = od, center = true);
        internal_thread(len, m3_major_d, m3_pitch, thread_depth);
    }
}

standoff_pillar(pillar_length, outer_diameter);