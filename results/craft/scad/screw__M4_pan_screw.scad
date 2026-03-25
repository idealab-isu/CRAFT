// Pan head screw (M4-like) — single connected solid
$fn = 96;

// Target dimensions
shaft_diameter_mm = 4.0;
head_diameter_mm  = 7.8;
head_height_mm    = 3.3;
length_mm         = 10.0;   // under-head length

// Modeling controls
overlap_mm = 0.2;           // small overlap to guarantee watertight union
thread_pitch_mm = 0.7;      // visual thread pitch (approx)
thread_depth_mm = 0.35;     // radial thread depth (visual)
thread_segments_per_turn = 24;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

// Simple pan head profile (rounded-ish) using rotate_extrude
module pan_head(d_head, h_head) {
    r = d_head/2;
    h = h_head;

    // Profile points in (radius, z), z from 0..h
    // Slight dome and small under-head fillet.
    rotate_extrude(convexity=10)
        polygon(points=[
            [0, 0],
            [r - 0.35, 0],
            [r, 0.35],
            [r, h - 0.55],
            [r - 0.55, h],
            [0, h]
        ]);
}

// Helical thread (visual) as a twisted triangular rib around the shaft
module visual_thread(d_major, length, pitch, depth) {
    r_major = d_major/2;
    turns = length / pitch;
    twist_deg = 360 * turns;

    // Triangular thread section in XY, extruded along Z with twist
    // Positioned so its outer radius reaches r_major.
    linear_extrude(height=length, twist=twist_deg, slices=max(ceil(turns*thread_segments_per_turn), 12), convexity=10)
        polygon(points=[
            [r_major - depth, -pitch*0.18],
            [r_major,          0],
            [r_major - depth,  pitch*0.18]
        ]);
}

// Complete screw as one connected solid, oriented along +Z
module pan_head_screw(d_shaft, d_head, h_head, len_under_head) {
    union() {
        // Head: z in [0, h_head]
        pan_head(d_head, h_head);

        // Core shaft (minor diameter) to ensure solid body under threads
        // z in [h_head - overlap, h_head + len_under_head]
        translate([0, 0, h_head - overlap_mm])
            cylinder(r=shaft_r - thread_depth_mm, h=len_under_head + overlap_mm, center=false);

        // Visual thread rib around shaft
        translate([0, 0, h_head - overlap_mm])
            visual_thread(d_shaft, len_under_head + overlap_mm, thread_pitch_mm, thread_depth_mm);

        // Small tip chamfer
        translate([0, 0, h_head + len_under_head - 0.6])
            cylinder(r1=shaft_r - thread_depth_mm, r2=max(shaft_r - thread_depth_mm - 0.4, 0.1), h=0.6, center=false);
    }
}

pan_head_screw(shaft_diameter_mm, head_diameter_mm, head_height_mm, length_mm);