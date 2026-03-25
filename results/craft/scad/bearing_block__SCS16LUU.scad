$fn = 96;

// Parameters
shaft_diameter_mm = 9.0; //[4.5:18.0:0.1]
block_width_mm = 50.0; //[25.0:100.0:0.5]     // X
block_length_mm = 85.0; //[42.5:170.0:0.5]    // Y
block_height_mm = 30.0; //[15.0:60.0:0.5]     // Z

bearing_bore_diameter_mm = 9.2; //[9.0:10.0:0.05]
bearing_bore_length_mm = 80.0; //[40.0:120.0:0.5]

mount_hole_diameter_mm = 5.5; //[3.0:8.0:0.1]
mount_hole_edge_margin_mm = 8.0; //[4.0:16.0:0.5]
mount_hole_counterbore_diameter_mm = 10.0; //[7.0:16.0:0.5]
mount_hole_counterbore_depth_mm = 4.0; //[1.0:10.0:0.5]

retention_slit_width_mm = 1.5; //[0.5:3.0:0.1]
retention_slit_depth_to_bore_mm = 1.0; //[0.5:3.0:0.1]
retention_screw_hole_diameter_mm = 3.3; //[2.0:6.0:0.1]
retention_screw_head_counterbore_diameter_mm = 6.5; //[4.0:12.0:0.1]
retention_screw_head_counterbore_depth_mm = 4.0; //[1.0:10.0:0.5]
retention_screw_y_offset_mm = 0.0; //[-20.0:20.0:0.5]

overlap_mm = 1.0; //[0.5:2.0:0.1]

// Derived
bore_r = bearing_bore_diameter_mm/2;

// Place bore along Y, centered in X, and slightly above mid-height (typical pillow/linear block feel)
bore_axis_z = 0; // keep centered to guarantee wall thickness symmetry and easy verification

// Safety clamps to keep geometry valid
min_wall_mm = 3.0;
bore_axis_z_clamped = clamp(bore_axis_z,
                            -block_height_mm/2 + min_wall_mm + bore_r,
                             block_height_mm/2 - min_wall_mm - bore_r);

module long_linear_bearing_block() {
  color("Silver")
  difference() {
    // ONE connected solid body (50 x 85 x 30)
    cube([block_width_mm, block_length_mm, block_height_mm], center=true);

    // Cylindrical bore/seat for 9mm shaft (along Y)
    translate([0, 0, bore_axis_z_clamped])
      rotate([90, 0, 0])
        cylinder(r=bore_r,
                 h=bearing_bore_length_mm + 2*overlap_mm,
                 center=true);

    // Mounting holes + counterbores from top face
    mounting_holes_with_counterbores();

    // Retention slit + clamp screw (cuts only; body remains connected)
    retention_feature();
  }
}

module mounting_holes_with_counterbores() {
  for (sx = [-1, 1])
    for (sy = [-1, 1]) {
      x_pos = sx * (block_width_mm/2 - mount_hole_edge_margin_mm);
      y_pos = sy * (block_length_mm/2 - mount_hole_edge_margin_mm);

      // Through hole (Z axis)
      translate([x_pos, y_pos, 0])
        cylinder(r=mount_hole_diameter_mm/2,
                 h=block_height_mm + 2*overlap_mm,
                 center=true);

      // Counterbore from top face
      translate([x_pos, y_pos,
                 block_height_mm/2 - mount_hole_counterbore_depth_mm/2 + overlap_mm/2])
        cylinder(r=mount_hole_counterbore_diameter_mm/2,
                 h=mount_hole_counterbore_depth_mm + overlap_mm,
                 center=true);
    }
}

module retention_feature() {
  // Slit from top down toward bore (do not cut through entire block)
  // Bottom of slit stops retention_slit_depth_to_bore_mm above the bore top.
  bore_top_z = bore_axis_z_clamped + bore_r;
  slit_bottom_z = bore_top_z + retention_slit_depth_to_bore_mm;

  // Clamp slit bottom to remain inside the block
  slit_bottom_z_clamped = min(block_height_mm/2 - min_wall_mm, slit_bottom_z);

  slit_depth = (block_height_mm/2) - slit_bottom_z_clamped;
  slit_depth_clamped = max(0.1, slit_depth);

  // Slit centered in X, runs full Y
  translate([0,
             0,
             block_height_mm/2 - slit_depth_clamped/2 + overlap_mm/2])
    cube([retention_slit_width_mm,
          block_length_mm + 2*overlap_mm,
          slit_depth_clamped + overlap_mm],
         center=true);

  // Clamp screw across X, located above bore and below top wall
  screw_z_target = bore_top_z + max(2.0, retention_slit_depth_to_bore_mm + 1.0);
  screw_z = clamp(screw_z_target,
                  bore_top_z + 1.0,
                  block_height_mm/2 - min_wall_mm);

  translate([0, retention_screw_y_offset_mm, screw_z])
    rotate([0, 90, 0])
      cylinder(r=retention_screw_hole_diameter_mm/2,
               h=block_width_mm + 2*overlap_mm,
               center=true);

  // Screw head counterbore on +X side
  translate([block_width_mm/2 - retention_screw_head_counterbore_depth_mm/2 + overlap_mm/2,
             retention_screw_y_offset_mm,
             screw_z])
    rotate([0, 90, 0])
      cylinder(r=retention_screw_head_counterbore_diameter_mm/2,
               h=retention_screw_head_counterbore_depth_mm + overlap_mm,
               center=true);
}

// Output: ONE connected solid
long_linear_bearing_block();