$fn=96;

shaft_d = 6.0;
block_x = 34.0;
block_y = 58.0;
block_z = 18.0;

bore_clear = 0.25;
bore_d = shaft_d + bore_clear;

slot_w = 2.0;
slot_h = 10.0;

mount_hole_d = 4.2;
mount_hole_x = 24.0;
mount_hole_y = 46.0;

counterbore_d = 8.0;
counterbore_h = 4.0;

edge_r = 3.0;

module rounded_block(x,y,z,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r, center=true);
        }
    }
}

module mount_hole(pos){
    translate(pos)
        union(){
            cylinder(h=block_z+2, d=mount_hole_d, center=true);
            translate([0,0,block_z/2 - counterbore_h/2])
                cylinder(h=counterbore_h+0.2, d=counterbore_d, center=true);
        }
}

difference(){
    rounded_block(block_x, block_y, block_z, edge_r);

    rotate([90,0,0])
        cylinder(h=block_y+2, d=bore_d, center=true);

    translate([0,0,block_z/2 - slot_h/2])
        cube([slot_w, block_y+2, slot_h], center=true);

    for (sx=[-1,1], sy=[-1,1]){
        mount_hole([sx*mount_hole_x/2, sy*mount_hole_y/2, 0]);
    }
}