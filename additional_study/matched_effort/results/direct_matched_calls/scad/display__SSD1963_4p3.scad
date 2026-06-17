$fn=64;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    offset(r=r2) offset(delta=-r2) square([w,h], center=true);
}

module lcd_display_4p3(){
    // Overall dimensions
    w = 105.5;
    h = 67.2;
    t = 3.4;

    // Bezel / body
    body_r = 1.2;

    // Screen window (from description: 105.5 x 65, with +1mm y padding on both sides)
    win_w = 105.5;
    win_h = 65 + 2; // 67
    win_r = 0.8;

    // Small feature block (from description: [[0, -34.5], [12, -31.5]])
    // Interpreted as a small rectangular protrusion centered at x=0, spanning y from -34.5 to -31.5
    feat_xc = 0;
    feat_y1 = -34.5;
    feat_y2 = -31.5;
    feat_w  = 12;
    feat_h  = abs(feat_y2 - feat_y1);
    feat_t  = 1.0;

    difference(){
        // Main body
        linear_extrude(height=t)
            rounded_rect_2d(w,h,body_r);

        // Screen window recess (shallow)
        translate([0,0,t-1.0])
            linear_extrude(height=1.05)
                rounded_rect_2d(win_w, win_h, win_r);
    }

    // Feature block on front face
    translate([feat_xc, (feat_y1+feat_y2)/2, t])
        linear_extrude(height=feat_t)
            square([feat_w, feat_h], center=true);
}

lcd_display_4p3();