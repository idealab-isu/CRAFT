// Linear bearing block for 9.0mm shaft
// Block size: 50.0mm (X) x 44.0mm (Y) x 30.0mm (Z)
// One connected solid (all features are subtractive; no floating parts)

// -------------------- Parameters --------------------
shaft_diameter_mm = 9.0; //[4.5:18.0:0.1]
block_length_mm   = 50.0; //[25.0:100.0:0.5]   // X
block_width_mm    = 44.0; //[22.0:88.0:0.5]    // Y
block_height_mm   = 30.0; //[15.0:60.0:0.5]    // Z

bore_clearance_mm = 0.10; //[0.0:0.5:0.01]

// Bearing pocket (outer housing) around the shaft bore
bearing_outer_diameter_mm = 16.0; //[10.0:30.0:0.1]
bearing_length_mm = 30.0; //[15.0:60.0:0.5]
bearing_pocket_clearance_mm = 0.20; //[0.0:0.6:0.01]

// Mounting holes (through Z) + counterbores from top
mount_hole_diameter_mm = 5.0; //[2.5:10.0:0.1]
mount_hole_spacing_x_mm = 36.0; //[18.0:72.0:0.5]
mount_hole_spacing_y_mm = 30.0; //[15.0:60.0:0.5]
mount_counterbore_diameter_mm = 9.0; //[5.0:18.0:0.1]
mount_counterbore_depth_mm = 4.0; //[1.0:10.0:0.1]

// Clamp slit (opens from top down to the bore region)
clamp_slit_width_mm  = 1.5; //[0.5:4.0:0.1]
clamp_slit_depth_mm  = 12.0; //[6.0:24.0:0.5]
clamp_slit_length_mm = 18.0; //[8.0:36.0:0.5]

corner_radius_mm = 2.0; //[0.5:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 96;

// -------------------- Helpers --------------------
module rounded_box_xy(size=[10,10,10], r=1) {
    // Rounded in XY, straight in Z
    sx=size[0]; sy=size[1]; sz=size[2];
    r2 = min(r, min(sx,sy)/2);
    linear_extrude(height=sz, center=true)
        offset(r=r2)
            square([sx-2*r2, sy-2*r2], center=true);
}

module mount_holes_and_counterbores() {
    // Through holes + top counterbores (subtractive)
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2, 0])
            cylinder(d=mount_hole_diameter_mm,
                     h=block_height_mm + 2*overlap_mm, center=true);

        // Counterbore from top face down
        translate([sx*mount_hole_spacing_x_mm/2, sy*mount_hole_spacing_y_mm/2,
                   block_height_mm/2 - mount_counterbore_depth_mm/2 + overlap_mm/2])
            cylinder(d=mount_counterbore_diameter_mm,
                     h=mount_counterbore_depth_mm + overlap_mm, center=true);
    }
}

module bearing_bore_and_pocket() {
    // Ensure pocket is not longer than the block
    pocket_len = min(bearing_length_mm, block_length_mm - 2*corner_radius_mm);
    pocket_len2 = max(pocket_len, shaft_diameter_mm); // keep sane

    // Shaft bore (through X)
    rotate([0,90,0])
        cylinder(d=shaft_diameter_mm + bore_clearance_mm,
                 h=block_length_mm + 2*overlap_mm, center=true);

    // Bearing pocket (shorter along X, centered)
    rotate([0,90,0])
        cylinder(d=bearing_outer_diameter_mm + bearing_pocket_clearance_mm,
                 h=pocket_len2 + 2*overlap_mm, center=true);
}

module clamp_slit() {
    // Slit from top down to allow clamping around the bore/pocket
    // Starts at top face and goes down by clamp_slit_depth_mm
    translate([0, 0,
               block_height_mm/2 - clamp_slit_depth_mm/2 + overlap_mm/2])
        cube([clamp_slit_length_mm,
              clamp_slit_width_mm,
              clamp_slit_depth_mm + overlap_mm],
             center=true);
}

// -------------------- Main Model --------------------
module linear_bearing_block_9mm() {
    difference() {
        // Main block body (rounded corners in XY)
        rounded_box_xy([block_length_mm, block_width_mm, block_height_mm], r=corner_radius_mm);

        // Functional features (all subtractive, connected solid remains)
        bearing_bore_and_pocket();
        mount_holes_and_counterbores();
        clamp_slit();
    }
}

linear_bearing_block_9mm();