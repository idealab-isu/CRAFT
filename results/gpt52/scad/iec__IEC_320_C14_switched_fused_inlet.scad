$fn=64;

plate_w = 40.0;
plate_h = 27.0;
plate_t = 3.0;

body_w = 30.0;
body_h = 22.0;
body_d = 28.0;

flange_r = 2.0;

cut_w = 30.0;
cut_h = 22.0;

screw_dx = 32.0;
screw_dy = 19.0;
screw_d = 3.2;
screw_head_d = 6.5;
screw_head_depth = 1.6;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module plate(){
    linear_extrude(height=plate_t, center=true)
        rounded_rect_2d(plate_w, plate_h, flange_r);
}

module body(){
    translate([0,0,-(plate_t/2 + body_d/2)])
        linear_extrude(height=body_d, center=true)
            rounded_rect_2d(body_w, body_h, 1.5);
}

module cutout(){
    translate([0,0,0])
        linear_extrude(height=plate_t+0.6, center=true)
            rounded_rect_2d(cut_w, cut_h, 1.0);
}

module screw_hole(x,y){
    translate([x,y,0]){
        cylinder(d=screw_d, h=plate_t+1.0, center=true);
        translate([0,0,plate_t/2 - screw_head_depth/2])
            cylinder(d=screw_head_d, h=screw_head_depth+0.2, center=true);
    }
}

difference(){
    union(){
        plate();
        body();
    }
    cutout();
    screw_hole( screw_dx/2,  screw_dy/2);
    screw_hole(-screw_dx/2,  screw_dy/2);
    screw_hole( screw_dx/2, -screw_dy/2);
    screw_hole(-screw_dx/2, -screw_dy/2);
}