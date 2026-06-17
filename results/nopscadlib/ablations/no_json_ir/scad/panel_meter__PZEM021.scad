$fn = 64;

// Peacefair PZEM-021 (approximate) panel meter solid model
// Coordinate system: X=width, Y=height, Z=depth (front at Z=0, rear negative)

// -------------------- Parameters --------------------
meter_w = 72;
meter_h = 36;
meter_d = 60;

// Front bezel
bezel_t = 2.2;
bezel_over = 3.0;          // bezel overhang beyond body on all sides
bezel_r = 1.2;             // bezel corner radius

// Body (insert) with slight draft/rounding
body_r = 0.8;

// Display window recess (not a cut-through)
win_w = 50;
win_h = 18;
win_margin_top = 6;        // from top edge of body opening area
win_recess = 1.2;

// Button (front face)
btn_d = 6.0;
btn_h = 1.6;
btn_y_from_bottom = 7.0;   // from bottom edge of body opening area

// Rear terminal block (typical)
term_w = 30;
term_h = 12;
term_d = 14;
term_inset_from_bottom = 4; // from bottom of body
term_inset_from_rear = 0;   // flush to rear face

// Mounting clips (side spring clips)
clip_w = 10;
clip_h = 14;
clip_t = 2.2;
clip_z_pos = 22;           // distance from front along depth where clips sit
clip_y_center = 0;         // centered vertically
clip_overlap = 1.0;        // overlap into body for connectivity

// Small rear strain relief / bump (centered)
bump_d = 6;
bump_h = 2.5;

// Panel lip / step (front face detail)
lip_inset = 1.2;
lip_depth = 0.8;

// Connectivity overlap (1-2mm) to guarantee unions
conn_ov = 1.2;

// -------------------- Helpers --------------------
module rrect(size=[10,10,10], r=1, center=false) {
    // Rounded rectangle prism via hull of cylinders
    sx = size[0]; sy = size[1]; sz = size[2];
    rr = min(r, min(sx, sy)/2);
    translate(center ? [-sx/2, -sy/2, -sz/2] : [0,0,0])
        hull() {
            for (ix = [rr, sx-rr])
                for (iy = [rr, sy-rr])
                    translate([ix, iy, 0]) cylinder(r=rr, h=sz);
        }
}

module panel_meter() {
    // Build as one connected solid: union of all positive geometry,
    // then subtract recesses (window + lip step).
    difference() {
        union() {
            // Main body (insert) behind bezel: front at Z=0, rear at Z=-meter_d
            translate([0, 0, -meter_d])
                rrect([meter_w, meter_h, meter_d], r=body_r, center=false);

            // Front bezel plate (overhangs body)
            // Ensure it slightly overlaps into the body so it is guaranteed connected.
            translate([-bezel_over, -bezel_over, -conn_ov])
                rrect([meter_w + 2*bezel_over, meter_h + 2*bezel_over, bezel_t + conn_ov], r=bezel_r, center=false);

            // Side mounting clips (left/right), connected with overlap into body
            clip_z = -clip_z_pos;
            clip_y = (meter_h/2) - (clip_h/2) + clip_y_center;

            // Left clip (overlaps into body by clip_overlap)
            translate([-clip_t + clip_overlap, clip_y, clip_z - clip_t/2])
                rrect([clip_t, clip_h, clip_w], r=0.6, center=false);

            // Right clip (overlaps into body by clip_overlap)
            translate([meter_w - clip_overlap, clip_y, clip_z - clip_t/2])
                rrect([clip_t, clip_h, clip_w], r=0.6, center=false);

            // Rear terminal block (connected to rear face with slight overlap)
            term_z0 = -meter_d - term_inset_from_rear; // rear face plane
            translate([(meter_w - term_w)/2, term_inset_from_bottom, term_z0 - term_d + conn_ov])
                rrect([term_w, term_h, term_d], r=0.8, center=false);

            // Rear center bump/strain relief (connected to rear face)
            translate([meter_w/2, meter_h/2, -meter_d - bump_h + conn_ov])
                cylinder(d=bump_d, h=bump_h, center=false);

            // Front button (blue circular feature) - FIXED:
            // Center it on the front face and embed it into the bezel by 1-2mm.
            // This guarantees it is not floating/offset and is physically attached.
            btn_x = meter_w/2;
            btn_y = btn_y_from_bottom;
            translate([btn_x, btn_y, -conn_ov])
                cylinder(d=btn_d, h=btn_h + conn_ov, center=false);
        }

        // Display window recess on bezel/front (not through)
        // Positioned near top, centered in X.
        win_x0 = (meter_w - win_w)/2;
        win_y0 = meter_h - win_margin_top - win_h;
        translate([win_x0, win_y0, bezel_t - win_recess + 0.01])
            rrect([win_w, win_h, win_recess + 0.2], r=1.0, center=false);

        // Front lip step (subtle inset rectangle) to give face definition
        translate([lip_inset, lip_inset, 0.01])
            rrect([meter_w - 2*lip_inset, meter_h - 2*lip_inset, lip_depth], r=1.0, center=false);
    }
}

panel_meter();