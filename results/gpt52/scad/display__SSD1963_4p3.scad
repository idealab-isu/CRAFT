$fn=64;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module lcd_display_4p3(){
    w = 105.5;
    h = 67.2;
    t = 3.4;

    // Screen window extents (from input)
    win_x1 = -50;
    win_y1 = -26.5;
    win_x2 = 50;
    win_y2 = 31.5;
    win_depth = 0.5;

    // Back recess extents (from input)
    back_x1 = -w/2;
    back_y1 = -65/2 + 1;
    back_x2 =  w/2;
    back_y2 =  65/2 + 1;
    back_depth = 1;

    // Small feature extents (from input)
    feat_x1 = 0;
    feat_y1 = -34.5;
    feat_x2 = 12;
    feat_y2 = -31.5;

    base_r = 2;

    difference(){
        // Main body centered at origin
        linear_extrude(height=t, center=true)
            rounded_rect_2d(w,h,base_r);

        // Front screen window recess (cut from front face)
        translate([0,0, t/2 - win_depth/2])
            cube([win_x2-win_x1, win_y2-win_y1, win_depth], center=true);

        // Back recess (cut from back face)
        translate([0,0, -t/2 + back_depth/2])
            cube([back_x2-back_x1, back_y2-back_y1, back_depth], center=true);

        // Small feature cut (through)
        translate([(feat_x1+feat_x2)/2, (feat_y1+feat_y2)/2, 0])
            cube([feat_x2-feat_x1, feat_y2-feat_y1, t+0.2], center=true);
    }
}

lcd_display_4p3();