$fn=96;

th = 3.5;

L = 108.0;
W = 31.0;

main_L = 78.0;
ext_L  = L - main_L;

main_r = W/2;

ext_W = 22.0;
ext_r = 4.0;

step_L = 18.0;
step_W = 16.0;
step_r = 3.0;

notch_depth = 10.0;
notch_width = 12.0;
notch_r = notch_width/2;

hole_d = 6.0;
small_hole_d = 4.0;

grid_dx = 18.0;
grid_dy = 12.0;

module rounded_rect_2d(l, w, r){
    hull(){
        translate([ l/2 - r,  w/2 - r]) circle(r=r);
        translate([-l/2 + r,  w/2 - r]) circle(r=r);
        translate([ l/2 - r, -w/2 + r]) circle(r=r);
        translate([-l/2 + r, -w/2 + r]) circle(r=r);
    }
}

module plate_outline_2d(){
    union(){
        translate([-(L/2) + main_L/2, 0])
            rounded_rect_2d(main_L, W, main_r);

        translate([-(L/2) + main_L + ext_L/2, 0])
            rounded_rect_2d(ext_L, ext_W, ext_r);

        translate([L/2 - step_L/2, 0])
            rounded_rect_2d(step_L, step_W, step_r);
    }
}

module u_notch_cut_2d(){
    translate([L/2 - notch_depth, 0])
        square([notch_depth + 0.2, notch_width], center=false);

    translate([L/2 - notch_depth, notch_width/2])
        circle(r=notch_r);

    translate([L/2 - notch_depth, -notch_width/2])
        circle(r=notch_r);
}

module holes_2d(){
    x0 = -(L/2) + 22.0;
    for (ix = [0:2]){
        for (iy = [0:1]){
            translate([x0 + ix*grid_dx, (iy==0 ? -grid_dy/2 : grid_dy/2)])
                circle(d=hole_d);
        }
    }

    translate([-(L/2) + 12.0, 0])
        circle(d=small_hole_d);
}

difference(){
    linear_extrude(height=th, center=true)
        difference(){
            plate_outline_2d();
            u_notch_cut_2d();
            holes_2d();
        }
}