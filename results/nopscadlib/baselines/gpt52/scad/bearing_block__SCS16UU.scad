$fn=96;

shaft_d = 9.0;
shaft_clear = 0.35;
bore_d = shaft_d + shaft_clear;

block_x = 50.0;
block_y = 44.0;
block_z = 20.0;

wall_min = 4.0;
bore_z = block_z + 2.0;

mount_hole_d = 5.2;
mount_hole_head_d = 9.5;
mount_hole_head_depth = 3.0;

mount_x_spacing = 36.0;
mount_y_spacing = 30.0;

edge_chamfer = 1.5;

module chamfered_block(x,y,z,c){
    hull(){
        translate([ x/2-c,  y/2-c,  z/2-c]) sphere(r=c);
        translate([ x/2-c,  y/2-c, -z/2+c]) sphere(r=c);
        translate([ x/2-c, -y/2+c,  z/2-c]) sphere(r=c);
        translate([ x/2-c, -y/2+c, -z/2+c]) sphere(r=c);
        translate([-x/2+c,  y/2-c,  z/2-c]) sphere(r=c);
        translate([-x/2+c,  y/2-c, -z/2+c]) sphere(r=c);
        translate([-x/2+c, -y/2+c,  z/2-c]) sphere(r=c);
        translate([-x/2+c, -y/2+c, -z/2+c]) sphere(r=c);
    }
}

module counterbored_hole_through(d_through, d_cb, cb_depth, z_thick){
    union(){
        cylinder(d=d_through, h=z_thick+0.2, center=true);
        translate([0,0, z_thick/2 - cb_depth/2 + 0.01])
            cylinder(d=d_cb, h=cb_depth+0.2, center=true);
    }
}

module bearing_block(){
    difference(){
        chamfered_block(block_x, block_y, block_z, edge_chamfer);

        cylinder(d=bore_d, h=bore_z, center=true);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*mount_x_spacing/2, sy*mount_y_spacing/2, 0])
                counterbored_hole_through(mount_hole_d, mount_hole_head_d, mount_hole_head_depth, block_z);
        }

        slot_w = max(2.0, bore_d*0.22);
        slot_x = block_x + 2.0;
        translate([0, block_y/2 - wall_min/2, 0])
            cube([slot_x, wall_min, block_z+2.0], center=true);

        translate([0, block_y/2 - wall_min, 0])
            cube([slot_x, slot_w, block_z+2.0], center=true);
    }
}

bearing_block();