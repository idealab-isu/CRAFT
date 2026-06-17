$fn = 96;

// Overall block dimensions (X x Y x Z)
block_x = 8.0;
block_y = 10.2;
block_z = 15.0;

// Feature parameters (kept within the block)
bore_d = 4.2;                 // leadscrew/nut bore
counterbore_d = 6.6;          // top pocket for nut flange
counterbore_h = 3.0;

mount_hole_d = 2.2;           // mounting holes
mount_head_d = 4.0;           // shallow head recess
mount_head_h = 1.2;

edge_margin_y = 2.0;

slot_w = 2.0;                 // side access slot to bore
slot_h = 7.0;
slot_depth = 1.6;

eps = 0.02;

// Derived placement (ensure holes stay inside the block)
mount_y_offset = max(0, block_y/2 - edge_margin_y);

difference() {
    // Main housing block (rectangular, correct overall size)
    cube([block_x, block_y, block_z], center=false);

    // Central bore through full height
    translate([block_x/2, block_y/2, -eps])
        cylinder(d=bore_d, h=block_z + 2*eps, center=false);

    // Top counterbore pocket
    translate([block_x/2, block_y/2, block_z - counterbore_h - eps])
        cylinder(d=counterbore_d, h=counterbore_h + 2*eps, center=false);

    // Two mounting holes through height (along Y, symmetric about center)
    for (sy = [-1, 1]) {
        y_pos = block_y/2 + sy * mount_y_offset;

        translate([block_x/2, y_pos, -eps])
            cylinder(d=mount_hole_d, h=block_z + 2*eps, center=false);

        // Shallow head recess on top
        translate([block_x/2, y_pos, block_z - mount_head_h - eps])
            cylinder(d=mount_head_d, h=mount_head_h + 2*eps, center=false);
    }

    // Side access slot from +X face into the bore area
    translate([block_x - slot_depth - eps, block_y/2 - slot_w/2, (block_z - slot_h)/2])
        cube([slot_depth + 2*eps, slot_w, slot_h], center=false);

    // Bottom relief pocket (kept inside block; does not remove entire bottom)
    relief_h = 1.0;
    relief_x = max(0, block_x - 2*slot_depth);
    relief_y = max(0, block_y - 2*edge_margin_y);
    translate([(block_x - relief_x)/2, (block_y - relief_y)/2, -eps])
        cube([relief_x, relief_y, relief_h + 2*eps], center=false);
}