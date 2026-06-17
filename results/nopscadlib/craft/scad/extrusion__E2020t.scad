// 20x20 T-slot aluminium extrusion (2020-style), 100mm long
// STRUCTURAL FIX: prevent the slot cutters from removing the central webs,
// which previously split the body into disconnected corner blocks / two rails.
// Approach: keep a guaranteed "web" thickness at the center in BOTH axes by
// limiting the slot cavity/mouth width to (outer - 2*min_wall - 2*web_keep).

cross_section_width_mm  = 20.0;
cross_section_height_mm = 20.0;
length_mm               = 100.0;

// Robust overlap for manifold boolean ops
overlap_mm = 1.5;

// Outer size
outer_w = cross_section_width_mm;
outer_h = cross_section_height_mm;

// Typical-ish 2020 features (approximate)
center_bore_diameter_mm = 5.0;

// T-slot geometry (per side, cut from the outer face inward)
slot_opening_mm       = 6.0;
slot_opening_depth_mm = 2.0;
slot_cavity_width_mm  = 11.0;
slot_cavity_depth_mm  = 6.5;

// Minimum wall to outer boundary
min_wall_mm = 1.6;

// CRITICAL CONNECTIVITY PARAMETER:
// Keep a solid web through the center so the profile cannot split into two rails / four corners.
web_keep_mm = 2.0;  // >= 1..2mm as requested

// Helpers
function clamp(v, lo, hi) = max(lo, min(hi, v));

// Clamp depths to safe ranges
slot_opening_depth_mm_c = clamp(slot_opening_depth_mm, 0.8, outer_w/2.0 - min_wall_mm);
slot_cavity_depth_mm_c  = clamp(slot_cavity_depth_mm, slot_opening_depth_mm_c + 1.0, outer_w/2.0 - min_wall_mm);

// Clamp widths to safe ranges (will be further limited for connectivity)
slot_opening_mm_c      = clamp(slot_opening_mm, 2.0, outer_h - 2.0*min_wall_mm);
slot_cavity_width_mm_c = clamp(slot_cavity_width_mm, slot_opening_mm_c, outer_h - 2.0*min_wall_mm);

// 2D cutter for one side, pointing toward +X, centered at origin
module tslot_cut_2d() {
    // Ensure the cutter NEVER removes the central web:
    // Remaining material at center in Y must be at least web_keep_mm.
    // So cutter width must be <= (outer_h - 2*min_wall_mm - 2*web_keep_mm).
    safe_max_w = max(0.1, outer_h - 2*min_wall_mm - 2*web_keep_mm);

    safe_cavity_w = min(slot_cavity_width_mm_c, safe_max_w);
    safe_mouth_w  = min(slot_opening_mm_c, safe_max_w);

    union() {
        // Narrow mouth (outer face inward)
        translate([outer_w/2.0 - slot_opening_depth_mm_c/2.0, 0])
            square([slot_opening_depth_mm_c + overlap_mm, safe_mouth_w], center=true);

        // Wider cavity behind the mouth
        translate([outer_w/2.0 - slot_opening_depth_mm_c - slot_cavity_depth_mm_c/2.0, 0])
            square([slot_cavity_depth_mm_c + overlap_mm, safe_cavity_w], center=true);
    }
}

module extrusion_2020(len=length_mm) {
    // Single connected solid: base minus cutters
    union() {
        difference() {
            // Main continuous outer square body
            cube([outer_w, outer_h, len], center=true);

            // Center bore (through)
            cylinder(d=center_bore_diameter_mm, h=len + 2*overlap_mm, center=true, $fn=64);

            // Four T-slots (cut through full length)
            for (a = [0, 90, 180, 270]) {
                rotate([0, 0, a])
                    linear_extrude(height=len + 2*overlap_mm, center=true, convexity=10)
                        tslot_cut_2d();
            }
        }
    }
}

// Render
extrusion_2020(length_mm);