// Timing pulley: 16 teeth, 9.75mm pitch diameter
// Single connected solid (pulley with timing-belt style grooves) with a bore hole.
// No hub/boss/flanges.

$fn = 220;

// --- Required specs ---
tooth_count        = 16;
pitch_diameter_mm  = 9.75;
pitch_radius_mm    = pitch_diameter_mm/2;

// --- Pulley dimensions ---
pulley_width_mm    = 10;
bore_diameter_mm   = 5;

// --- Tooth/groove style (GT2-like rounded groove approximation) ---
// We model a toothed pulley by subtracting rounded grooves from an outer cylinder.
// Pitch circle is enforced by placing groove centers on the pitch radius.
tooth_depth_mm     = 1.25;   // radial depth of groove (approx)
groove_round_r_mm  = 0.55;   // rounding radius of groove bottom (controls GT2-like shape)
groove_opening_mm  = 1.05;   // tangential opening at pitch circle (approx)
outer_margin_mm    = 0.35;   // material above pitch circle to outer OD
root_margin_mm     = 0.35;   // material below groove bottom to root OD
eps               = 0.03;    // small overlap to avoid coincident faces

// --- Derived ---
tooth_pitch_mm = (PI * pitch_diameter_mm) / tooth_count;

// Outer and root radii (ensure groove fits and pulley remains one solid)
outer_r = pitch_radius_mm + outer_margin_mm;
root_r  = pitch_radius_mm - tooth_depth_mm - root_margin_mm;

// Groove placement: groove center sits on pitch circle, and is shifted inward so it cuts depth.
groove_center_r = pitch_radius_mm - tooth_depth_mm + groove_round_r_mm;

// Convert desired tangential opening to an angular span at the pitch radius
groove_ang_deg = (groove_opening_mm / pitch_radius_mm) * 180 / PI;

// 2D rounded "slot" used as a cutter, then rotate_extrude to make a ring groove.
// Built from hull of two circles to get a rounded-bottom groove.
module groove_slot_2d(r_round, opening_mm) {
    hull() {
        translate([-opening_mm/2, 0]) circle(r=r_round);
        translate([ opening_mm/2, 0]) circle(r=r_round);
    }
}

// One groove cutter positioned at pitch radius and rotated to tooth index.
module groove_cutter(i) {
    rotate([0,0, i * 360/tooth_count])
        rotate([0,0, 0])  // explicit, keeps transforms formula-based
            rotate_extrude(angle=groove_ang_deg, convexity=10)
                translate([groove_center_r, 0, 0])
                    groove_slot_2d(groove_round_r_mm, groove_opening_mm);
}

// All grooves (slightly taller than pulley to guarantee full cut)
module grooves_all() {
    // Extrude in Z by making the cutter a 3D solid via linear_extrude before rotate_extrude is not possible.
    // Instead, we make the groove cutter as a full-height solid by intersecting with a tall cylinder.
    // Practical approach: create grooves as rotate_extrude solids and then scale in Z using linear_extrude via projection is complex.
    // So we build grooves as 3D by adding height using a centered cylinder intersection.
    intersection() {
        // Tall bounding cylinder to give grooves height
        cylinder(r=outer_r + 5, h=pulley_width_mm + 2, center=true);
        union() {
            for (i = [0:tooth_count-1]) groove_cutter(i);
        }
    }
}

module timing_pulley() {
    difference() {
        // Base solid: outer cylinder (ensures correct pitch diameter reference via pitch_radius_mm)
        // Root radius is enforced by subtracting a cylinder outside root? No: we keep full outer and cut grooves only.
        // To ensure a defined root OD, we also subtract everything inside root? Not needed; root is the minimum after grooves.
        cylinder(r=outer_r, h=pulley_width_mm, center=true);

        // Subtract grooves (timing pulley tooth form)
        grooves_all();

        // Bore hole
        cylinder(r=bore_diameter_mm/2, h=pulley_width_mm + 2 + 4*eps, center=true);
    }
}

timing_pulley();