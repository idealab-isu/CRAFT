$fn=96;

shaft_d = 9.0;
shaft_r = shaft_d/2;

block_w = 50.0;   // X
block_l = 85.0;   // Y
block_h = 30.0;   // Z

bore_clear = 0.35;
bore_d = shaft_d + 2*bore_clear;

wall_min = 6.0;
bore_z = 0.0;

clamp_slot_w = 2.0;
clamp_slot_depth = 18.0;

mount_hole_d = 5.5;
mount_hole_head_d = 10.0;
mount_hole_head_depth = 4.0;

mount_x = 18.0;
mount_y = 30.0;

module rounded_block(w,l,h,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(w/2-r), sy*(l/2-r), -h/2])
                cylinder(h=h, r=r);
        }
    }
}

module mount_hole(){
    union(){
        cylinder(h=block_h+2, d=mount_hole_d, center=true);
        translate([0,0,block_h/2 - mount_hole_head_depth/2])
            cylinder(h=mount_hole_head_depth+0.2, d=mount_hole_head_d, center=true);
    }
}

module bearing_block(){
    difference(){
        rounded_block(block_w, block_l, block_h, r=6.0);

        rotate([90,0,0])
            cylinder(h=block_l+2, d=bore_d, center=true);

        translate([0, block_l/2 - clamp_slot_depth/2, 0])
            cube([clamp_slot_w, clamp_slot_depth+0.2, block_h+2], center=true);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*mount_x, sy*mount_y, 0])
                mount_hole();
        }
    }
}

bearing_block();