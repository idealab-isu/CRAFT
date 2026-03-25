$fn=64;

L = 43.9;
W = 10.9;
H = 10.6;

module rounded_box(size=[10,10,10], r=1.0, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, sx/2, sy/2);
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    linear_extrude(height=sz)
        offset(r=rr)
            square([sx-2*rr, sy-2*rr], center=false);
}

module rib(len=10, w=1.0, h=1.0, z0=0){
    translate([-len/2, -w/2, z0])
        cube([len, w, h], center=false);
}

module arm_with_step(arm_len=14.0, arm_w=W, arm_h=6.2, step_len=2.2, step_h=1.2, fillet_r=1.0){
    union(){
        rounded_box([arm_len, arm_w, arm_h], r=fillet_r, center=true);
        translate([-(arm_len/2 - step_len/2), 0, (arm_h/2 + step_h/2)])
            rounded_box([step_len, arm_w, step_h], r=fillet_r*0.8, center=true);
    }
}

module central_block(block_len=15.9, block_w=W, block_h=H, fillet_r=1.2){
    rounded_box([block_len, block_w, block_h], r=fillet_r, center=true);
}

module bracket(){
    block_len = 15.9;
    arm_len = (L - block_len)/2;
    arm_h = 6.2;
    step_len = 2.2;
    step_h = 1.2;

    difference(){
        union(){
            central_block(block_len=block_len, block_w=W, block_h=H, fillet_r=1.2);

            translate([ (block_len/2 + arm_len/2), 0, -(H/2 - arm_h/2)])
                arm_with_step(arm_len=arm_len, arm_w=W, arm_h=arm_h, step_len=step_len, step_h=step_h, fillet_r=1.0);

            translate([-(block_len/2 + arm_len/2), 0, -(H/2 - arm_h/2)])
                arm_with_step(arm_len=arm_len, arm_w=W, arm_h=arm_h, step_len=step_len, step_h=step_h, fillet_r=1.0);

            rib_len = L - 2.0;
            rib_h = 1.0;
            rib_w = 0.9;
            z_rib = H/2 - rib_h;

            for (ypos = [-3.6, -1.8, 0, 1.8, 3.6])
                translate([0, ypos, 0])
                    rib(len=rib_len, w=rib_w, h=rib_h, z0=z_rib);
        }

        win = 6.0;
        translate([0,0,0])
            cube([win, win, H+0.6], center=true);
    }
}

bracket();