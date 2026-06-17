$fn = 96;

// Long linear bearing block for 9.0mm shaft
// Overall block size: 50.0mm x 85.0mm (X x Y)
// Thickness chosen as a reasonable default for a long block.
shaft_d = 9.0;

block_x = 50.0;
block_y = 85.0;
block_z = 24.0;

corner_r = 4.0;

// Shaft bore runs along Y (length)
bore_clearance = 0.4;          // diameter clearance
bore_d = shaft_d + bore_clearance;

// Split clamp slot (top to bore)
slot_w = 2.0;

// Mounting holes (4x) through Z
mount_hole_d = 5.2;            // M5 clearance
mount_counterbore_d = 9.5;     // socket head cap clearance
mount_counterbore_h = 4.0;

edge_x = 10.0;
edge_y = 12.0;

// Clamp screw holes across X (2x), through the split
clamp_hole_d = 4.3;            // M4 clearance
clamp_head_d = 8.0;            // head/counterbore
clamp_head_h = 3.0;
clamp_y_offset = 18.0;         // from center along Y

module rounded_block(x, y, z, r){
    r2 = min(r, x/2, y/2);
    linear_extrude(height=z)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module bearing_block(){
    difference(){
        // Body
        translate([0,0,block_z/2])
            rounded_block(block_x, block_y, block_z, corner_r);

        // Shaft bore along Y
        translate([0,0,block_z/2])
            rotate([90,0,0])
                cylinder(d=bore_d, h=block_y+2, center=true);

        // Split slot from top down to bore
        translate([0,0,block_z/2])
            translate([0,0,block_z/2])
                cube([slot_w, block_y+2, block_z], center=true);

        // Mounting holes (4x) through Z with counterbore on top
        for (sx = [-1, 1])
        for (sy = [-1, 1]){
            xh = sx*(block_x/2 - edge_x);
            yh = sy*(block_y/2 - edge_y);

            // Through hole
            translate([xh, yh, -1])
                cylinder(d=mount_hole_d, h=block_z+2);

            // Counterbore (top)
            translate([xh, yh, block_z - mount_counterbore_h])
                cylinder(d=mount_counterbore_d, h=mount_counterbore_h+1);
        }

        // Clamp screw holes across X (2x), placed near ends along Y
        for (sy = [-1, 1]){
            yh = sy*clamp_y_offset;

            // Through hole across X
            translate([0, yh, block_z*0.72])
                rotate([0,90,0])
                    cylinder(d=clamp_hole_d, h=block_x+2, center=true);

            // Counterbore on +X side
            translate([block_x/2 - clamp_head_h, yh, block_z*0.72])
                rotate([0,90,0])
                    cylinder(d=clamp_head_d, h=clamp_head_h+1, center=false);
        }

        // Lightening pockets (optional, shallow) on sides
        pocket_depth = 4.0;
        pocket_margin_y = 10.0;
        pocket_z0 = 6.0;
        pocket_z1 = block_z - 6.0;

        for (sx = [-1, 1]){
            translate([sx*(block_x/2 - pocket_depth/2), 0, (pocket_z0+pocket_z1)/2])
                cube([pocket_depth, block_y - 2*pocket_margin_y, (pocket_z1-pocket_z0)], center=true);
        }
    }
}

bearing_block();