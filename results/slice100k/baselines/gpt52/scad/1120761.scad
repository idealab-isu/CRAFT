$fn=64;

size_xy = 26.4;
thickness = 5.6;

arm_w = 8.8;
core_w = 8.8;
corner_r = 2.2;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module cross_2d(arm_len, arm_w, r){
    union(){
        rounded_rect_2d(arm_len, arm_w, r);
        rounded_rect_2d(arm_w, arm_len, r);
    }
}

module cross_block(){
    linear_extrude(height=thickness, center=true, convexity=10)
        cross_2d(size_xy, arm_w, corner_r);
}

cross_block();