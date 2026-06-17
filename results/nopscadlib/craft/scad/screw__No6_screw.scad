// Pan head screw (single connected solid)
// Exact target dimensions:
// - Shank Ø3.5mm
// - Head Ø6.7mm
// - Head height 2.2mm
// - Overall length 10mm (tip to top)

shaft_diameter_mm = 3.5;
length_mm = 10;
head_diameter_mm = 6.7;
head_height_mm = 2.2;

eps_mm = 0.05;   // overlap for watertight unions/differences
$fn = 128;

// Visual thread approximation (kept subtle so orthographic side views show profile)
thread_pitch_mm = 0.7;
thread_depth_mm = 0.18;        // reduced so it doesn't dominate silhouette
thread_start_clear_mm = 0.45;  // unthreaded under head
thread_end_clear_mm = 0.35;    // unthreaded at tip

// Pan head shaping (must sum to head_height_mm)
head_crown_h_mm = 0.75;        // rounded top portion height
head_fillet_h_mm = 0.30;       // under-head fillet height

// Drive recess (Phillips-like cross) - ensure visible in top view
drive_depth_mm = 1.25;
drive_radius_mm = 1.75;
drive_slot_w_mm = 0.75;

module helical_thread(major_r, minor_r, pitch, h, starts=1) {
    // Helical ridge by twisting a small rectangular profile around Z.
    turns = h / pitch;
    ridge_w = pitch * 0.32;
    ridge_t = max(0.01, major_r - minor_r);

    for (s = [0:starts-1]) {
        rotate([0, 0, s * 360 / starts])
            linear_extrude(height=h, twist=turns * 360, slices=max(24, ceil(turns * 90)))
                translate([minor_r, -ridge_w/2, 0])
                    square([ridge_t, ridge_w], center=false);
    }
}

module pan_head_screw() {
    shaft_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Z layout: tip at z=0, top of head at z=length_mm
    shank_len = length_mm - head_height_mm;
    shank_z0 = 0;
    shank_z1 = shank_len;

    head_z0 = shank_z1;
    head_z1 = length_mm;

    // Thread region
    thread_z0 = shank_z0 + thread_start_clear_mm;
    thread_z1 = shank_z1 - thread_end_clear_mm;
    thread_h  = max(0, thread_z1 - thread_z0);

    major_r = shaft_r + thread_depth_mm;
    minor_r = shaft_r;

    // Head breakdown
    crown_h = min(head_crown_h_mm, head_height_mm - 0.01);
    base_h  = max(0.01, head_height_mm - crown_h);

    // Tip chamfer
    tip_h = 0.7;

    difference() {
        union() {
            // Core shank (exact Ø3.5)
            translate([0, 0, shank_len/2])
                cylinder(h=shank_len, r=minor_r, center=true);

            // Tip chamfer (connected, overlaps slightly into shank)
            translate([0, 0, shank_z0 + tip_h/2 - eps_mm])
                cylinder(h=tip_h, r1=minor_r*0.55, r2=minor_r, center=true);

            // Visual thread ridge (connected to shank)
            if (thread_h > 0)
                translate([0, 0, thread_z0])
                    helical_thread(major_r=major_r, minor_r=minor_r, pitch=thread_pitch_mm, h=thread_h, starts=1);

            // Under-head fillet (connected to both shank and head)
            translate([0, 0, head_z0 + head_fillet_h_mm/2 - eps_mm])
                cylinder(h=head_fillet_h_mm, r1=minor_r, r2=head_r*0.98, center=true);

            // Pan head base (exact Ø6.7, height base_h)
            translate([0, 0, head_z0 + base_h/2])
                cylinder(h=base_h, r=head_r, center=true);

            // Rounded crown (frustum) within remaining head height
            translate([0, 0, head_z0 + base_h + crown_h/2 - eps_mm])
                cylinder(h=crown_h + 2*eps_mm, r1=head_r, r2=head_r*0.78, center=true);
        }

        // Drive recess cut from top (Phillips-like cross + round pocket)
        recess_z_center = head_z1 - drive_depth_mm/2 + eps_mm;

        translate([0, 0, recess_z_center]) {
            cylinder(h=drive_depth_mm + 2*eps_mm, r=drive_radius_mm, center=true);
            cube([2*drive_radius_mm, drive_slot_w_mm, drive_depth_mm + 2*eps_mm], center=true);
            cube([drive_slot_w_mm, 2*drive_radius_mm, drive_depth_mm + 2*eps_mm], center=true);
        }
    }
}

pan_head_screw();