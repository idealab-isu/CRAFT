$fn=64;

plate_th = 2;
hub_r = 8;

arm_len = 45;
arm_w_root = 10;
arm_w_mid = 12;
arm_w_tip = 22;

pad_len = 18;
pad_w = 28;
pad_r = 6;

hole_size = 3.2;
hole_clear = 0.2;
hole_h = plate_th + 2;

arm_count = 6;

module rounded_rect_2d(w, h, r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
    }
}

module diamond_hole(size){
    rotate(45) square([size, size], center=true);
}

module arm_2d(){
    union(){
        polygon(points=[
            [hub_r, -arm_w_root/2],
            [hub_r,  arm_w_root/2],
            [hub_r + arm_len*0.55,  arm_w_mid/2],
            [hub_r + arm_len,       arm_w_tip/2],
            [hub_r + arm_len,      -arm_w_tip/2],
            [hub_r + arm_len*0.55, -arm_w_mid/2]
        ]);
        translate([hub_r + arm_len + pad_len/2, 0])
            rounded_rect_2d(pad_len, pad_w, pad_r);
    }
}

module arm_holes_2d(){
    union(){
        for (x = [hub_r + arm_len + pad_len*0.25, hub_r + arm_len + pad_len*0.5, hub_r + arm_len + pad_len*0.75]){
            for (y = [-pad_w*0.25, 0, pad_w*0.25]){
                translate([x, y]) diamond_hole(hole_size + hole_clear);
            }
        }
        for (x2 = [hub_r + arm_len*0.25, hub_r + arm_len*0.45, hub_r + arm_len*0.65]){
            translate([x2, 0]) diamond_hole(hole_size + hole_clear);
        }
    }
}

module one_arm(){
    difference(){
        linear_extrude(height=plate_th, center=true) arm_2d();
        linear_extrude(height=hole_h, center=true) arm_holes_2d();
    }
}

module hub(){
    difference(){
        cylinder(h=plate_th, r=hub_r, center=true);
        cylinder(h=hole_h, r=2.2, center=true);
    }
}

module spider_plate(){
    union(){
        hub();
        for (i=[0:arm_count-1]){
            rotate([0,0, i*360/arm_count]) one_arm();
        }
    }
}

rotate([0,0,0]) spider_plate();