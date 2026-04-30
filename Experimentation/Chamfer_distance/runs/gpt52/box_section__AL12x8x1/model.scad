$fn = 64;

module box_section_tube(L=40, W=12, H=8, t=1, r_i=0.5) {
    r_o = r_i + t;

    module rounded_rect_2d(w, h, r) {
        if (r <= 0) {
            square([w, h], center=true);
        } else {
            minkowski() {
                square([w - 2*r, h - 2*r], center=true);
                circle(r=r);
            }
        }
    }

    difference() {
        linear_extrude(height=L, center=true, convexity=10)
            rounded_rect_2d(W, H, r_o);

        linear_extrude(height=L + 2, center=true, convexity=10)
            rounded_rect_2d(W - 2*t, H - 2*t, r_i);
    }
}

box_section_tube();