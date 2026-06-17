// Pan head screw (single connected solid)
// Target: shank Ø2.5, length under head 10, head Ø4.7, head height 1.7

$fn = 96;

// Parameters (mm)
shank_diameter_mm      = 2.5;  //[1.25:5:0.05]
length_under_head_mm   = 10;   //[5:20:0.1]
head_diameter_mm       = 4.7;  //[2.35:9.4:0.05]
head_height_mm         = 1.7;  //[0.85:3.4:0.05]

// Thread (visual approximation)
thread_pitch_mm        = 0.45; //[0.3:0.8:0.01]
thread_depth_mm        = 0.18; //[0.05:0.35:0.01]
thread_start_taper_mm  = 1.0;  //[0:3:0.1]

// Tip
tip_chamfer_height_mm  = 0.6;  //[0:2:0.1]

// Drive recess (Phillips-like cross, optional)
drive_recess_depth_mm  = 0.6;  //[0:1.2:0.05]
drive_recess_width_mm  = 0.7;  //[0.3:1.2:0.05]

// Small overlap to ensure watertight unions/differences
overlap_mm             = 0.05; //[0.01:0.2:0.01]

// ---------- Helpers ----------
module thread_ridge(len, pitch, r_base, depth, start_taper=0) {
    // Creates a helical "ridge" that is unioned onto the shank.
    // r_base is the shank radius; ridge extends outward by depth.
    turns = len / pitch;
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
        translate([r_base, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);

    // Optional start taper (blends ridge in near the tip)
    if (start_taper > 0) {
        // Remove ridge near the tip with a cone-shaped cutter
        difference() {
            // nothing (used by caller via difference if needed)
        }
    }
}

module pan_head_solid(head_d, head_h) {
    // Pan head: cylindrical skirt + low dome
    r = head_d/2;
    skirt_h = head_h * 0.55;
    dome_h  = head_h - skirt_h;

    union() {
        // Skirt
        cylinder(h=skirt_h, r=r, center=false);

        // Dome (spherical cap approximation via scaled sphere)
        translate([0,0,skirt_h])
            intersection() {
                // Scaled sphere to get a gentle dome
                scale([1,1, dome_h/(r*0.75)])
                    sphere(r=r*0.75);
                // Keep only the upper cap of height dome_h
                translate([0,0,0])
                    cylinder(h=dome_h, r=r+overlap_mm, center=false);
            }
    }
}

module phillips_like_recess(depth, width, head_r) {
    // Simple cross recess (not a hex). Subtracted from head.
    // width is arm thickness; depth is recess depth.
    arm_len = head_r * 1.2;
    translate([0,0,-overlap_mm])  // ensure clean subtraction from top
    union() {
        cube([arm_len, width, depth + 2*overlap_mm], center=true);
        cube([width, arm_len, depth + 2*overlap_mm], center=true);
    }
}

// ---------- Main screw ----------
module pan_head_screw() {
    shank_r = shank_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Coordinate system:
    // z=0 at underside of head (bearing surface)
    // shank extends to negative z
    // head extends to positive z

    difference() {
        union() {
            // Shank core (minor diameter)
            translate([0,0,-length_under_head_mm])
                cylinder(h=length_under_head_mm, r=shank_r, center=false);

            // Threads (visual)
            // Add a helical ridge along most of the shank, leaving a small unthreaded zone near head
            thread_len = max(length_under_head_mm - 0.6, 0);
            if (thread_len > 0) {
                translate([0,0,-thread_len])
                    thread_ridge(thread_len, thread_pitch_mm, shank_r, thread_depth_mm);
            }

            // Tip chamfer
            if (tip_chamfer_height_mm > 0) {
                translate([0,0,-length_under_head_mm - overlap_mm])
                    cylinder(h=tip_chamfer_height_mm + overlap_mm,
                             r1=shank_r + thread_depth_mm,
                             r2=0,
                             center=false);
            }

            // Pan head (connected to shank at z=0)
            pan_head_solid(head_diameter_mm, head_height_mm);
        }

        // Drive recess (subtracted from top of head)
        if (drive_recess_depth_mm > 0) {
            translate([0,0,head_height_mm - drive_recess_depth_mm])
                phillips_like_recess(drive_recess_depth_mm, drive_recess_width_mm, head_r);
        }
    }
}

pan_head_screw();