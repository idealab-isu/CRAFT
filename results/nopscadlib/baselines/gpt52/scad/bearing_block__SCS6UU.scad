$fn=64;

shaft_d = 6.0;
block_x = 30.0;
block_y = 25.0;
block_z = 16.0;

bore_clear = 0.3;
bore_d = shaft_d + bore_clear;

clamp_slot_w = 2.0;

mount_hole_d = 3.4;
mount_hole_x = 20.0;
mount_hole_y = 15.0;

counterbore_d = 6.6;
counterbore_depth = 3.0;

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_x/2, sy*mount_hole_y/2, 0])
            cylinder(d=mount_hole_d, h=block_z+2, center=true);
        translate([sx*mount_hole_x/2, sy*mount_hole_y/2, block_z/2 - counterbore_depth/2])
            cylinder(d=counterbore_d, h=counterbore_depth+0.2, center=true);
    }
}

module bearing_block() {
    difference() {
        cube([block_x, block_y, block_z], center=true);

        rotate([0, 90, 0])
            cylinder(d=bore_d, h=block_x+2, center=true);

        translate([0, 0, 0])
            cube([block_x+2, clamp_slot_w, block_z+2], center=true);

        mount_holes();
    }
}

bearing_block();