// Hex head screw (M4-like) with visible helical threads
// Target dimensions:
// - Shank major diameter: 4.0 mm
// - Head diameter (across corners): 8.1 mm
// - Head height: 2.925 mm
// - Overall length: 10.0 mm

$fn = 96;

// ---------------- Parameters ----------------
screw_length = 10.0;
shank_diameter = 4.0;

head_diameter_across_corners = 8.1;   // across corners (circumradius*2)
head_height = 2.925;

thread_pitch = 0.7;
thread_length = 8.0;                 // threaded portion length from tip upward
thread_depth = 0.35;                 // radial height of thread above root

// small overlaps to guarantee watertight unions/differences
eps = 0.02;
overlap = 0.15;

// derived
shank_len = screw_length - head_height;
head_r = head_diameter_across_corners/2;
shank_r = shank_diameter/2;

// Place screw along +Z, with tip at z=0 and top of head at z=screw_length
z_tip = 0;
z_under_head = shank_len;
z_head_top = screw_length;

// ---------------- Helpers ----------------
module hex_prism(h, r_across_corners) {
    // True 6-sided hex: cylinder with $fn=6 uses r as circumradius (across corners / 2)
    cylinder(h=h, r=r_across_corners, $fn=6);
}

// ISO-ish external thread approximation using linear_extrude twist of a triangular profile
module external_thread(major_d, pitch, length, depth) {
    major_r = major_d/2;
    root_r  = major_r - depth;

    // 2D profile in X-Y plane, extruded along Z with twist.
    // Triangle spans one pitch in Y, radial thickness in X.
    // Keep it slightly inside at the root to avoid non-manifold edges.
    profile = [
        [root_r - eps, -pitch/2],
        [major_r,       0],
        [root_r - eps,  pitch/2]
    ];

    turns = length / pitch;
    linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        polygon(points=profile);
}

// ---------------- Main solid ----------------
module screw_solid() {
    union() {
        // Head (hex)
        translate([0,0,z_under_head - overlap])
            hex_prism(head_height + overlap, head_r);

        // Shank core (root diameter so threads stand proud)
        // Root diameter = major - 2*thread_depth
        root_d = shank_diameter - 2*thread_depth;
        root_r = root_d/2;

        // Unthreaded portion under head (if any)
        unthreaded_len = max(shank_len - thread_length, 0);
        if (unthreaded_len > 0)
            translate([0,0,z_under_head - unthreaded_len - overlap])
                cylinder(h=unthreaded_len + overlap, r=shank_r);

        // Threaded core (root cylinder) + helical ridge
        // Thread starts at tip (z=0) and goes up to thread_length
        translate([0,0,z_tip - overlap])
            cylinder(h=thread_length + overlap, r=root_r);

        translate([0,0,z_tip])
            external_thread(shank_diameter, thread_pitch, thread_length, thread_depth);

        // Tip chamfer (simple cone) to avoid flat end
        tip_chamfer_len = min(1.0, thread_length);
        translate([0,0,z_tip - overlap])
            cylinder(h=tip_chamfer_len + overlap, r1=root_r, r2=0);

        // Small under-head fillet (simple torus-like via rotate_extrude)
        fillet_r = 0.35;
        translate([0,0,z_under_head - fillet_r])
            rotate_extrude(convexity=10, $fn=96)
                translate([shank_r - fillet_r, 0, 0])
                    circle(r=fillet_r, $fn=48);
    }
}

// ---------------- Final output ----------------
screw_solid();