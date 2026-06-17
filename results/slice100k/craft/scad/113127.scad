// Blocky C-shaped bracket/frame with stepped outer perimeter and inner step transitions
// Target bounding box: 31.8 x 31.8 x 15.8 mm

$fn = 48;

// --- Parameters (mm) ---
outer_x = 31.8;
outer_y = 31.8;
thk     = 15.8;

// Main inner opening (rectangular)
inner_x = 18.0;
inner_y = 20.0;

// C-gap (opens to the bottom edge)
gap_w   = 8.0;

// Outer stepped perimeter (a shallow recess on the top face)
outer_step_depth = 2.0;     // inset from outer edges
outer_step_drop  = 1.2;     // depth of recess from top face

// Inner step transitions (small ledges around inner opening)
inner_step_w    = 1.2;
inner_step_len  = 10.0;
inner_step_drop = 0.8;      // depth of inner ledges from top face

// Boss pads (reinforced pads on top face)
boss_w = 6.0;
boss_l = 6.0;
boss_drop = 0.0;            // 0 => bosses are full thickness (flush); increase to make them top-only

// Robust boolean overlap
eps = 0.05;

// --- Helpers ---
module box_at(x, y, z, sx, sy, sz) {
    translate([x,y,z]) cube([sx,sy,sz], center=true);
}

// --- Core geometry ---
module base_plate() {
    cube([outer_x, outer_y, thk], center=true);
}

// Through openings to create the C-shape
module cut_inner_opening() {
    cube([inner_x, inner_y, thk + 2*eps], center=true);
}

module cut_bottom_gap() {
    // Ensure the gap actually reaches the outer bottom edge and intersects the inner opening.
    // Make it slightly wider in Y than the outer plate so it always cuts through.
    translate([0, -outer_y/2, 0])
        cube([gap_w, outer_y + 2*eps, thk + 2*eps], center=true);
}

// Top-face recess (outer perimeter step)
module cut_outer_top_recess() {
    recess_x = outer_x - 2*outer_step_depth;
    recess_y = outer_y - 2*outer_step_depth;
    recess_h = outer_step_drop;

    translate([0,0, thk/2 - recess_h/2 + eps])
        cube([recess_x, recess_y, recess_h + 2*eps], center=true);
}

// Inner step transitions (small top-face ledges around inner opening)
module cut_inner_step_transitions() {
    h = inner_step_drop;

    // Place these cuts so they nibble into the frame around the opening (not floating).
    // Keep them shallow and on the top face.
    zc = thk/2 - h/2 + eps;

    // Top ledge cut
    translate([0,  inner_y/2 + inner_step_w/2, zc])
        cube([inner_step_len, inner_step_w, h + 2*eps], center=true);

    // Bottom ledge cut (still fine; the C-gap is separate and will open the bottom)
    translate([0, -inner_y/2 - inner_step_w/2, zc])
        cube([inner_step_len, inner_step_w, h + 2*eps], center=true);

    // Left ledge cut
    translate([-inner_x/2 - inner_step_w/2, 0, zc])
        cube([inner_step_w, inner_step_len, h + 2*eps], center=true);

    // Right ledge cut
    translate([ inner_x/2 + inner_step_w/2, 0, zc])
        cube([inner_step_w, inner_step_len, h + 2*eps], center=true);
}

// Boss pads (add material; keep connected by overlapping with base)
module boss_pads() {
    boss_h = (boss_drop <= 0) ? thk : (thk - boss_drop);
    boss_z = (boss_drop <= 0) ? 0 : (boss_drop/2);

    // Corner bosses
    x0 = outer_x/2 - boss_w/2;
    y0 = outer_y/2 - boss_l/2;

    box_at(-x0,  y0, boss_z, boss_w, boss_l, boss_h);
    box_at(-x0, -y0, boss_z, boss_w, boss_l, boss_h);
    box_at( x0,  y0, boss_z, boss_w, boss_l, boss_h);
    box_at( x0, -y0, boss_z, boss_w, boss_l, boss_h);

    // Small mid bosses on left side (reinforced pads near the "legs")
    sm_w = boss_w*0.7;
    sm_l = boss_l*0.5;

    xl = -outer_x/2 + sm_w/2;
    yt =  outer_y/2 - sm_l/2;
    yb = -outer_y/2 + sm_l/2;

    box_at(xl, yt, boss_z, sm_w, sm_l, boss_h);
    box_at(xl, yb, boss_z, sm_w, sm_l, boss_h);
}

// --- Final model ---
module bracket() {
    difference() {
        union() {
            base_plate();
            boss_pads(); // additive, overlaps base => one connected solid
        }

        // Through cuts for C-shape
        cut_inner_opening();
        cut_bottom_gap();

        // Top-face stepped details
        cut_outer_top_recess();
        cut_inner_step_transitions();
    }
}

bracket();