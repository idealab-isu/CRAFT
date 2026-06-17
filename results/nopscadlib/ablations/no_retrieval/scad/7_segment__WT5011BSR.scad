// Simplified 7-segment display body with CLEAR recessed segment windows + optional decimal point + pins
// Target overall size (bounding box): [12.7, 19, 8.2]  (X, Y, Z)
// One connected solid (pins overlap into body; windows are cutouts)

$fn = 64;

// ---------------- Parameters ----------------
body_W = 12.7;   // X
body_H = 19;     // Y
body_D = 8.2;    // Z

// Robust overlap for booleans + connectivity (1-2mm requested)
overlap = 1.2;

// Front recess / bezel
bezel_thk = 0.8;
bezel_margin = 0.9;

// Segment window geometry (cutouts) - tuned to be recognizable at this small size
seg_depth = 1.6;     // depth of segment recess
seg_thk   = 1.8;     // stroke thickness in XY
seg_end   = 0.7;     // rounding at ends
seg_gap   = 0.7;     // spacing between segments and margins

// Decimal point window (cutout)
dp_enable = true;
dp_radius = 0.85;
dp_depth  = 1.6;

// Pins (2 pins, connected to body by overlap)
pin_radius = 0.7;
pin_len    = 2.5;
pin_pitchX = 6.8;    // distance between pins in X (kept within body width)
pin_inset_Y = 2.2;   // from bottom edge in Y

// ---------------- Helpers ----------------
module rounded_bar_2d(L, T, r) {
    r2 = min(r, T/2);
    hull() {
        translate([-L/2 + r2, 0]) circle(r=r2);
        translate([ L/2 - r2, 0]) circle(r=r2);
    }
}

module seg_window_h(L, T, depth) {
    linear_extrude(height=depth, center=true)
        rounded_bar_2d(L, T, seg_end);
}

module seg_window_v(L, T, depth) {
    rotate([0,0,90]) seg_window_h(L, T, depth);
}

// ---------------- Main solid ----------------
module main_body() {
    cube([body_W, body_H, body_D], center=true);
}

module pins_union() {
    // Place pins on bottom face (Z-), overlapping into body by "overlap"
    // Ensures pins touch/merge with body (no floating)
    z_pin = -body_D/2 - pin_len/2 + overlap;

    // Two pins centered in Y near bottom edge; symmetric in X
    y_pin = -body_H/2 + pin_inset_Y;

    union() {
        translate([-pin_pitchX/2, y_pin, z_pin])
            cylinder(r=pin_radius, h=pin_len, center=true);
        translate([ pin_pitchX/2, y_pin, z_pin])
            cylinder(r=pin_radius, h=pin_len, center=true);
    }
}

// ---------------- Cutouts ----------------
module front_recess_cutout() {
    // Shallow recess on the front face to suggest bezel area
    // Cutout is guaranteed to intersect the body by overlap
    z_recess = body_D/2 - bezel_thk/2; // centered within the front skin
    translate([0, 0, z_recess])
        cube([body_W - 2*bezel_margin, body_H - 2*bezel_margin, bezel_thk + overlap], center=true);
}

module segments_cutouts() {
    // Active area for segments (inside bezel)
    inner_W = body_W - 2*bezel_margin;
    inner_H = body_H - 2*bezel_margin;

    // Keep within inner area and ensure a recognizable 7-seg silhouette
    // Horizontal segments length: leave room for vertical strokes + gaps
    h_len = max(0.1, inner_W - 2*(seg_thk + seg_gap*1.2));

    // Vertical segments length: upper/lower halves with a center gap around middle segment
    // Allocate: top seg_thk + mid seg_thk + bottom seg_thk + 4 gaps + 2*v_len = inner_H
    v_len = max(0.1, (inner_H - 3*seg_thk - 4*seg_gap) / 2);

    // Cut into the front face (Z+). Center the cut volume so it intersects the front face.
    z_cut = body_D/2 - seg_depth/2;

    // Horizontal segment Y positions (a, g, d)
    y_top =  inner_H/2 - seg_thk/2 - seg_gap;
    y_mid =  0;
    y_bot = -inner_H/2 + seg_thk/2 + seg_gap;

    // Vertical segment X positions (f/e on left, b/c on right)
    x_left  = -inner_W/2 + seg_thk/2 + seg_gap;
    x_right =  inner_W/2 - seg_thk/2 - seg_gap;

    // Vertical segment Y positions (upper: f/b, lower: e/c)
    y_upper =  (seg_thk/2 + seg_gap) + v_len/2;
    y_lower = -(seg_thk/2 + seg_gap) - v_len/2;

    union() {
        // a, g, d
        translate([0, y_top, z_cut]) seg_window_h(h_len, seg_thk, seg_depth + overlap);
        translate([0, y_mid, z_cut]) seg_window_h(h_len, seg_thk, seg_depth + overlap);
        translate([0, y_bot, z_cut]) seg_window_h(h_len, seg_thk, seg_depth + overlap);

        // f, b, e, c
        translate([x_left,  y_upper, z_cut]) seg_window_v(v_len, seg_thk, seg_depth + overlap);
        translate([x_right, y_upper, z_cut]) seg_window_v(v_len, seg_thk, seg_depth + overlap);
        translate([x_left,  y_lower, z_cut]) seg_window_v(v_len, seg_thk, seg_depth + overlap);
        translate([x_right, y_lower, z_cut]) seg_window_v(v_len, seg_thk, seg_depth + overlap);

        // Decimal point (bottom-right)
        if (dp_enable) {
            dp_x = inner_W/2 - dp_radius - seg_gap;
            dp_y = -inner_H/2 + dp_radius + seg_gap;
            translate([dp_x, dp_y, body_D/2 - dp_depth/2])
                cylinder(r=dp_radius, h=dp_depth + overlap, center=true);
        }
    }
}

// ---------------- Final model ----------------
module display_digit() {
    // Single connected solid: body + pins, with segment recesses cut into front
    difference() {
        union() {
            main_body();
            pins_union();
        }
        front_recess_cutout();
        segments_cutouts();
    }
}

display_digit();