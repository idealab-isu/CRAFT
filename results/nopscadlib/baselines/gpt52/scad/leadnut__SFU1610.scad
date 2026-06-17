$fn=64;

block_x = 16.0;
block_y = 28.0;
block_z = 42.5;

lead_bore_d = 8.0;
counterbore_d = 14.0;
counterbore_depth = 6.0;

mount_hole_d = 4.2;
mount_hole_x_offset = 5.0;
mount_hole_y_offset = 9.0;

module centered_block(x,y,z){
    translate([-x/2,-y/2,-z/2]) cube([x,y,z], center=false);
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_x_offset, sy*mount_hole_y_offset, 0])
            rotate([90,0,0])
                cylinder(d=mount_hole_d, h=block_y+2, center=true);
    }
}

difference(){
    centered_block(block_x, block_y, block_z);

    // Leadscrew through-bore (along Z)
    cylinder(d=lead_bore_d, h=block_z+2, center=true);

    // Counterbores on both ends (along Z)
    translate([0,0, block_z/2 - counterbore_depth/2])
        cylinder(d=counterbore_d, h=counterbore_depth+0.2, center=true);
    translate([0,0,-block_z/2 + counterbore_depth/2])
        cylinder(d=counterbore_d, h=counterbore_depth+0.2, center=true);

    // Mounting holes (through Y)
    mount_holes();
}