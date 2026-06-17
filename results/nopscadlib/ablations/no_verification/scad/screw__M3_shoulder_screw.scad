// Screw: 4.0mm shaft diameter, 7.0mm head diameter, 2.4mm head height, 10mm overall length
$fn = 128;

// Parameters (mm)
shaft_diameter_mm = 4.0;
length_mm         = 10.0;
head_diameter_mm  = 7.0;
head_height_mm    = 2.4;

// Small overlap to guarantee a single connected solid
overlap_mm = 0.2;

// Thread (visual) parameters (kept within 4.0mm major diameter)
thread_pitch_mm   = 1.0;   // visual pitch
thread_depth_mm   = 0.35;  // radial depth (major radius stays at 2.0mm)
thread_starts     = 1;

// Drive (Phillips-like cross) parameters
drive_depth_mm    = 1.2;   // cut depth into head
drive_arm_w_mm    = 1.2;   // width of each slot arm
drive_arm_l_mm    = 5.2;   // length of each slot arm (fits within 7mm head)
drive_clear_mm    = 0.15;  // small clearance so the cut is clean

// Derived
shaft_len_mm = length_mm - head_height_mm;
shaft_r_mm   = shaft_diameter_mm / 2;
head_r_mm    = head_diameter_mm / 2;

module helical_thread_visual(major_r, depth, pitch, len, starts=1) {
    // Creates a shallow helical ridge that stays within major_r
    // Ridge cross-section is a small rectangle placed near the surface.
    ridge_h = pitch * 0.55;
    ridge_w = depth;

    union() {
        for (s = [0:starts-1]) {
            rotate([0,0, s*360/starts])
                linear_extrude(height=len, twist=-(360*len/pitch), slices=max(24, ceil(len*24/pitch)))
                    translate([major_r - ridge_w/2, 0, 0])
                        square([ridge_w, ridge_h], center=true);
        }
    }
}

module screw() {
    difference() {
        union() {
            // Shaft core (minor diameter)
            translate([0, 0, shaft_len_mm/2])
                cylinder(d=shaft_diameter_mm - 2*thread_depth_mm, h=shaft_len_mm + overlap_mm, center=true);

            // Thread ridge (visual)
            translate([0, 0, 0])
                helical_thread_visual(major_r=shaft_r_mm, depth=thread_depth_mm, pitch=thread_pitch_mm, len=shaft_len_mm, starts=thread_starts);

            // Slight tip chamfer (still within 4mm major)
            tip_h = min(1.0, shaft_len_mm*0.25);
            translate([0, 0, tip_h/2])
                cylinder(h=tip_h + overlap_mm, r1=shaft_r_mm - thread_depth_mm, r2=shaft_r_mm - thread_depth_mm - 0.6, center=true);

            // Head
            translate([0, 0, shaft_len_mm + head_height_mm/2])
                cylinder(d=head_diameter_mm, h=head_height_mm + overlap_mm, center=true);

            // Small under-head fillet/cone to look more like a screw and ensure connection
            fillet_h = 0.6;
            translate([0, 0, shaft_len_mm - fillet_h/2 + overlap_mm/2])
                cylinder(h=fillet_h + overlap_mm, r1=shaft_r_mm, r2=head_r_mm, center=true);
        }

        // Phillips-like cross recess in head
        translate([0, 0, shaft_len_mm + head_height_mm - drive_depth_mm/2 + overlap_mm/2])
            union() {
                for (a = [0, 90]) {
                    rotate([0, 0, a])
                        cube([drive_arm_l_mm + drive_clear_mm, drive_arm_w_mm + drive_clear_mm, drive_depth_mm + overlap_mm],
                             center=true);
                }
            }
    }
}

screw();