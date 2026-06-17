$fn = 96;

// Long linear bearing block for 8.0mm shaft
// Overall block size: 42.0mm x 70.0mm (X x Y)
// Thickness chosen as a reasonable default for a long block.
shaft_d = 8.0;

block_x = 42.0;
block_y = 70.0;
block_z = 18.0;

corner_r = 4.0;

// Through bore for shaft along Y (long axis)
bore_clearance = 0.4;          // diameter clearance
bore_d = shaft_d + bore_clearance;

// Optional split clamp slot and clamp screw holes
enable_clamp = true;
slot_w = 2.0;
slot_depth = block_z;          // through
clamp_hole_d = 3.4;            // for M3 clearance
clamp_head_d = 6.2;            // counterbore for M3 socket head
clamp_head_h = 3.2;

mount_hole_d = 5.2;            // for M5 clearance
mount_counterbore_d = 9.5;
mount_counterbore_h = 4.0;

module rounded_block(x,y,z,r){
    r2 = min(r, min(x,y)/2);
    linear_extrude(height=z)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module bearing_block(){
    difference(){
        // Body
        translate([0,0,0])
            rounded_block(block_x, block_y, block_z, corner_r);

        // Shaft bore (along Y)
        translate([0,0,block_z/2])
            rotate([90,0,0])
                cylinder(d=bore_d, h=block_y+2, center=true);

        // Relief pockets (reduce material, keep stiffness)
        // Two shallow side pockets
        pocket_z = block_z*0.55;
        pocket_x = block_x*0.62;
        pocket_y = block_y*0.72;
        for (sx=[-1,1]){
            translate([sx*(block_x*0.18), 0, block_z - pocket_z/2])
                rounded_block(pocket_x, pocket_y, pocket_z, 3.0);
        }

        // Mounting holes (4x) from bottom with counterbores
        mx = block_x*0.32;
        my = block_y*0.32;
        for (ix=[-1,1], iy=[-1,1]){
            translate([ix*mx, iy*my, 0])
                cylinder(d=mount_hole_d, h=block_z+1, center=false);

            translate([ix*mx, iy*my, 0])
                cylinder(d=mount_counterbore_d, h=mount_counterbore_h, center=false);
        }

        if (enable_clamp){
            // Clamp slot (split) from top down, aligned with bore
            translate([0, 0, block_z/2])
                cube([slot_w, block_y+2, slot_depth+2], center=true);

            // Two clamp screws across X, near ends
            clamp_y = block_y*0.28;
            for (yy=[-clamp_y, clamp_y]){
                // Through hole
                translate([0, yy, block_z*0.55])
                    rotate([0,90,0])
                        cylinder(d=clamp_hole_d, h=block_x+2, center=true);

                // Counterbore on +X side
                translate([block_x/2 - clamp_head_h/2, yy, block_z*0.55])
                    rotate([0,90,0])
                        cylinder(d=clamp_head_d, h=clamp_head_h+0.2, center=true);
            }
        }

        // Small chamfer-like edge relief via subtracting thin wedges (approx)
        cham = 0.8;
        // Top edges
        translate([0,0,block_z])
            rotate([0,0,0])
                linear_extrude(height=cham)
                    offset(r=corner_r)
                        square([block_x+2, block_y+2], center=true);
    }
}

bearing_block();