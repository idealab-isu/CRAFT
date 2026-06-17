// Standoff pillar: M3 (3.0mm) internal thread representation, 20.0mm long, 8.0mm diameter
// One connected solid with a visible through-bore and simple internal "thread" cue.

$fn = 128;

// Parameters (mm)
overall_length   = 20.0;
outer_diameter   = 8.0;

thread_diameter  = 3.0;     // nominal M3 major diameter
bore_diameter    = 2.6;     // tap drill / minor diameter for visible internal thread representation
bore_length      = overall_length;

end_chamfer_h    = 0.8;     // chamfer height
end_chamfer_delta= 0.6;     // radial reduction across chamfer
overlap          = 0.2;     // robust boolean overlap

// Simple internal "thread" cue (not a true ISO thread):
// subtract a shallow helical groove from the bore wall so thread detail is visible.
thread_pitch     = 0.5;     // M3 coarse pitch
thread_depth     = 0.18;    // shallow groove depth
thread_turns     = bore_length / thread_pitch;

module internal_thread_cue(h, r_minor, pitch, depth) {
    // Helical groove: rotate_extrude a small rectangle while twisting along Z
    // Positioned at the bore wall so it cuts into the cylinder.
    linear_extrude(height = h + 2*overlap, twist = -360 * (h / pitch), slices = max(60, ceil(12*(h/pitch))), center = true)
        translate([r_minor - depth/2, 0, 0])
            square([depth, pitch*0.45], center = true);
}

module standoff_pillar() {
    difference() {
        // Outer body with chamfered ends (single connected solid)
        union() {
            // Main cylinder shortened to make room for chamfers
            cylinder(h = overall_length - 2*end_chamfer_h, r = outer_diameter/2, center = true);

            // Top chamfer
            translate([0, 0, overall_length/2 - end_chamfer_h/2])
                cylinder(h = end_chamfer_h,
                         r1 = outer_diameter/2,
                         r2 = outer_diameter/2 - end_chamfer_delta,
                         center = true);

            // Bottom chamfer
            translate([0, 0, -overall_length/2 + end_chamfer_h/2])
                cylinder(h = end_chamfer_h,
                         r1 = outer_diameter/2 - end_chamfer_delta,
                         r2 = outer_diameter/2,
                         center = true);
        }

        // Through bore (minor diameter)
        cylinder(h = bore_length + 2*overlap, r = bore_diameter/2, center = true);

        // Internal thread cue: shallow helical groove at approx. major radius
        internal_thread_cue(bore_length, thread_diameter/2, thread_pitch, thread_depth);
    }
}

standoff_pillar();