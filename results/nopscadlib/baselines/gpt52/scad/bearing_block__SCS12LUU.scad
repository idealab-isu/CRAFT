$fn=64;

shaft_d = 8.0;
shaft_r = shaft_d/2;

block_w = 42.0;   // X
block_l = 70.0;   // Y
block_h = 24.0;   // Z

bore_clear = 0.4;
bore_d = shaft_d + bore_clear;

wall = 6.0;
slot_w = 10.0;
slot_depth = 3.0;

mount_hole_d = 5.0;
mount_hole_head_d = 9.0;
mount_hole_head_depth = 3.0;

mount_x = 14.0;
mount_y = 24.0;

module rounded_block(w,l,h,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(w/2 - r), sy*(l/2 - r), 0])
                cylinder(h=h, r=r);
        }
    }
}

module counterbore_hole(h, d_through, d_head, head_depth){
    union(){
        cylinder(h=h+0.2, d=d_through, center=false);
        translate([0,0,h-head_depth])
            cylinder(h=head_depth+0.2, d=d_head, center=false);
    }
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_x, sy*mount_y, 0])
            counterbore_hole(block_h, mount_hole_d, mount_hole_head_d, mount_hole_head_depth);
    }
}

module bearing_block(){
    difference(){
        translate([0,0,-block_h/2])
            rounded_block(block_w, block_l, block_h, 4.0);

        // Shaft bore along Y axis
        rotate([90,0,0])
            cylinder(h=block_l+2, d=bore_d, center=true);

        // Relief slot on top to allow clamping
        translate([0,0,block_h/2 - slot_depth/2])
            cube([slot_w, block_l+2, slot_depth+0.2], center=true);

        // Mounting holes (vertical)
        translate([0,0,-block_h/2])
            mount_holes();

        // Side flats for easier printing/clearance
        for (sx=[-1,1]){
            translate([sx*(block_w/2 - 1.5), 0, 0])
                cube([3.0, block_l+2, block_h+2], center=true);
        }
    }
}

bearing_block();