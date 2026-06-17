$fn=64;

module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module iec_inlet_cutout(w=40.0, h=27.0, depth=20.0, corner_r=2.0) {
    linear_extrude(height=depth, center=true)
        rounded_rect_2d(w, h, corner_r);
}

module screw_hole(d=3.2, depth=20.0) {
    cylinder(d=d, h=depth, center=true);
}

module iec_inlet_module() {
    cut_w = 40.0;
    cut_h = 27.0;
    depth = 20.0;

    flange_w = 50.0;
    flange_h = 37.0;
    flange_t = 3.0;
    flange_r = 3.0;

    body_w = 44.0;
    body_h = 31.0;
    body_t = 18.0;
    body_r = 2.0;

    hole_d = 3.2;
    hole_x = 22.0;
    hole_y = 0.0;

    difference() {
        union() {
            translate([0,0, body_t/2])
                linear_extrude(height=body_t, center=true)
                    rounded_rect_2d(body_w, body_h, body_r);

            translate([0,0, -flange_t/2])
                linear_extrude(height=flange_t, center=true)
                    rounded_rect_2d(flange_w, flange_h, flange_r);
        }

        iec_inlet_cutout(cut_w, cut_h, depth=body_t + flange_t + 2, corner_r=2.0);

        translate([ hole_x, hole_y, 0])
            screw_hole(d=hole_d, depth=body_t + flange_t + 4);

        translate([-hole_x, hole_y, 0])
            screw_hole(d=hole_d, depth=body_t + flange_t + 4);
    }
}

iec_inlet_module();