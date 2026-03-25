// Dome head screw with visible threads + drive feature (single connected solid)
// Target dimensions (mm):
// - Shank major Ø2.5
// - Head Ø5.35
// - Head height 1.6
// - Length under head 10

$fn = 128;

// Parameters (mm)
shaft_diameter_mm = 2.5;   // major diameter
length_mm         = 10;    // under-head length
head_diameter_mm  = 5.35;
head_height_mm    = 1.6;

// Thread (visual, not ISO-perfect)
thread_pitch_mm   = 0.45;  // close to M2.5 coarse (0.45)
thread_depth_mm   = 0.18;  // radial depth (kept modest for robustness)
thread_start_mm   = 0.6;   // unthreaded length under head
thread_end_mm     = 0.4;   // unthreaded at tip

// Drive feature (Phillips-like cross recess)
drive_depth_mm    = 0.55;
drive_arm_w_mm    = 0.75;
drive_arm_l_mm    = 2.2;

// Small overlap to guarantee watertight unions/differences
overlap_mm = 0.06;

module helical_thread_visual(d_major, pitch, depth, L, ov=0.05) {
    // Creates a helical ridge around a core cylinder.
    // Major diameter is d_major; ridge adds up to that, core is reduced.
    r_major = d_major/2;
    r_core  = max(0.01, r_major - depth);

    turns = L / pitch;
    twist_deg = 360 * turns;

    union() {
        // Core
        cylinder(h=L + ov, r=r_core, center=false);

        // Helical ridge (triangular-ish section)
        // Place a small polygon at radius r_core and twist-extrude it.
        linear_extrude(height=L + ov, twist=twist_deg, slices=max(ceil(turns*24), 60), center=false)
            translate([r_core, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module dome_head(d_head, h_head, ov=0.05) {
    r_head = d_head/2;

    // Spherical cap: base radius = r_head at z=0, height = h_head above base.
    R  = (r_head*r_head + h_head*h_head) / (2*h_head);
    zc = h_head - R;

    intersection() {
        translate([0,0,zc]) sphere(r=R);
        translate([0,0,h_head/2])
            cylinder(h=h_head + ov, r=r_head, center=true);
    }
}

module phillips_recess(d_head, h_head, depth, arm_w, arm_l, ov=0.05) {
    // Cut a simple cross recess into the dome head.
    // Positioned from the top surface downward.
    // Use a slight taper for better visibility.
    z_top = h_head;
    z_center = z_top - depth/2;

    translate([0,0,z_center])
        union() {
            for (a = [0, 90]) rotate([0,0,a])
                linear_extrude(height=depth + ov, center=true, scale=0.85)
                    square([arm_l, arm_w], center=true);
        }
}

module dome_head_screw(
    d_shaft = shaft_diameter_mm,
    L       = length_mm,
    d_head  = head_diameter_mm,
    h_head  = head_height_mm,
    pitch   = thread_pitch_mm,
    tdepth  = thread_depth_mm,
    tstart  = thread_start_mm,
    tend    = thread_end_mm,
    drv_d   = drive_depth_mm,
    drv_w   = drive_arm_w_mm,
    drv_l   = drive_arm_l_mm,
    ov      = overlap_mm
){
    // Ensure thread length is valid
    thread_L = max(0, L - tstart - tend);

    difference() {
        union() {
            // Head at z in [0, h_head]
            dome_head(d_head, h_head, ov);

            // Under-head shank: z in [-L, 0]
            // Build as: unthreaded near head + threaded section + unthreaded tip
            // All positioned with formulas so everything is connected.

            // Unthreaded near head: from z = -tstart to 0
            if (tstart > 0)
                translate([0,0,-tstart])
                    cylinder(h=tstart + ov, r=d_shaft/2, center=false);

            // Threaded section: from z = -(tstart + thread_L) to z = -tstart
            if (thread_L > 0)
                translate([0,0,-(tstart + thread_L)])
                    helical_thread_visual(d_major=d_shaft, pitch=pitch, depth=tdepth, L=thread_L, ov=ov);

            // Unthreaded tip: from z = -L to z = -(tstart + thread_L)
            if (tend > 0)
                translate([0,0,-L])
                    cylinder(h=tend + ov, r=max(0.01, (d_shaft/2 - tdepth*0.6)), center=false);
        }

        // Drive recess cut into head from the top
        phillips_recess(d_head, h_head, drv_d, drv_w, drv_l, ov);
    }
}

dome_head_screw();