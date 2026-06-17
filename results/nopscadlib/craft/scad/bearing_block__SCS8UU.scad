// Linear bearing block for 6.0mm shaft
// Block size: 34.0mm x 30.0mm x 20.0mm
// One connected solid (single printable part) with through bore and 4 mounting holes.

shaft_diameter_mm = 6;                 // shaft through-hole
block_length_mm = 34;                  // X
block_width_mm  = 30;                  // Y
block_height_mm = 20;                  // Z

// Optional larger seat around shaft (typical for LM6UU-style insert)
bearing_outer_diameter_mm = 12;        // seat diameter
bearing_seat_fit_clearance_mm = -0.1;  // negative = tighter seat

mount_hole_diameter_mm = 4.2;
mount_hole_spacing_x_mm = 24;
mount_hole_spacing_y_mm = 20;

mount_hole_counterbore_enabled = true;
mount_hole_counterbore_diameter_mm = 8;
mount_hole_counterbore_depth_mm = 3;

clamp_slot_enabled = true;
clamp_slot_width_mm = 2;
clamp_slot_length_mm = 16;
clamp_slot_offset_from_top_mm = 3;

clamp_screw_diameter_mm = 3.2;
clamp_screw_head_diameter_mm = 6;
clamp_screw_head_depth_mm = 2.5;

corner_fillet_radius_mm = 1.5; // simple edge softening via minkowski (kept small)
eps_mm = 0.4;

$fn = 64;

// Rounded block helper (keeps exact outer size by shrinking then minkowski)
module rounded_block(size=[10,10,10], r=1) {
    r2 = max(0, min(r, min(size[0], min(size[1], size[2]))/2 - 0.01));
    if (r2 <= 0) {
        cube(size, center=true);
    } else {
        minkowski() {
            cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=true);
            sphere(r=r2);
        }
    }
}

module bearing_block() {
    difference() {
        // Main body (single solid)
        rounded_block([block_length_mm, block_width_mm, block_height_mm], corner_fillet_radius_mm);

        // Through shaft bore along X (full pass-through)
        cylinder(r=shaft_diameter_mm/2 + 0.15,
                 h=block_length_mm + 2*eps_mm,
                 center=true);

        // Bearing seat (also along X), limited to central region (not full length)
        // Seat length chosen to be inside the block with margins.
        seat_len = min(block_length_mm - 6, 19); // typical insert length, but never exceeds block
        cylinder(r=(bearing_outer_diameter_mm + bearing_seat_fit_clearance_mm)/2,
                 h=seat_len + 2*eps_mm,
                 center=true);

        // Mounting holes (through Z)
        for (x = [-mount_hole_spacing_x_mm/2, mount_hole_spacing_x_mm/2])
            for (y = [-mount_hole_spacing_y_mm/2, mount_hole_spacing_y_mm/2])
                translate([x, y, 0])
                    rotate([90,0,0]) // keep cylinder axis along Y? No: we want along Z, so no rotate.
                        children();

        // (Implement holes without children() to avoid confusion)
        for (x = [-mount_hole_spacing_x_mm/2, mount_hole_spacing_x_mm/2])
            for (y = [-mount_hole_spacing_y_mm/2, mount_hole_spacing_y_mm/2])
                translate([x, y, 0])
                    cylinder(r=mount_hole_diameter_mm/2,
                             h=block_height_mm + 2*eps_mm,
                             center=true,
                             $fn=40);

        // Counterbores from top face (Z+)
        if (mount_hole_counterbore_enabled) {
            for (x = [-mount_hole_spacing_x_mm/2, mount_hole_spacing_x_mm/2])
                for (y = [-mount_hole_spacing_y_mm/2, mount_hole_spacing_y_mm/2])
                    translate([x, y, block_height_mm/2 - mount_hole_counterbore_depth_mm/2])
                        cylinder(r=mount_hole_counterbore_diameter_mm/2,
                                 h=mount_hole_counterbore_depth_mm + eps_mm,
                                 center=true,
                                 $fn=48);
        }

        // Clamp slot (cuts from top down, across X)
        if (clamp_slot_enabled) {
            slot_zc = block_height_mm/2 - clamp_slot_offset_from_top_mm - (block_height_mm/2)/2;
            // Make slot reach from top surface into body; keep it fully inside by using a tall cutter.
            translate([0, 0, block_height_mm/2 - clamp_slot_offset_from_top_mm])
                cube([clamp_slot_length_mm, clamp_slot_width_mm, block_height_mm + 2*eps_mm], center=true);

            // Clamp screw clearance (along Y, through the slot region)
            translate([0, 0, block_height_mm/2 - clamp_slot_offset_from_top_mm])
                rotate([90, 0, 0])
                    cylinder(r=clamp_screw_diameter_mm/2,
                             h=block_width_mm + 2*eps_mm,
                             center=true,
                             $fn=36);

            // Clamp screw head clearance from +Y side (counterbore pocket)
            translate([0,
                       block_width_mm/2 - clamp_screw_head_depth_mm/2,
                       block_height_mm/2 - clamp_slot_offset_from_top_mm])
                rotate([90, 0, 0])
                    cylinder(r=clamp_screw_head_diameter_mm/2,
                             h=clamp_screw_head_depth_mm + eps_mm,
                             center=true,
                             $fn=48);
        }
    }
}

bearing_block();