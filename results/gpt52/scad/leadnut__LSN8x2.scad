$fn=64;

block_x = 8.0;
block_y = 10.2;
block_z = 15.0;

thread_hole_d = 4.2;
counterbore_d = 7.0;
counterbore_depth = 3.0;

mount_hole_d = 2.6;
mount_hole_spacing_y = 6.0;

edge_chamfer = 0.6;

module chamfered_block(x,y,z,c){
    difference(){
        cube([x,y,z], center=true);
        for (sx=[-1,1], sy=[-1,1], sz=[-1,1]){
            translate([sx*(x/2), sy*(y/2), sz*(z/2)])
                rotate([0,0,45])
                    cube([c*2, c*2, c*2], center=true);
        }
    }
}

module leadscrew_nut_housing(){
    difference(){
        chamfered_block(block_x, block_y, block_z, edge_chamfer);

        cylinder(d=thread_hole_d, h=block_z+2, center=true);

        translate([0,0,block_z/2 - counterbore_depth/2])
            cylinder(d=counterbore_d, h=counterbore_depth+0.2, center=true);

        for (sy=[-1,1]){
            translate([0, sy*(mount_hole_spacing_y/2), 0])
                rotate([0,90,0])
                    cylinder(d=mount_hole_d, h=block_x+2, center=true);
        }
    }
}

leadscrew_nut_housing();