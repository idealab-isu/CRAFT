// Pan head screw: 3.0mm major diameter, 5.5mm head diameter, 2.0mm head height, 10mm length (under head)

$fn = 128;

// Parameters (mm)
thread_major_diameter_mm = 3.0;
overall_length_mm        = 10.0;   // length under head
head_diameter_mm         = 5.5;
head_height_mm           = 2.0;

// Overlap to ensure one connected solid (REQUIRED: 1–2mm)
overlap_mm = 1.2;

// Thread parameters (visual/approx)
thread_pitch_mm          = 0.50;   // coarse-ish for M3 look
thread_depth_mm          = 0.18;   // radial depth (kept modest for robustness)
thread_start_z_mm        = 0.6;    // unthreaded length under head
thread_end_margin_mm     = 0.8;    // leave a small unthreaded/chamfer region at tip

// Tip chamfer
tip_chamfer_h_mm = 0.6;

// Phillips recess (simple cross)
recess_depth_mm = 0.9;
recess_arm_w_mm = 0.75;
recess_arm_l_mm = 3.6;

module helical_thread(major_d, pitch, depth, length, z0=0) {
    // Creates an external thread by adding a helical ridge around a core cylinder.
    // z0 is the start position (at underside of head, z=0).
    major_r = major_d/2;
    core_r  = major_r - depth;

    turns = length / pitch;

    union() {
        // Core (centered at z0 - length/2 so it spans [z0-length, z0])
        translate([0,0, z0 - length/2])
            cylinder(r=core_r, h=length, center=true);

        // Helical ridge (triangular-ish profile), spans [z0, z0+length]
        // NOTE: We will position z0 so this overlaps the shank and stays under the head.
        translate([0,0,z0])
            linear_extrude(height=length, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
                translate([core_r, 0, 0])
                    polygon(points=[
                        [0, -pitch*0.22],
                        [depth, 0],
                        [0,  pitch*0.22]
                    ]);
    }
}

module pan_head(head_d, head_h) {
    // Pan head: cylindrical side with a gently rounded top (not spherical/domed).
    head_r = head_d/2;

    // Rounded top radius (small, to keep "pan" look)
    top_round_r = min(0.55, head_h*0.35);

    // Ensure the rounded cap fits within head height
    cyl_h = max(head_h - top_round_r, 0.01);

    union() {
        // Cylindrical portion: spans from z=0 down to slightly below for overlap with shank
        translate([0,0, cyl_h/2 - overlap_mm/2])
            cylinder(r=head_r, h=cyl_h + overlap_mm, center=true);

        // Rounded top (quarter-circle profile via rotate_extrude)
        translate([0,0, cyl_h - overlap_mm/2])
            rotate_extrude(convexity=10)
                translate([head_r - top_round_r, 0, 0])
                    circle(r=top_round_r);
    }
}

module phillips_recess(head_h) {
    // Cross recess cut into top face
    z_center = head_h - recess_depth_mm/2;
    translate([0,0,z_center])
        union() {
            cube([recess_arm_l_mm, recess_arm_w_mm, recess_depth_mm], center=true);
            cube([recess_arm_w_mm, recess_arm_l_mm, recess_depth_mm], center=true);
        }
}

module pan_head_screw() {
    major_r = thread_major_diameter_mm/2;
    core_r  = major_r - thread_depth_mm;

    // Coordinate system:
    // underside of head at z=0
    // shank extends down to z=-overall_length_mm

    // Threaded length (under head), leaving small unthreaded regions
    thread_len = max(overall_length_mm - thread_start_z_mm - thread_end_margin_mm, 0.5);

    // Place the helical ridge so it stays under the head and overlaps the unthreaded shank.
    // Ridge spans [thread_ridge_z0, thread_ridge_z0 + thread_len]
    // We want its top to be slightly below z=0 (under head) to avoid floating above the head,
    // and its bottom to be above the tip margin.
    thread_ridge_top_z = -overlap_mm;                 // slightly under head underside
    thread_ridge_z0    = thread_ridge_top_z - thread_len;

    // Unthreaded section under head: spans [0, -thread_start_z_mm]
    // Make it overlap the head and the thread by overlap_mm.
    unthread_h = thread_start_z_mm + overlap_mm*2;
    unthread_center_z = -thread_start_z_mm/2;

    // Tip chamfer: must connect to the end of the shaft at z=-overall_length_mm
    // Make it overlap upward into the shaft by overlap_mm.
    tip_h = tip_chamfer_h_mm + overlap_mm;
    tip_center_z = -overall_length_mm + tip_h/2;      // bottom at -overall_length_mm, top overlaps upward

    difference() {
        union() {
            // Pan head (z from ~0 to +head_height_mm, with slight overlap below z=0)
            pan_head(head_diameter_mm, head_height_mm);

            // Unthreaded shank under head (core diameter), overlaps head and thread
            translate([0,0, unthread_center_z])
                cylinder(r=core_r, h=unthread_h, center=true);

            // Threaded shank (core + helical ridge), positioned fully under head and overlapping unthreaded shank
            helical_thread(
                major_d = thread_major_diameter_mm,
                pitch   = thread_pitch_mm,
                depth   = thread_depth_mm,
                length  = thread_len,
                z0      = thread_ridge_z0
            );

            // Tip chamfer/conical tip, attached to end of shaft with overlap
            translate([0, 0, tip_center_z])
                cylinder(r1=core_r, r2=core_r*0.35, h=tip_h, center=true);

            // Ensure continuous core down to the tip (fills any potential gap between thread core and tip)
            // This guarantees no separation even if thread placement changes.
            core_fill_top_z = -thread_start_z_mm + overlap_mm; // overlaps into unthreaded section
            core_fill_bot_z = -overall_length_mm + tip_chamfer_h_mm; // up to start of chamfer region
            core_fill_h = max(core_fill_top_z - core_fill_bot_z, 0.01);
            translate([0,0, (core_fill_top_z + core_fill_bot_z)/2])
                cylinder(r=core_r, h=core_fill_h + overlap_mm, center=true);
        }

        // Phillips recess on top (kept within head height)
        phillips_recess(head_height_mm);
    }
}

pan_head_screw();