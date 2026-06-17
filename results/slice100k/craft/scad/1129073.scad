$fn = 96;

// Target bounding box (X x Y x Z): 7.8 x 24.5 x 4.5 mm
L = 24.5;          // overall length (Y)
W = 7.8;           // overall width  (X)
H = 4.5;           // overall height (Z)

// End tapers (double-pointed)
tip_len = 4.6;                 // length of each pointed end along Y
mid_len = L - 2*tip_len;
tip_w   = 3.2;                 // width at very tip (X)
tip_h   = 3.2;                 // height at very tip (Z)

// Faceting / chamfers (make outer body clearly non-prismatic)
chamfer_x = 0.9;               // side chamfer amount (in X)
chamfer_z = 0.7;               // top/bottom chamfer amount (in Z)

// Through-slot (obround / closed-loop opening)
slot_L = 18.5;                 // overall slot length (Y)
slot_W = 3.6;                  // slot width (X)

// Side notches (two shallow rectangular notches near mid-length)
notch_L = 3.2;                 // along Y
notch_D = 0.7;                 // depth into side (along X)
notch_H = 1.6;                 // notch height (along Z)
notch_y = 0;                   // centered at mid-length

// Small top flat/mark (kept subtle)
mark_flat_W = 1.2;
mark_flat_L = 2.0;
mark_flat_D = 0.25;
mark_flat_offset_y = 0;

// Robust boolean overlap
eps = 0.02;

// ---------- Helpers ----------
module obround_2d(len, wid) {
    r = wid/2;
    hull() {
        translate([0,  len/2 - r]) circle(r=r);
        translate([0, -len/2 + r]) circle(r=r);
    }
}

module slot_3d() {
    // Extrude along Z; 2D is in XY with length along Y and width along X
    linear_extrude(height=H + 2*eps, center=true)
        obround_2d(slot_L, slot_W);
}

module faceted_section(xw, yh, zh) {
    // Faceted/chamfered prism via hull of 3 rectangles:
    // - full size at mid Z
    // - reduced in X at top/bottom (side chamfers)
    // - reduced in Z at left/right (top/bottom chamfers)
    // This yields clearly angled outer faces without changing the bounding box.
    hull() {
        // Mid plane: full
        cube([xw, yh, eps], center=true);

        // Top & bottom: reduced X (side chamfers)
        translate([0, 0,  zh/2 - eps/2])
            cube([max(0.01, xw - 2*chamfer_x), yh, eps], center=true);
        translate([0, 0, -zh/2 + eps/2])
            cube([max(0.01, xw - 2*chamfer_x), yh, eps], center=true);

        // Left & right: reduced Z (top/bottom chamfers)
        translate([ xw/2 - eps/2, 0, 0])
            cube([eps, yh, max(0.01, zh - 2*chamfer_z)], center=true);
        translate([-xw/2 + eps/2, 0, 0])
            cube([eps, yh, max(0.01, zh - 2*chamfer_z)], center=true);
    }
}

module outer_spindle() {
    // Faceted spindle: hull of three faceted cross-sections (mid + two tips)
    hull() {
        // Mid body (full W,H)
        faceted_section(W, mid_len, H);

        // Front tip (reduced W,H)
        translate([0,  mid_len/2 + tip_len/2, 0])
            faceted_section(tip_w, tip_len, tip_h);

        // Back tip (reduced W,H)
        translate([0, -(mid_len/2 + tip_len/2), 0])
            faceted_section(tip_w, tip_len, tip_h);
    }
}

module side_notches() {
    // Cut into left/right sides; ensure they intersect the outer body
    // and are visible in orthographic views.
    for (sx = [-1, 1]) {
        translate([ sx*(W/2 - notch_D/2 + eps), notch_y, 0])
            cube([notch_D + 2*eps, notch_L, notch_H], center=true);
    }
}

module top_mark_flat() {
    translate([0, mark_flat_offset_y, H/2 - mark_flat_D/2 + eps])
        cube([mark_flat_W, mark_flat_L, mark_flat_D + 2*eps], center=true);
}

// ---------- Final model ----------
difference() {
    outer_spindle();
    slot_3d();
    side_notches();
    top_mark_flat();
}