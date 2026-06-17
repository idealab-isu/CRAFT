// Pan head screw: 2.5mm major thread dia, 4.7mm head dia, 1.7mm head height, 10mm overall length
// One connected solid. Z=0 at top of head.

$fn = 128;

// Parameters (mm)
major_d_mm        = 2.5;   // thread major diameter
length_mm         = 10;    // overall length (top of head to tip)
head_d_mm         = 4.7;
head_h_mm         = 1.7;

// Drive recess (simple Phillips-like cross)
drive_depth_mm       = 0.75;   // <= head_h_mm
drive_slot_width_mm  = 0.55;
drive_slot_length_mm = 3.0;

// Thread parameters (approximate ISO M2.5 coarse)
pitch_mm          = 0.45;
thread_len_mm     = 7.6;   // threaded portion length (below head)
tip_len_mm        = 0.8;   // conical tip length
thread_depth_mm   = 0.18;  // radial depth of thread (approx)
thread_starts     = 1;

// Overlap to guarantee physical attachment (1–2mm as required)
overlap_mm = 1.0;

// Small epsilon for booleans
eps = 0.02;

module helical_thread(major_d, pitch, len, depth, starts=1) {
    // Z=0 at top of threaded section, extends down to -len.
    major_r = major_d/2;
    minor_r = major_r - depth;

    tooth_w = pitch * 0.55;
    tooth_h = depth;

    module one_start() {
        translate([minor_r, 0, 0])
            polygon(points=[
                [0, -tooth_w/2],
                [tooth_h, 0],
                [0,  tooth_w/2]
            ]);
    }

    turns = len / pitch;
    twist_deg = -360 * turns;

    union() {
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(height=len, twist=twist_deg,
                               slices=max(ceil(turns*40), 80), convexity=10)
                    one_start();
        }
    }
}

module pan_head_profile(head_r, head_h) {
    top_round_h = head_h * 0.35;
    skirt_h     = head_h - top_round_h;
    top_r_inset = head_r * 0.10;

    rotate_extrude(convexity=10)
        polygon(points=[
            [0,        -head_h],
            [head_r,   -head_h],
            [head_r,   -top_round_h],
            [head_r,   -top_round_h*0.35],
            [head_r*(1-top_r_inset), 0],
            [0,         0]
        ]);
}

module pan_head_screw() {
    major_r = major_d_mm/2;
    head_r  = head_d_mm/2;

    head_top_z  = 0;
    head_bot_z  = -head_h_mm;

    shank_len = length_mm - head_h_mm; // length below head underside

    // Ensure we always have a valid threaded length and a connected tip.
    // Also ensure the tip is not "floating" by overlapping it into the threaded core.
    thread_len = min(thread_len_mm, max(0, shank_len - tip_len_mm));
    unthread_len = max(0, shank_len - thread_len - tip_len_mm);

    // Z locations
    z_under_head    = head_bot_z;                       // underside of head
    z_unthread_bot  = z_under_head - unthread_len;      // bottom of unthreaded shank
    z_thread_top    = z_unthread_bot;                   // top of threaded section
    z_thread_bot    = z_thread_top - thread_len;        // bottom of threaded section (start of tip)
    z_tip_top       = z_thread_bot;                     // nominal tip start
    z_tip_bot       = z_tip_top - tip_len_mm;           // tip end (should be -length_mm)

    // Radii
    minor_r = major_r - thread_depth_mm;

    // Overlap used to guarantee attachment between thread and tip
    tip_overlap = min(overlap_mm, max(0.2, tip_len_mm * 0.9)); // keep sensible even for short tips

    difference() {
        union() {
            // Head
            pan_head_profile(head_r, head_h_mm);

            // Under-head fillet / neck (connected to head and shank)
            neck_h = 0.35;
            translate([0,0, z_under_head - neck_h - overlap_mm])
                cylinder(h=neck_h + overlap_mm, r1=head_r*0.92, r2=major_r, center=false);

            // Unthreaded shank (if any) - overlap into neck and into thread
            if (unthread_len > 0)
                translate([0,0, z_under_head - unthread_len - overlap_mm])
                    cylinder(h=unthread_len + overlap_mm, r=major_r - thread_depth_mm*0.35, center=false);

            // Thread core (minor diameter cylinder) - extend slightly past bottom to overlap into tip
            translate([0,0, z_thread_top - thread_len - tip_overlap])
                cylinder(h=thread_len + tip_overlap, r=minor_r, center=false);

            // External helical thread - keep aligned with thread core
            translate([0,0, z_thread_top - thread_len])
                helical_thread(major_d=major_d_mm, pitch=pitch_mm, len=thread_len, depth=thread_depth_mm, starts=thread_starts);

            // Conical tip - start it slightly ABOVE the thread bottom so it intersects the core (no gap)
            // This fixes the floating/disconnected tip by forcing a 1mm overlap.
            translate([0,0, z_tip_top - tip_len_mm + tip_overlap])
                cylinder(h=tip_len_mm, r1=minor_r, r2=0.15, center=false);
        }

        // Cross recess cut from the top (kept within head height)
        recess_depth = min(drive_depth_mm, head_h_mm - 0.1);
        recess_z0 = head_top_z - recess_depth; // bottom of recess
        translate([0,0, recess_z0 - eps]) {
            cube([drive_slot_length_mm, drive_slot_width_mm, recess_depth + 2*eps], center=false);
            translate([-drive_slot_width_mm/2, -drive_slot_length_mm/2, 0])
                cube([drive_slot_width_mm, drive_slot_length_mm, recess_depth + 2*eps], center=false);
        }
    }
}

pan_head_screw();