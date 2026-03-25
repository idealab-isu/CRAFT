$fn=96;

shaft_d = 8.0;
shaft_clear = 0.35;
shaft_hole_d = shaft_d + shaft_clear;

block_w = 40.0;   // X
block_l = 68.0;   // Y
block_h = 24.0;   // Z

end_margin = 10.0;
mount_x = 28.0;
mount_y = block_l - 2*end_margin;
mount_hole_d = 5.2;
mount_counterbore_d = 9.5;
mount_counterbore_depth = 4.0;

slot_w = 14.0;
slot_depth = 6.0;

edge_r = 2.0;

module rounded_block(x, y, z, r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(h=z, r=r);
    }
}

module mount_holes(){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*mount_x/2, sy*mount_y/2, 0]){
            cylinder(h=block_h+2, d=mount_hole_d, center=true);
            translate([0,0, block_h/2 - mount_counterbore_depth/2 + 0.001])
                cylinder(h=mount_counterbore_depth+0.01, d=mount_counterbore_d, center=true);
        }
    }
}

module shaft_bore(){
    rotate([90,0,0])
        cylinder(h=block_l+2, d=shaft_hole_d, center=true);
}

module top_relief_slot(){
    translate([0,0, block_h/2 - slot_depth/2 + 0.001])
        cube([slot_w, block_l+2, slot_depth+0.01], center=true);
}

difference(){
    rounded_block(block_w, block_l, block_h, edge_r);
    shaft_bore();
    mount_holes();
    top_relief_slot();
}