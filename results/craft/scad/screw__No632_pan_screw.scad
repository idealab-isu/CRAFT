// Pan head screw (single connected solid)
// Target dimensions:
// - Shank diameter: 3.5 mm
// - Head diameter: 6.9 mm
// - Head height: 2.5 mm
// - Overall length (under head): 10 mm

$fn = 96;

// Parameters
shank_diameter_mm = 3.5;
head_diameter_mm  = 6.9;
head_height_mm    = 2.5;
length_mm         = 10;

eps_mm     = 0.02;
overlap_mm = 0.15;

// Simple external thread approximation (cosmetic)
thread_pitch_mm   = 0.7;   // typical for ~M3.5
thread_depth_mm   = 0.25;  // radial depth (visual)
thread_start_mm   = 0.6;   // unthreaded near head
thread_end_mm     = 0.6;   // blunt tip allowance

// Pan head shaping
head_top_round_r_mm = 0.9; // rounding radius for top dome
head_underfillet_r  = 0.35;

// Drive (Phillips-like cross recess)
drive_depth_mm = 1.2;
drive_arm_w_mm = 0.9;
drive_arm_l_mm = head_diameter_mm * 0.62;

module helical_thread_visual(major_r, pitch, depth, len) {
    // Creates a shallow helical ridge by twisting a small triangular profile.
    // This is a visual approximation, not a standards-accurate thread.
    turns = len / pitch;
    translate([0,0,0])
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        translate([major_r - depth, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

module pan_head_screw() {
    shank_r = shank_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Coordinate system:
    // z=0 at underside of head; shank extends to negative z.
    union() {
        // Shank core (minor diameter) to allow thread ridge to protrude
        minor_r = max(shank_r - thread_depth_mm, shank_r*0.85);
        translate([0,0,-length_mm/2])
            cylinder(r=minor_r, h=length_mm, center=true);

        // Thread ridge (only on threaded portion)
        thread_len = max(length_mm - thread_start_mm - thread_end_mm, 0);
        if (thread_len > 0)
            translate([0,0,-thread_start_mm - thread_len])
                helical_thread_visual(major_r=shank_r, pitch=thread_pitch_mm, depth=thread_depth_mm, len=thread_len + overlap_mm);

        // Slightly rounded/blunt tip
        translate([0,0,-length_mm])
            sphere(r=minor_r);

        // Pan head: cylindrical base + domed top via hull, with small under-head fillet
        difference() {
            union() {
                // Under-head fillet (small torus-like blend)
                translate([0,0,0])
                    rotate_extrude(convexity=10)
                        translate([head_r - head_underfillet_r, 0, 0])
                            circle(r=head_underfillet_r, $fn=64);

                // Main head body with domed top
                hull() {
                    // Base disk at underside
                    translate([0,0,0 + overlap_mm/2])
                        cylinder(r=head_r, h=eps_mm, center=false);

                    // Upper cylinder section
                    translate([0,0,head_height_mm - head_top_round_r_mm])
                        cylinder(r=head_r, h=eps_mm, center=false);

                    // Dome cap point (sphere) to round the top
                    translate([0,0,head_height_mm - head_top_round_r_mm])
                        sphere(r=head_top_round_r_mm);
                }
            }

            // Cross recess (Phillips-like), centered on head top
            translate([0,0,head_height_mm - drive_depth_mm + eps_mm])
                union() {
                    cube([drive_arm_l_mm, drive_arm_w_mm, drive_depth_mm + 2*eps_mm], center=true);
                    cube([drive_arm_w_mm, drive_arm_l_mm, drive_depth_mm + 2*eps_mm], center=true);
                }
        }

        // Ensure shank and head are fused (overlap)
        translate([0,0,-overlap_mm/2])
            cylinder(r=shank_r, h=overlap_mm, center=true);
    }
}

pan_head_screw();