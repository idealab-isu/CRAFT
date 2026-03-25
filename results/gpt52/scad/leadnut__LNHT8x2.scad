$fn=64;

block_x = 30.0;
block_y = 34.0;
block_z = 30.0;

nut_bore_d = 16.0;
nut_bore_depth = 24.0;

mount_hole_d = 5.0;
mount_hole_x_spacing = 20.0;
mount_hole_y_spacing = 24.0;

counterbore_d = 9.0;
counterbore_depth = 4.0;

module centered_block(x,y,z){
    translate([-x/2,-y/2,-z/2]) cube([x,y,z], center=false);
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_x_spacing/2, sy*mount_hole_y_spacing/2, 0])
            cylinder(d=mount_hole_d, h=block_z+0.2, center=true);
    }
}

module counterbores_top(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_hole_x_spacing/2, sy*mount_hole_y_spacing/2, block_z/2 - counterbore_depth/2])
            cylinder(d=counterbore_d, h=counterbore_depth+0.2, center=true);
    }
}

module nut_bore(){
    translate([0,0,block_z/2 - nut_bore_depth/2])
        cylinder(d=nut_bore_d, h=nut_bore_depth+0.2, center=true);
}

difference(){
    centered_block(block_x, block_y, block_z);
    nut_bore();
    mount_holes();
    counterbores_top();
}