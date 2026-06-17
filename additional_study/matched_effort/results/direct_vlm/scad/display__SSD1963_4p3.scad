$fn = 96;

// Robust rounded rectangle (no offset degeneracy)
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)])
                circle(r = r2);
    }
}

module lcd_display_4p3() {
    // Overall dimensions (mm)
    body_w = 105.5;
    body_h = 67.2;
    body_t = 3.4;

    // Screen window from given coords
    win_x1 = -50;
    win_y1 = -26.5;
    win_x2 =  50;
    win_y2 =  31.5;
    win_r  = 0.5;

    win_w  = win_x2 - win_x1;
    win_h  = win_y2 - win_y1;
    win_cx = (win_x1 + win_x2)/2;
    win_cy = (win_y1 + win_y2)/2;

    // Inner recess from given coords
    rec_x1 = -body_w/2;
    rec_y1 = -65/2 + 1;
    rec_x2 =  body_w/2;
    rec_y2 =  65/2 + 1;
    rec_r  = 1;

    rec_w  = rec_x2 - rec_x1;
    rec_h  = rec_y2 - rec_y1;
    rec_cx = (rec_x1 + rec_x2)/2;
    rec_cy = (rec_y1 + rec_y2)/2;

    // Small feature (slot) from given coords
    slot_x1 = 0;
    slot_y1 = -34.5;
    slot_x2 = 12;
    slot_y2 = -31.5;

    slot_w  = abs(slot_x2 - slot_x1);
    slot_h  = abs(slot_y2 - slot_y1);
    slot_cx = (slot_x1 + slot_x2)/2;
    slot_cy = (slot_y1 + slot_y2)/2;

    // Depths (kept within body thickness)
    // Make recesses clearly visible but not through-cut.
    rec_depth  = min(0.6, body_t - 0.4);
    win_depth  = min(1.0, body_t - 0.4);
    slot_depth = min(0.8, body_t - 0.4);

    // Add a raised bezel ring so the model isn't just a slab.
    bezel_h = min(0.35, body_t * 0.25);
    bezel_r = 1.0;

    // Bezel ring geometry derived from given recess rectangle
    bezel_outer_w = rec_w;
    bezel_outer_h = rec_h;
    bezel_inner_w = win_w + 2*1.2;   // small border around window
    bezel_inner_h = win_h + 2*1.2;
    bezel_inner_r = win_r + 0.6;

    eps = 0.05;

    // ONE connected solid: base + raised bezel, with carved pockets/slot
    color([0.15, 0.15, 0.15])
    difference() {
        union() {
            // Main body centered on Z=0 for reliable viewing
            linear_extrude(height = body_t, center = true)
                rounded_rect_2d(body_w, body_h, 1.0);

            // Raised bezel ring on the front face (connected with slight overlap)
            translate([0, 0, body_t/2 + bezel_h/2 - eps])
                linear_extrude(height = bezel_h, center = true)
                    difference() {
                        rounded_rect_2d(bezel_outer_w, bezel_outer_h, bezel_r);
                        translate([win_cx - rec_cx, win_cy - rec_cy])
                            rounded_rect_2d(bezel_inner_w, bezel_inner_h, bezel_inner_r);
                    }
        }

        // Inner recess (shallow pocket from front face)
        translate([rec_cx, rec_cy, body_t/2 - rec_depth/2 + eps])
            linear_extrude(height = rec_depth + 2*eps, center = true)
                rounded_rect_2d(rec_w, rec_h, rec_r);

        // Screen window pocket (deeper pocket from front face)
        translate([win_cx, win_cy, body_t/2 - win_depth/2 + eps])
            linear_extrude(height = win_depth + 2*eps, center = true)
                rounded_rect_2d(win_w, win_h, win_r);

        // Small slot/feature cut (from front face)
        translate([slot_cx, slot_cy, body_t/2 - slot_depth/2 + eps])
            linear_extrude(height = slot_depth + 2*eps, center = true)
                square([slot_w, slot_h], center = true);
    }
}

lcd_display_4p3();