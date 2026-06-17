$fn=96;

shaft_d = 6.0;
shaft_clear = 0.25;
bore_d = shaft_d + shaft_clear;

block_x = 34.0;
block_y = 30.0;
block_z = 16.0;

mount_hole_d = 3.4;
mount_hole_head_d = 6.6;
mount_hole_head_depth = 3.0;

mount_x_spacing = 24.0;
mount_y_spacing = 20.0;

edge_r = 2.0;

module rounded_block(x,y,z,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), sz*(z/2-r)])
                sphere(r=r);
        }
    }
}

module mount_hole(){
    union(){
        cylinder(d=mount_hole_d, h=block_z+0.4, center=true);
        translate([0,0, block_z/2 - mount_hole_head_depth/2 + 0.01])
            cylinder(d=mount_hole_head_d, h=mount_hole_head_depth+0.2, center=true);
    }
}

module bearing_block(){
    difference(){
        rounded_block(block_x, block_y, block_z, edge_r);

        rotate([0,90,0])
            cylinder(d=bore_d, h=block_x+0.6, center=true);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*mount_x_spacing/2, sy*mount_y_spacing/2, 0])
                mount_hole();
        }

        translate([0,0, block_z/2 - 1.0])
            cube([block_x+1, block_y+1, 2.0], center=true);
    }
}

bearing_block();