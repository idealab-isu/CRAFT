$fn=96;

rod_d = 16.0;
height = 27.0;

base_len = 50.0;
base_w   = 30.0;
base_t   = 8.0;

wall_t   = 6.0;
outer_d  = rod_d + 2*wall_t;   // 28mm
boss_h   = height - base_t;    // 19mm

bolt_d   = 6.5;
bolt_head_d = 12.0;
bolt_head_h = 3.0;

clamp_gap = 3.0;
clamp_bolt_d = 5.5;
clamp_bolt_head_d = 10.0;
clamp_bolt_head_h = 3.0;

module counterbore_through(h, d_through, d_cb, h_cb){
    union(){
        cylinder(h=h, d=d_through);
        translate([0,0,h-h_cb]) cylinder(h=h_cb, d=d_cb);
    }
}

module base_plate(){
    translate([-base_len/2, -base_w/2, 0])
        cube([base_len, base_w, base_t], center=false);
}

module boss(){
    translate([0,0,base_t])
        cylinder(h=boss_h, d=outer_d);
}

module rod_bore(){
    translate([0,0,base_t-0.2])
        cylinder(h=boss_h+0.4, d=rod_d);
}

module clamp_slot(){
    translate([-outer_d/2-1, -clamp_gap/2, base_t-0.5])
        cube([outer_d+2, clamp_gap, boss_h+1], center=false);
}

module base_holes(){
    hole_x = base_len/2 - 10.0;
    hole_y = base_w/2 - 7.5;
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*hole_x, sy*hole_y, 0])
            counterbore_through(base_t, bolt_d, bolt_head_d, bolt_head_h);
    }
}

module clamp_bolt_hole(){
    zc = base_t + boss_h*0.55;
    translate([0,0,zc])
        rotate([0,90,0])
            union(){
                cylinder(h=outer_d+2, d=clamp_bolt_d, center=true);
                translate([0,0, outer_d/2 - clamp_bolt_head_h/2])
                    cylinder(h=clamp_bolt_head_h, d=clamp_bolt_head_d, center=true);
            }
}

difference(){
    union(){
        base_plate();
        boss();
    }
    rod_bore();
    clamp_slot();
    base_holes();
    clamp_bolt_hole();
}