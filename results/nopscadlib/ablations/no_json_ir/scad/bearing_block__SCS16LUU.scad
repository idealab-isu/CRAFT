$fn = 96;

// Target: long linear bearing block for 9.0mm shaft
shaft_d = 9.0;

// Overall block size (X x Y)
block_w = 50.0;   // X
block_l = 85.0;   // Y
block_h = 20.0;   // Z

// Mounting (4x through holes)
mount_hole_d = 5.0;
mount_x_spacing = 36.0;   // within 50mm width
mount_y_spacing = 60.0;   // within 85mm length
mount_edge_margin_x = (block_w - mount_x_spacing)/2;
mount_edge_margin_y = (block_l - mount_y_spacing)/2;

// Bearing seat + clamp features (SCS/SBR style approximation)
seat_d = shaft_d + 10.0;          // outer "bearing seat" diameter
seat_center_z = 0;                // shaft axis at mid-height
top_open_slot_w = shaft_d + 2.0;  // opening to allow clamp
slot_depth_from_top = block_h/2 - seat_center_z; // from top face down to axis
clamp_gap_w = 2.0;                // split gap width
clamp_bolt_d = 4.0;
clamp_bolt_head_d = 8.0;
clamp_bolt_head_h = 3.0;
clamp_bolt_y_offset = block_l*0.22; // two clamp bolts along length

// Edge rounding/chamfer (simple)
corner_r = 2.0;

// Helpers
module rounded_block(size=[10,10,10], r=1) {
    // Minkowski rounding; keep r small for performance
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=true);
        sphere(r=r);
    }
}

module mounting_holes() {
    for (sx = [-1, 1])
        for (sy = [-1, 1])
            translate([sx*mount_x_spacing/2, sy*mount_y_spacing/2, 0])
                cylinder(h=block_h+2, d=mount_hole_d, center=true);
}

module clamp_bolts_and_counterbores() {
    // Two bolts across the split (along X), placed near top
    // Through holes go across X; counterbore on +X side.
    for (sy = [-1, 1]) {
        translate([0, sy*clamp_bolt_y_offset, block_h/2 - 6])
            rotate([0, 90, 0]) {
                // through hole
                cylinder(h=block_w+2, d=clamp_bolt_d, center=true);
                // counterbore on +X side
                translate([block_w/2 - clamp_bolt_head_h/2, 0, 0])
                    cylinder(h=clamp_bolt_head_h+0.2, d=clamp_bolt_head_d, center=true);
            }
    }
}

module bearing_bore_and_seat() {
    // Main shaft bore (along Y)
    translate([0, 0, seat_center_z])
        rotate([90, 0, 0])
            cylinder(h=block_l+2, d=shaft_d, center=true);

    // Larger seat pocket (partial depth from top) to resemble bearing insert area
    // Cut a larger cylinder but only in upper portion using intersection.
    intersection() {
        translate([0, 0, seat_center_z])
            rotate([90, 0, 0])
                cylinder(h=block_l+2, d=seat_d, center=true);

        // Limit to upper region (from axis upward), leaving material below
        translate([0, 0, (seat_center_z + block_h/2)/2])
            cube([block_w+2, block_l+2, block_h/2 - seat_center_z + 0.2], center=true);
    }

    // Top opening slot down to the bore (along Y)
    // Slot starts at top face and goes down slightly past axis for clearance.
    slot_h = slot_depth_from_top + 1.0;
    translate([0, 0, block_h/2 - slot_h/2])
        cube([top_open_slot_w, block_l+2, slot_h], center=true);

    // Split clamp gap (along Y), only in upper portion so block stays robust
    gap_h = block_h/2 + 0.5;
    translate([0, 0, block_h/2 - gap_h/2])
        cube([clamp_gap_w, block_l+2, gap_h], center=true);
}

module bottom_relief() {
    // Shallow underside relief to look like a bearing block base
    relief_w = block_w - 2*6;
    relief_l = block_l - 2*8;
    relief_h = 2.0;

    translate([0, 0, -block_h/2 + relief_h/2])
        cube([relief_w, relief_l, relief_h], center=true);
}

module sbr9_long_bearing_block() {
    difference() {
        // Main body (rounded edges)
        rounded_block([block_w, block_l, block_h], r=corner_r);

        // Functional cuts
        bearing_bore_and_seat();
        mounting_holes();
        clamp_bolts_and_counterbores();
        bottom_relief();
    }
}

// Render
sbr9_long_bearing_block();