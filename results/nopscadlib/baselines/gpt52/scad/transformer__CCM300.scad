$fn=64;

L=120.0;
W=88.0;
H=120.0;

module rounded_box(size=[10,10,10], r=2){
    l=size[0]; w=size[1]; h=size[2];
    r2=min(r, min(l,w)/2);
    hull(){
        for(x=[-l/2+r2, l/2-r2])
            for(y=[-w/2+r2, w/2-r2])
                translate([x,y,0]) cylinder(h=h, r=r2);
    }
}

module mounting_foot(side=1, foot_len=18, foot_w=14, foot_h=6, hole_d=6.5, hole_offset=6){
    x = side*(L/2 + foot_len/2);
    translate([x,0,-H/2 + foot_h/2])
    difference(){
        cube([foot_len, foot_w, foot_h], center=true);
        translate([side*(foot_len/2 - hole_offset),0,0])
            rotate([90,0,0]) cylinder(h=foot_w+2, d=hole_d, center=true);
    }
}

module terminal_block(side=1, blk_l=26, blk_w=18, blk_h=14, post_d=3.2, post_h=10, post_pitch=7.5){
    x = side*(L/2 - blk_l/2 - 6);
    y = 0;
    z = H/2 - blk_h/2 - 6;
    translate([x,y,z]){
        union(){
            cube([blk_l, blk_w, blk_h], center=true);
            for(i=[-1.5,-0.5,0.5,1.5]){
                translate([i*post_pitch, 0, blk_h/2 + post_h/2])
                    cylinder(h=post_h, d=post_d, center=true);
            }
        }
    }
}

module transformer_body(){
    union(){
        rounded_box([L,W,H], r=6);
        mounting_foot(1);
        mounting_foot(-1);
        terminal_block(1);
        terminal_block(-1);
    }
}

transformer_body();