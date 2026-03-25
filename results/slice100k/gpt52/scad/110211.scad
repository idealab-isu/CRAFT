$fn=64;

L = 22.0;
W = 15.0;
H = 6.0;

corner_r = 2.0;

plate_t = 3.0;

boss_l = 10.0;
boss_w = 7.0;
boss_h = H - plate_t;

hole_d = 3.2;
hole_x = 7.0;

rod_r = 4.0;

module rounded_rect_2d(l, w, r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module base_plate(){
    linear_extrude(height=plate_t)
        rounded_rect_2d(L, W, corner_r);
}

module boss(){
    translate([0,0,plate_t])
        cube([boss_l, boss_w, boss_h], center=true);
}

module holes(){
    for (sx=[-1,1])
        translate([sx*hole_x, 0, 0])
            cylinder(d=hole_d, h=H+0.4, center=false);
}

module rod_cutout(){
    translate([0,0,plate_t])
        rotate([0,90,0])
            cylinder(r=rod_r, h=L+0.6, center=true);
}

difference(){
    union(){
        base_plate();
        boss();
    }
    translate([0,0,-0.2]) holes();
    rod_cutout();
}