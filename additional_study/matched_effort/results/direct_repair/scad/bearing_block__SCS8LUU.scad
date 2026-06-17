$fn = 96;

// Long linear bearing block for 6.0mm shaft
// Overall block size: 34.0mm x 58.0mm (X x Y). Height chosen as a reasonable default.

shaft_d = 6.0;

block_x = 34.0;
block_y = 58.0;
block_z = 18.0;

wall = 3.0;                 // minimum wall thickness around bore
bore_clear = 0.25;          // clearance on shaft bore
bore_d = shaft_d + bore_clear;

slot_w = 2.0;               // clamp slit width
clamp_screw_d = 3.2;        // M3 clearance
clamp_screw_head_d = 6.2;   // socket head clearance
clamp_screw_head_h = 3.2;

mount_hole_d = 4.3;         // M4 clearance
mount_counterbore_d = 8.2;  // counterbore for M4 socket head
mount_counterbore_h = 4.0;

corner_r = 3.0;

module rounded_block(x,y,z,r){
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module bearing_block(){
    difference(){
        // Body
        rounded_block(block_x, block_y, block_z, corner_r);

        // Shaft bore (along Y axis)
        rotate([90,0,0])
            cylinder(d=bore_d, h=block_y+2, center=true);

        // Clamp slit from top to bore (along Y, thin in X)
        translate([0,0,block_z/2])
            cube([slot_w, block_y+2, block_z], center=true);

        // Clamp screws (2x) across slit (along X), with head pockets on +X side
        for (yy = [-block_y*0.22, block_y*0.22]){
            // Through hole
            translate([0, yy, block_z*0.25])
                rotate([0,90,0])
                    cylinder(d=clamp_screw_d, h=block_x+2, center=true);

            // Head pocket on +X side
            translate([block_x/2 - clamp_screw_head_h/2, yy, block_z*0.25])
                rotate([0,90,0])
                    cylinder(d=clamp_screw_head_d, h=clamp_screw_head_h+0.2, center=true);
        }

        // Mounting holes (4x) from bottom, counterbored
        mx = block_x*0.30;
        my = block_y*0.32;
        for (sx = [-1,1], sy = [-1,1]){
            // Through hole
            translate([sx*mx, sy*my, 0])
                cylinder(d=mount_hole_d, h=block_z+2, center=true);

            // Counterbore from bottom
            translate([sx*mx, sy*my, -block_z/2 + mount_counterbore_h/2])
                cylinder(d=mount_counterbore_d, h=mount_counterbore_h+0.2, center=true);
        }

        // Light chamfer-ish relief on bottom edges (simple bevel via hull of cuts)
        // (kept subtle to preserve stated footprint)
        translate([0,0,-block_z/2])
            linear_extrude(height=1.2)
                offset(r=1.0)
                    square([block_x-2.0, block_y-2.0], center=true);
    }
}

bearing_block();