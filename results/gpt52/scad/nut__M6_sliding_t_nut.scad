$fn=64;

screw_d = 6.0;
across_flats = 8.0;
thickness = 6.6;

t_head_w = 12.0;
t_head_l = 18.0;
t_neck_w = 8.0;
t_neck_l = 10.0;

chamfer = 0.6;

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, center=true, $fn=6);
}

module tslot_nut_body(){
    union(){
        cube([t_head_l, t_head_w, thickness], center=true);
        cube([t_neck_l, t_neck_w, thickness], center=true);
    }
}

module chamfered_body(){
    difference(){
        tslot_nut_body();
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(t_head_l/2), sy*(t_head_w/2), 0])
                rotate([0,0,45])
                    cube([chamfer*2, chamfer*2, thickness+0.2], center=true);
        }
    }
}

module tslot_nut(){
    difference(){
        chamfered_body();
        translate([0,0,0])
            cylinder(h=thickness+0.4, d=screw_d+0.4, center=true, $fn=64);
        translate([0,0,0])
            hex_prism(across_flats+0.2, thickness+0.4);
    }
}

tslot_nut();