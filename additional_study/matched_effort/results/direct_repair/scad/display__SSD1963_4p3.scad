$fn = 64;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

module lcd_display_4p3() {
    // Dimensions (mm)
    body_w = 105.5;
    body_h = 67.2;
    body_t = 3.4;

    // Screen window (approx from given coords)
    // [[-50, -26.5], [50, 31.5, 0.5]]
    win_x1 = -50;
    win_y1 = -26.5;
    win_x2 =  50;
    win_y2 =  31.5;
    win_r  =  0.5;

    win_w = win_x2 - win_x1;
    win_h = win_y2 - win_y1;
    win_cx = (win_x1 + win_x2)/2;
    win_cy = (win_y1 + win_y2)/2;

    // Inner recess / back feature (approx from given coords)
    // [[-105.5 / 2, -65 / 2 + 1], [105.5 / 2, 65 / 2 + 1, 1]]
    recess_x1 = -body_w/2;
    recess_y1 = -65/2 + 1;
    recess_x2 =  body_w/2;
    recess_y2 =  65/2 + 1;
    recess_r  =  1;

    recess_w = recess_x2 - recess_x1;
    recess_h = recess_y2 - recess_y1;
    recess_cx = (recess_x1 + recess_x2)/2;
    recess_cy = (recess_y1 + recess_y2)/2;

    // Small bottom feature (approx from given coords)
    // [[0, -34.5], [12, -31.5]]
    tab_x1 = 0;
    tab_y1 = -34.5;
    tab_x2 = 12;
    tab_y2 = -31.5;

    tab_w = abs(tab_x2 - tab_x1);
    tab_h = abs(tab_y2 - tab_y1);
    tab_cx = (tab_x1 + tab_x2)/2;
    tab_cy = (tab_y1 + tab_y2)/2;

    difference() {
        // Main body
        color([0.15,0.15,0.15])
        linear_extrude(height=body_t)
            rounded_rect_2d(body_w, body_h, 1.0);

        // Front screen window cut (shallow)
        translate([win_cx, win_cy, body_t - 0.8])
            linear_extrude(height=1.0)
                rounded_rect_2d(win_w, win_h, win_r);

        // Back recess (deeper pocket from bottom)
        translate([recess_cx, recess_cy, 0])
            linear_extrude(height=1.2)
                rounded_rect_2d(recess_w, recess_h, recess_r);

        // Small bottom notch/feature (through cut)
        translate([tab_cx, tab_cy, 0])
            linear_extrude(height=body_t + 0.2)
                square([tab_w, tab_h], center=true);
    }

    // Add a "glass" plate in the window area
    color([0.05,0.1,0.12,0.6])
    translate([win_cx, win_cy, body_t - 0.6])
        linear_extrude(height=0.5)
            rounded_rect_2d(win_w - 0.6, win_h - 0.6, max(0, win_r - 0.2));
}

translate([0,0,0]) lcd_display_4p3();