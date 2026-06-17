$fn=64;

sx = 0.2;
sy = 0.1;
sz = 0.1;

base_len = 0.11;
base_w   = 0.09;
base_h   = 0.04;
base_r   = 0.02;

arm_th   = 0.03;
arm_w    = 0.05;
arm_r    = 0.035;
arm_z0   = base_h;
arm_z1   = 0.09;

pad_len  = 0.05;
pad_w    = 0.06;
pad_h    = 0.02;

boss1_len = 0.03;
boss1_w   = 0.055;
boss1_h   = 0.012;

boss2_len = 0.025;
boss2_w   = 0.055;
boss2_h   = 0.01;

module rounded_rect_2d(l, w, r){
    hull(){
        for(x=[-l/2 + r, l/2 - r])
            for(y=[-w/2 + r, w/2 - r])
                translate([x,y]) circle(r=r);
    }
}

module rounded_block(l,w,h,r){
    linear_extrude(height=h)
        rounded_rect_2d(l,w,r);
}

module arm_path_2d(r, z0, z1){
    union(){
        translate([0, z0]) square([r, arm_th], center=false);
        translate([r, z0]) square([arm_th, (z1 - z0) - r], center=false);
        translate([r, z0 + r]) intersection(){
            circle(r=r + arm_th);
            difference(){
                square([r + arm_th, r + arm_th], center=false);
                circle(r=r);
            }
        }
    }
}

module arm_solid(){
    translate([base_len/2 - arm_th, 0, 0])
        rotate([90,0,0])
            linear_extrude(height=arm_w, center=true)
                arm_path_2d(arm_r, arm_z0, arm_z1);
}

module end_pad(){
    x_end = (base_len/2 - arm_th) + arm_r + arm_th + pad_len/2;
    z_end = arm_z1 - pad_h/2;
    translate([x_end, 0, z_end])
        cube([pad_len, pad_w, pad_h], center=true);
}

module bosses(){
    x_b1 = base_len/2 - boss1_len/2;
    z_b1 = base_h + boss1_h/2;
    translate([x_b1, 0, z_b1])
        cube([boss1_len, boss1_w, boss1_h], center=true);

    x_end = (base_len/2 - arm_th) + arm_r + arm_th + pad_len/2;
    x_b2 = x_end - pad_len/2 + boss2_len/2;
    z_b2 = arm_z1 - pad_h + boss2_h/2;
    translate([x_b2, 0, z_b2])
        cube([boss2_len, boss2_w, boss2_h], center=true);
}

module bracket(){
    union(){
        translate([-(sx/2) + base_len/2, 0, 0])
            rounded_block(base_len, base_w, base_h, base_r);

        translate([-(sx/2) + base_len/2, 0, 0])
            arm_solid();

        translate([-(sx/2) + base_len/2, 0, 0])
            end_pad();

        translate([-(sx/2) + base_len/2, 0, 0])
            bosses();
    }
}

bracket();