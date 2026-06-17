// Long linear bearing block for 8.0mm shaft
// Block size: 42.0mm (X) x 70.0mm (Y) x 28.0mm (Z)

// Parameters
shaft_diameter_mm = 8.0; //[4.0:16.0:0.1]
block_width_mm = 42.0; //[21.0:84.0:0.5]     // X
block_length_mm = 70.0; //[35.0:140.0:0.5]   // Y
block_height_mm = 28.0; //[14.0:56.0:0.5]    // Z

bearing_outer_diameter_mm = 15.0; //[10.0:30.0:0.1]
bearing_length_mm = 24.0; //[12.0:48.0:0.5]

shaft_bore_clearance_mm = 0.1; //[0.0:0.5:0.05]
bearing_seat_clearance_mm = 0.1; //[0.0:0.5:0.05]

mount_hole_diameter_mm = 5.0; //[3.0:8.0:0.1]
mount_hole_counterbore_diameter_mm = 9.0; //[6.0:14.0:0.1]
mount_hole_counterbore_depth_mm = 4.0; //[2.0:10.0:0.1]
mount_hole_spacing_x_mm = 28.0; //[14.0:56.0:0.5]
mount_hole_spacing_y_mm = 50.0; //[25.0:100.0:0.5]

retention_method = 0; //[0:1:1]
retention_lip_depth_mm = 1.5; //[0.5:3.0:0.1]
retention_lip_thickness_mm = 1.0; //[0.5:2.5:0.1]

seat_extra_depth_mm = 2.0; //[0.5:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 96;

// Derived
shaft_r = (shaft_diameter_mm + shaft_bore_clearance_mm)/2;
seat_r  = (bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2;

// Bore axis along X (shaft passes left-right)
bore_axis_rot = [0, 90, 0];

// Bearing seat length (along X) - ensure it doesn't exceed block width
seat_len = min(bearing_length_mm + seat_extra_depth_mm, block_width_mm - 2);
seat_len = max(seat_len, 1);

// --- Added: corner inserts/bushings (physically attached) ---
insert_outer_d_mm = mount_hole_counterbore_diameter_mm; // match counterbore OD visually
insert_inner_d_mm = mount_hole_diameter_mm;             // through-hole ID
insert_height_mm  = mount_hole_counterbore_depth_mm + 2.0; // visible bushing height
insert_overlap_mm = 1.5; // 1-2mm overlap into the main body to guarantee fusion

module corner_inserts() {
    for (sx = [-1, 1])
        for (sy = [-1, 1]) {
            x = sx * mount_hole_spacing_x_mm/2;
            y = sy * mount_hole_spacing_y_mm/2;

            // Place on top face, but sink into body by insert_overlap_mm so it fuses (no gap)
            z = block_height_mm/2 + insert_height_mm/2 - insert_overlap_mm;

            translate([x, y, z])
                difference() {
                    cylinder(h=insert_height_mm, r=insert_outer_d_mm/2, center=true);
                    // Ensure the insert's hole aligns and fully opens through the insert
                    cylinder(h=insert_height_mm + 2*overlap_mm, r=insert_inner_d_mm/2, center=true);
                }
        }
}

// Helper: mounting holes (through Z) + counterbores from top face
module mount_holes() {
    for (sx = [-1, 1])
        for (sy = [-1, 1]) {
            x = sx * mount_hole_spacing_x_mm/2;
            y = sy * mount_hole_spacing_y_mm/2;

            // Through hole
            translate([x, y, 0])
                cylinder(h=block_height_mm + 2*overlap_mm,
                         r=mount_hole_diameter_mm/2,
                         center=true);

            // Counterbore from top face (Z+)
            translate([x, y, block_height_mm/2 - mount_hole_counterbore_depth_mm/2 + overlap_mm/2])
                cylinder(h=mount_hole_counterbore_depth_mm + overlap_mm,
                         r=mount_hole_counterbore_diameter_mm/2,
                         center=true);
        }
}

// Main block with verifiable features
module bearing_block() {
    union() {
        // Main body with cutouts
        difference() {
            // Solid body
            cube([block_width_mm, block_length_mm, block_height_mm], center=true);

            // Shaft bore (through along X)
            rotate(bore_axis_rot)
                cylinder(h=block_width_mm + 2*overlap_mm, r=shaft_r, center=true);

            // Bearing seat (shorter along X, larger diameter)
            rotate(bore_axis_rot)
                cylinder(h=seat_len, r=seat_r, center=true);

            // Optional retention lip: leave a small ring at both ends of the seat
            if (retention_method == 1) {
                inner_r = max(seat_r - retention_lip_thickness_mm, shaft_r + 0.2);
                inner_len = max(seat_len - 2*retention_lip_depth_mm, 0.1);

                rotate(bore_axis_rot)
                    cylinder(h=inner_len, r=inner_r, center=true);
            }

            // Mounting holes + counterbores
            mount_holes();

            // Side relief window (open from +Z/top into bore region)
            window_depth_z = block_height_mm * 0.60;
            window_len_y   = min(block_length_mm * 0.70, block_length_mm - 6);
            window_w_x     = min(seat_len * 0.90, block_width_mm - 6);

            translate([0, 0, block_height_mm/2 - window_depth_z/2 + overlap_mm/2])
                cube([window_w_x, window_len_y, window_depth_z + overlap_mm], center=true);

            // Clamp split (thin slot) from top to the bore, along Y, centered on X=0
            split_w_x = max(1.2, shaft_diameter_mm * 0.18);
            split_len_y = block_length_mm - 6;
            split_depth_z = block_height_mm/2 + seat_r + 1.0;

            translate([0, 0, block_height_mm/2 - split_depth_z/2 + overlap_mm/2])
                cube([split_w_x, split_len_y, split_depth_z + overlap_mm], center=true);
        }

        // Add the four corner cylindrical inserts/bushings and fuse them to the body
        corner_inserts();
    }
}

// Final
bearing_block();