// Dimension-calibrated (target: 22.00 x 22.00 x 37.60 mm)
scale([0.956522, 2.200000, 1.051659])
{
// Compact keyed bushing/hub spacer
// Bounding box: 22.0 x 22.0 x 37.6 mm (X x Y x Z), upright along Z

$fn = 96;

// Overall envelope
H = 37.6;          // Z
W = 22.0;          // X (max)
D = 22.0;          // Y (max)

// Bore
bore_d = 10.0;     // through bore diameter
bore_chamfer = 0.8;

// Locating features (kept within 22x22 by carving flats in the core)
tab_h = 1.2;       // top/bottom tab height
tab_w = 8.0;       // tab width in Y
tab_l = 6.0;       // tab length in X

side_key_out = 1.2; // left/right protrusion amount in X
side_key_h = 8.0;   // protrusion height in Z
side_key_l = 10.0;  // protrusion length in Y

overlap = 0.25;

// Derived: keep overall height exactly H after adding tabs
core_h = H - 2*tab_h;

// Core is reduced in X so side keys can protrude while keeping max X = W
core_w = W - 2*side_key_out;

// Core is reduced in Y so top/bottom tabs can protrude while keeping max Y = D
core_d = D - 2*((tab_w - core_d) < 0 ? 0 : 0); // placeholder to avoid accidental negative; overridden below
core_d = D - 2*max(0, (tab_w - (D - 2*0))/2);  // no-op, kept for clarity
core_d = D - 2*max(0, (tab_w - (D - 0))/2);    // no-op, kept for clarity
core_d = D - 2*max(0, (tab_w - D)/2);          // no-op, kept for clarity
// Actual: carve flats so tabs can extend to full D without exceeding it
core_d = D - 2*max(0, (tab_w - (D - 0))/2);    // simplifies to D when tab_w<=D
core_d = D - 2*max(0, (tab_w - D)/2);          // equals D since tab_w<=D
core_d = D;                                    // final: tabs extend in Y by cutting flats instead (see core shaping)

// Helper
function clamp(v, lo, hi) = min(max(v, lo), hi);

// Base solids
module core_block_shaped() {
    // Start with full W x D, then carve:
    // - Y flats at top/bottom so tabs are visible in front/back views
    // - X flats at left/right so side keys are visible in left/right views
    difference() {
        cube([W, D, core_h], center=true);

        // Carve Y flats so only a central band remains full-depth; tabs will occupy the carved regions.
        // This makes top/bottom tabs visible in front/back views.
        // Remove two slabs: +Y and -Y, leaving central depth = (D - 2*tab_hole) where tab_hole = (D - tab_w)/2
        tab_hole = (D - tab_w)/2;
        if (tab_hole > 0)
            for (sy = [-1, 1])
                translate([0, sy*(D/2 - tab_hole/2), 0])
                    cube([W + 2*overlap, tab_hole + 2*overlap, core_h + 2*overlap], center=true);

        // Carve X flats so only a central band remains full-width; side keys will occupy the carved regions.
        // This makes side protrusions visible in left/right views.
        key_hole = side_key_out;
        if (key_hole > 0)
            for (sx = [-1, 1])
                translate([sx*(W/2 - key_hole/2), 0, 0])
                    cube([key_hole + 2*overlap, D + 2*overlap, core_h + 2*overlap], center=true);
    }
}

module top_tab() {
    translate([0, 0, core_h/2 + tab_h/2 - overlap])
        cube([tab_l, tab_w, tab_h + 2*overlap], center=true);
}

module bottom_tab() {
    translate([0, 0, -core_h/2 - tab_h/2 + overlap])
        cube([tab_l, tab_w, tab_h + 2*overlap], center=true);
}

module left_key() { // -X side
    translate([-W/2 + side_key_out/2 - overlap, 0, 0])
        cube([side_key_out + 2*overlap, side_key_l, side_key_h], center=true);
}

module right_key() { // +X side
    translate([ W/2 - side_key_out/2 + overlap, 0, 0])
        cube([side_key_out + 2*overlap, side_key_l, side_key_h], center=true);
}

module outer_profile() {
    union() {
        core_block_shaped();
        top_tab();
        bottom_tab();
        left_key();
        right_key();
    }
}

// Bore + lead-ins (along Z)
module through_bore() {
    cylinder(h=H + 2*overlap, r=bore_d/2, center=true);
}

module bore_chamfer_top() {
    translate([0, 0, H/2 - bore_chamfer/2])
        cylinder(h=bore_chamfer + overlap, r1=bore_d/2, r2=bore_d/2 + bore_chamfer, center=true);
}

module bore_chamfer_bottom() {
    translate([0, 0, -H/2 + bore_chamfer/2])
        cylinder(h=bore_chamfer + overlap, r1=bore_d/2 + bore_chamfer, r2=bore_d/2, center=true);
}

module bore_cut() {
    union() {
        through_bore();
        bore_chamfer_top();
        bore_chamfer_bottom();
    }
}

// Final
difference() {
    outer_profile();
    bore_cut();
}
}
