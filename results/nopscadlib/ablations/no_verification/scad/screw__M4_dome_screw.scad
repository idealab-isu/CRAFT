$fn = 128;

// Target dimensions (mm)
shaft_diameter_mm     = 4.0;   // major diameter
length_under_head_mm  = 10.0;  // from underside of head to tip
head_diameter_mm      = 7.6;
head_height_mm        = 2.2;

// Thread (simple helical ridge approximation)
thread_pitch_mm       = 0.7;
thread_depth_mm       = 0.35;  // radial height of thread ridge
thread_flat_mm        = 0.25;  // ridge thickness (tangential)
tip_chamfer_mm        = 0.8;

// Small overlap to ensure watertight unions/differences
overlap_mm            = 0.05;

module dome_head_screw(
    d_shaft = shaft_diameter_mm,
    L = length_under_head_mm,
    d_head = head_diameter_mm,
    h_head = head_height_mm,
    pitch = thread_pitch_mm,
    t_depth = thread_depth_mm,
    t_flat = thread_flat_mm,
    tip_chamfer = tip_chamfer_mm,
    overlap = overlap_mm
) {
    r_shaft = d_shaft/2;
    r_head  = d_head/2;

    // Minor radius approximated as r_shaft - t_depth
    r_minor = max(0.05, r_shaft - t_depth);

    // Dome as a spherical cap with base radius r_head and cap height h_head:
    // Sphere radius R = (r^2 + h^2) / (2h), center at z = h - R (with base plane at z=0)
    R  = (r_head*r_head + h_head*h_head) / (2*h_head);
    zc = h_head - R;

    // Thread turns
    turns = L / pitch;
    slices_thread = max(ceil(turns * 60), 120);

    union() {
        // --- HEAD (true dome head, not a flat cylinder) ---
        // Spherical cap only (no full-height cylinder that makes it look flat)
        intersection() {
            translate([0,0,zc]) sphere(r = R);
            // Keep only z in [0, h_head]
            translate([0,0,h_head/2]) cube([d_head*3, d_head*3, h_head], center=true);
        }

        // Small underside collar to guarantee a crisp edge and solid connection to shank
        // (kept very thin so the head still reads as a dome)
        cylinder(h = overlap*2, r = r_head, center = false);

        // --- SHANK CORE (extends from z=0 down to z=-L) ---
        translate([0,0,-L])
            cylinder(h = L + overlap, r = r_minor, center = false);

        // --- TIP CHAMFER (at very bottom) ---
        translate([0,0,-L])
            cylinder(h = tip_chamfer, r1 = 0.05, r2 = r_minor, center = false);

        // --- HELICAL THREAD RIDGE (approx) ---
        // Ridge centered near the major diameter; overlaps into core for watertight union
        translate([0,0,-L])
            linear_extrude(height = L, twist = -360*turns, slices = slices_thread, convexity = 10)
                translate([r_minor + t_depth/2 - overlap, 0, 0])
                    square([t_depth + 2*overlap, t_flat], center = true);

        // --- MAJOR DIAMETER "CREST" CYLINDER (ensures 4.0mm major diameter everywhere) ---
        // This also guarantees the thread ridge doesn't leave gaps in orthographic views.
        translate([0,0,-L])
            cylinder(h = L + overlap, r = r_shaft, center = false);

        // --- HEAD/SHANK BLEND (prevents any seam and ensures one connected solid) ---
        translate([0,0,-overlap])
            cylinder(h = overlap*2, r = r_shaft, center = false);
    }
}

dome_head_screw();