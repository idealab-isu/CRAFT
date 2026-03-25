$fn=64;

shaft_d = 8.0;
shaft_r = shaft_d/2;

block_x = 40.0;
block_y = 35.0;
block_z = 20.0;

bore_clearance = 0.4;
bore_d = shaft_d + bore_clearance;

wall_min = 4.0;
bore_z = block_z/2;

mount_hole_d = 5.0;
mount_hole_head_d = 9.0;
mount_hole_head_depth = 3.0;

mount_x_offset = 12.0;
mount_y_offset = 10.0;

clamp_slot_w = 2.0;
clamp_slot_len = block_x - 6.0;

clamp_screw_d = 4.0;
clamp_screw_head_d = 7.5;
clamp_screw_head_depth = 3.0;

module rounded_block(x,y,z,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), sz*(z/2-r)])
                sphere(r=r);
        }
    }
}

module mount_hole(pos){
    translate(pos)
    union(){
        cylinder(d=mount_hole_d, h=block_z+2, center=true);
        translate([0,0,block_z/2 - mount_hole_head_depth/2])
            cylinder(d=mount_hole_head_d, h=mount_hole_head_depth+0.2, center=true);
    }
}

module clamp_screw_hole(pos){
    translate(pos)
    union(){
        rotate([0,90,0]) cylinder(d=clamp_screw_d, h=block_x+2, center=true);
        translate([block_x/2 - clamp_screw_head_depth/2,0,0])
            rotate([0,90,0]) cylinder(d=clamp_screw_head_d, h=clamp_screw_head_depth+0.2, center=true);
    }
}

difference(){
    rounded_block(block_x, block_y, block_z, r=3.0);

    rotate([90,0,0])
        cylinder(d=bore_d, h=block_y+2, center=true);

    translate([0,0,0])
        cube([clamp_slot_len, clamp_slot_w, block_z+2], center=true);

    for (sx=[-1,1], sy=[-1,1]){
        mount_hole([sx*mount_x_offset, sy*mount_y_offset, 0]);
    }

    clamp_screw_hole([0, 0, 0]);
}