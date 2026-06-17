// Parameters
shaft_diameter = 8.0; //[4.0:16.0:0.1]
block_width = 40.0; //[20.0:80.0:0.5]
block_length = 68.0; //[34.0:136.0:0.5]
block_height = 28.0; //[14.0:56.0:0.5]
bearing_outer_diameter = 15.0; //[10.0:30.0:0.1]
bearing_length = 24.0; //[12.0:48.0:0.5]
bore_clearance = 0.1; //[0.0:0.5:0.05]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x = 28.0; //[14.0:56.0:0.5]
mount_hole_spacing_y = 50.0; //[25.0:100.0:0.5]
edge_margin = 4.0; //[2.0:10.0:0.5]
counterbore_diameter = 9.0; //[6.0:16.0:0.1]
counterbore_depth = 4.0; //[2.0:10.0:0.5]
clamp_screw_diameter = 4.2; //[3.0:6.5:0.1]
clamp_screw_head_diameter = 7.5; //[5.5:12.0:0.1]
clamp_screw_head_depth = 3.0; //[1.5:8.0:0.5]
clamp_slot_width = 2.0; //[1.0:5.0:0.1]
retention_shoulder_thickness = 2.0; //[1.0:5.0:0.5]
retention_shoulder_diameter = 13.0; //[9.0:25.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  union() {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_x / 2, y * mount_hole_spacing_y / 2, 0])
          cylinder(r = mount_hole_diameter / 2, h = block_height + 2 * overlap, center = true);
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_x / 2, y * mount_hole_spacing_y / 2, -block_height / 2 + counterbore_depth / 2])
          cylinder(r = counterbore_diameter / 2, h = counterbore_depth + overlap, center = true);
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  difference() {
    cube([block_width, block_length, block_height], center = true);
    translate([0, 0, 0])
      rotate([90, 0, 0])
      cylinder(r = bearing_outer_diameter / 2, h = block_length + 2 * overlap, center = true);
    translate([0, 0, 0])
      rotate([90, 0, 0])
      cylinder(r = (shaft_diameter + bore_clearance) / 2, h = block_length + 2 * overlap, center = true);
    scs_bearing_block_hole_positions();
    union() {
      translate([0, block_length / 2 - retention_shoulder_thickness / 2, 0])
        rotate([90, 0, 0])
        cylinder(r = retention_shoulder_diameter / 2, h = retention_shoulder_thickness + 2 * overlap, center = true);
      translate([0, -block_length / 2 + retention_shoulder_thickness / 2, 0])
        rotate([90, 0, 0])
        cylinder(r = retention_shoulder_diameter / 2, h = retention_shoulder_thickness + 2 * overlap, center = true);
    }
    union() {
      translate([0, 0, 0])
        cube([clamp_slot_width, block_length + 2 * overlap, block_height + 2 * overlap], center = true);
      for (y = [-1, 1]) {
        translate([0, y * block_length / 4, bearing_outer_diameter / 2 + (block_height / 2 - bearing_outer_diameter / 2) / 2])
          rotate([0, 90, 0])
          cylinder(r = clamp_screw_diameter / 2, h = block_width + 2 * overlap, center = true);
        translate([block_width / 2 - clamp_screw_head_depth / 2, y * block_length / 4, bearing_outer_diameter / 2 + (block_height / 2 - bearing_outer_diameter / 2) / 2])
          rotate([0, 90, 0])
          cylinder(r = clamp_screw_head_diameter / 2, h = clamp_screw_head_depth + overlap, center = true);
      }
    }
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  scs_bearing_block();
}

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  sbr_bearing_block();
}

// Final Assembly
module assembly() {
  sbr_bearing_block_assembly();
}

assembly();