// Standoff pillar with internal M3 (3.0mm nominal) threaded hole
// Target: 10.0mm long, outer diameter = outer_diameter_mm (prompt said "None" -> keep param)
// One connected solid, with visible internal helical thread detail.

$fn = 128;

// Parameters
thread_diameter_mm = 3.0; //[1.5:6.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
outer_diameter_mm = 6.0; //[3.5:12.0:0.5]
top_thread_length_mm = 10.0; //[0.0:10.0:0.5]
bottom_thread_length_mm = 0.0; //[0.0:10.0:0.5]
chamfered = 0; //[0:1:1]
overlap_mm = 0.8; //[0.5:2.0:0.1]
chamfer_height_mm = 0.8; //[0.4:2.0:0.1]
chamfer_reduction_mm = 0.8; //[0.3:2.0:0.1]

// Thread parameters (visual/printable approximation)
thread_pitch_mm = 0.5;          // M3 coarse pitch
thread_depth_mm = 0.30;         // radial depth of thread groove (more visible)
thread_clearance_mm = 0.20;     // clearance for printing/visibility
thread_slices_per_turn = 48;    // smoother helix

eps = 0.02;

// Helical groove cutter for internal thread (subtract from hole wall)
module internal_thread_cutter(d_nom, pitch, depth, len) {
    turns = len / pitch;
    slices = max(ceil(turns * thread_slices_per_turn), 16);

    // Use a slightly larger "major" radius so the groove actually intersects the wall
    // (ensures visible helical detail after subtraction).
    d_minor = max(0.2, d_nom - 2*depth) + 2*thread_clearance_mm;
    r_major = (d_nom/2) + thread_clearance_mm;  // where groove reaches outward
    r_minor = d_minor/2;                        // inner boundary of hole

    // Place a small rectangular "tooth" that sweeps helically to carve a groove.
    // Radial thickness is depth; tangential width is a fraction of pitch.
    tooth_t = depth;
    tooth_w = pitch * 0.55;

    linear_extrude(height=len + 2*eps, twist=-360*turns, slices=slices, convexity=10)
        translate([r_major - tooth_t/2, 0, 0])
            square([tooth_t, tooth_w], center=true);
}

// Main body (standoff pillar)
module standoff_body() {
    union() {
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

        if (chamfered) {
            translate([0, 0, length_mm/2 - chamfer_height_mm/2 + overlap_mm/2])
                cylinder(
                    h=chamfer_height_mm,
                    r1=outer_diameter_mm/2,
                    r2=max(0.01, outer_diameter_mm/2 - chamfer_reduction_mm),
                    center=true
                );

            translate([0, 0, -length_mm/2 + chamfer_height_mm/2 - overlap_mm/2])
                cylinder(
                    h=chamfer_height_mm,
                    r1=outer_diameter_mm/2,
                    r2=max(0.01, outer_diameter_mm/2 - chamfer_reduction_mm),
                    center=true
                );
        }
    }
}

// Threaded hole subtraction (top and/or bottom)
module threaded_hole() {
    top_len = min(top_thread_length_mm, length_mm);
    bot_len = min(bottom_thread_length_mm, length_mm);
    use_full = (top_len <= 0 && bot_len <= 0);

    // Core drill diameter (minor) for internal thread
    d_minor_core = max(0.2, thread_diameter_mm - 2*thread_depth_mm) + 2*thread_clearance_mm;

    union() {
        if (use_full) {
            cylinder(h=length_mm + 2*eps, r=d_minor_core/2, center=true);

            translate([0, 0, -length_mm/2 - eps])
                internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, thread_depth_mm, length_mm + 2*eps);
        } else {
            if (top_len > 0) {
                translate([0, 0, length_mm/2 - top_len/2])
                    cylinder(h=top_len + 2*eps, r=d_minor_core/2, center=true);

                translate([0, 0, length_mm/2 - top_len - eps])
                    internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, thread_depth_mm, top_len + 2*eps);
            }

            if (bot_len > 0) {
                translate([0, 0, -length_mm/2 + bot_len/2])
                    cylinder(h=bot_len + 2*eps, r=d_minor_core/2, center=true);

                translate([0, 0, -length_mm/2 - eps])
                    internal_thread_cutter(thread_diameter_mm, thread_pitch_mm, thread_depth_mm, bot_len + 2*eps);
            }
        }
    }
}

// Final connected solid
difference() {
    standoff_body();
    threaded_hole();
}