$fn = 64;

body_w = 45.3;
body_h = 26.0;
body_d = 17.4;

bezel_w = 47.8;
bezel_h = 28.8;
bezel_t = 2.2;

ap_w = 36.0;
ap_h = 18.0;

corner_r = 1.2;

module rounded_rect_prism(w,h,d,r=1.0){
    hull(){
        for (sx = [-1, 1], sy = [-1, 1]){
            translate([sx*(w/2 - r), sy*(h/2 - r), 0])
                cylinder(h=d, r=r, center=false);
        }
    }
}

module meter(){
    union(){
        // Bezel with display aperture cutout
        difference(){
            translate([0,0,body_d/2 + bezel_t/2])
                rounded_rect_prism(bezel_w, bezel_h, bezel_t, r=corner_r);
            translate([0,0,body_d/2 + bezel_t/2 - 0.2])
                cube([ap_w, ap_h, bezel_t + 0.4], center=true);
        }

        // Main body (behind bezel)
        translate([0,0,0])
            rounded_rect_prism(body_w, body_h, body_d, r=corner_r);

        // Small rear protrusion to ensure non-empty detail
        translate([0,0,-body_d/2 - 3])
            cylinder(h=6, r=4.5, center=true);
    }
}

meter();