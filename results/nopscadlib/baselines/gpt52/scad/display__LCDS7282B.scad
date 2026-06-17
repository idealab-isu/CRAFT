$fn=64;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module lcd_s_7282b(body_w=73.6, body_h=28.7, body_t=2.2, corner_r=2.0,
                  bezel_inset=1.2, bezel_t=0.6,
                  window_w=62.0, window_h=18.0, window_depth=0.9){
    difference(){
        union(){
            linear_extrude(height=body_t)
                rounded_rect_2d(body_w, body_h, corner_r);

            translate([0,0,body_t - bezel_t])
                linear_extrude(height=bezel_t)
                    rounded_rect_2d(body_w - 2*bezel_inset, body_h - 2*bezel_inset, max(0.5, corner_r-0.8));
        }

        translate([0,0,body_t - window_depth])
            linear_extrude(height=window_depth + 0.2)
                rounded_rect_2d(window_w, window_h, 1.2);
    }
}

lcd_s_7282b();