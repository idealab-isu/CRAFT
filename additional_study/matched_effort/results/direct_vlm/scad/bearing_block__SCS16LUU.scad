$fn = 128;

// Long linear bearing block for 9.0mm shaft
// Overall block size: 50.0mm (X) x 85.0mm (Y) x 30.0mm (Z)

block_x = 50.0;
block_y = 85.0;
block_z = 30.0;

shaft_d = 9.0;
shaft_clear = 0.35;                 // clearance on diameter
shaft_hole_d = shaft_d + shaft_clear;

// Mounting holes (4-hole pattern)
mount_hole_d = 5.5;                 // for M5 clearance
mount_counterbore_d = 10.0;         // counterbore diameter
mount_counterbore_depth = 4.0;

edge_x = 10.0;                      // distance from X edges to hole centers
edge_y = 12.0;                      // distance from Y edges to hole centers

// Bearing block features
slot_open = true;                   // open-top shaft channel (typical pillow/linear block style)
slot_w = 3.0;                       // width of opening at top (X direction)
seat_extra_d = 2.0;                 // extra diameter for bearing seat pocket (visual/retainer)
seat_depth = 10.0;                  // depth from top face into block
end_relief_len = 12.0;              // relief length at each end along Y
end_relief_extra_d = 1.0;           // extra diameter at ends for easier insertion

// Bottom relief pocket (kept shallow so part stays strong)
relief_w = 22.0;                    // X width
relief_h = 10.0;                    // Z height
relief_y_margin = 10.0;             // keep ends solid

// Outer edge fillet approximation
fillet_r = 1.5;

eps = 0.02;

module rounded_block(x,y,z,r){
    minkowski(){
        cube([x-2*r, y-2*r, z-2*r], center=true);
        sphere(r=r);
    }
}

module bearing_block(){
    difference(){
        // Body
        rounded_block(block_x, block_y, block_z, fillet_r);

        // Main shaft bore along Y axis
        rotate([90,0,0])
            cylinder(d=shaft_hole_d, h=block_y + 2, center=true);

        // Entry chamfers on both ends of the bore (at +/-Y faces)
        chamfer_h = 2.0;
        chamfer_d = 2.0;
        for (sy = [-1, 1]){
            translate([0, sy*(block_y/2 - chamfer_h), 0])
                rotate([90,0,0])
                    cylinder(d1=shaft_hole_d + chamfer_d, d2=shaft_hole_d,
                             h=chamfer_h + eps, center=false);
        }

        // End reliefs (slightly larger bore near both ends)
        for (sy = [-1, 1]){
            translate([0, sy*(block_y/2 - end_relief_len/2), 0])
                rotate([90,0,0])
                    cylinder(d=shaft_hole_d + end_relief_extra_d,
                             h=end_relief_len + eps, center=true);
        }

        // Top bearing seat pocket (retainer area) - larger diameter, shallow depth from top
        translate([0, 0, block_z/2 - seat_depth/2])
            rotate([90,0,0])
                cylinder(d=shaft_hole_d + seat_extra_d, h=block_y + 2, center=true);

        // Open-top slot to create a shaft channel (connects to bore and seat pocket)
        if (slot_open){
            // Slot runs full length; depth reaches slightly below bore center to ensure opening
            slot_depth = block_z/2 + shaft_hole_d/2 + 0.5;
            translate([0, 0, block_z/2 - slot_depth/2])
                cube([slot_w, block_y + 2, slot_depth + eps], center=true);
        }

        // Mounting holes + counterbores from top face (+Z)
        for (sx = [-1, 1], sy = [-1, 1]){
            xh = sx*(block_x/2 - edge_x);
            yh = sy*(block_y/2 - edge_y);

            // Through hole
            translate([xh, yh, 0])
                cylinder(d=mount_hole_d, h=block_z + 2, center=true);

            // Counterbore from top
            translate([xh, yh, block_z/2 - mount_counterbore_depth/2])
                cylinder(d=mount_counterbore_d,
                         h=mount_counterbore_depth + eps, center=true);
        }

        // Bottom relief pocket (does not break through)
        translate([0, 0, -block_z/2 + relief_h/2])
            cube([relief_w, block_y - 2*relief_y_margin, relief_h], center=true);
    }
}

bearing_block();