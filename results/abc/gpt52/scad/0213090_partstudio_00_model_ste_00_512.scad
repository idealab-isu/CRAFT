$fn=64;

mm = 1;

bbox_x = 0.2*mm;
bbox_y = 0.1*mm;
bbox_z = 0.1*mm;

base_x = 0.12*mm;
base_y = 0.08*mm;
base_z = 0.06*mm;
base_r = 0.02*mm;

arm_z = 0.04*mm;
arm_r = arm_z/2;

neck_w = 0.028*mm;
neck_len = 0.03*mm;

arm_w = 0.036*mm;
arm_len1 = 0.05*mm;
arm_len2 = 0.05*mm;

end_w = 0.05*mm;
end_len = 0.04*mm;

boss_w = 0.012*mm;
boss_len = 0.016*mm;
boss_h = 0.02*mm;

module rounded_rect_2d(x,y,r){
    hull(){
        translate([ x/2 - r,  y/2 - r]) circle(r=r);
        translate([-x/2 + r,  y/2 - r]) circle(r=r);
        translate([ x/2 - r, -y/2 + r]) circle(r=r);
        translate([-x/2 + r, -y/2 + r]) circle(r=r);
    }
}

module obround_2d(len,w){
    r = w/2;
    hull(){
        translate([ len/2 - r, 0]) circle(r=r);
        translate([-len/2 + r, 0]) circle(r=r);
    }
}

module base_block(){
    linear_extrude(height=base_z, center=true)
        rounded_rect_2d(base_x, base_y, base_r);
}

module arm_path_2d(){
    union(){
        translate([base_x/2 - neck_len/2, 0])
            square([neck_len, neck_w], center=true);

        translate([base_x/2 + arm_len1/2, 0])
            square([arm_len1, arm_w], center=true);

        translate([base_x/2 + arm_len1, arm_len2/2])
            square([arm_w, arm_len2], center=true);

        translate([base_x/2 + arm_len1, 0])
            circle(r=arm_w/2);

        translate([base_x/2 + arm_len1, arm_len2])
            circle(r=arm_w/2);

        translate([base_x/2 + arm_len1, arm_len2])
            obround_2d(end_len, end_w);
    }
}

module arm_solid(){
    linear_extrude(height=arm_z, center=true)
        offset(r=arm_r)
            arm_path_2d();
}

module neck_bosses(){
    x0 = base_x/2 - neck_len*0.55;
    yoff = neck_w/2 + boss_w/2;
    union(){
        translate([x0,  yoff, 0])
            cube([boss_len, boss_w, boss_h], center=true);
        translate([x0, -yoff, 0])
            cube([boss_len, boss_w, boss_h], center=true);
    }
}

module bracket(){
    union(){
        base_block();
        arm_solid();
        neck_bosses();
    }
}

scale_factor = min(bbox_x/(base_x + arm_len1 + end_len*0.8), bbox_y/(base_y), bbox_z/(base_z + 0.02*mm));
scale([scale_factor, scale_factor, scale_factor]) bracket();