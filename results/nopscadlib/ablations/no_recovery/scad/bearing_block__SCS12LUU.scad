// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
block_width_mm = 42; //[21:84:0.5]
block_length_mm = 70; //[35:140:0.5]
block_height_mm = 28; //[14:56:0.5]
bearing_outer_diameter_mm = 15; //[10:30:0.1]
bearing_length_mm = 24; //[12:48:0.5]
bearing_seat_clearance_mm = 0.1; //[0:0.4:0.01]
shaft_clearance_mm = 0.2; //[0:0.6:0.01]
mounting_hole_diameter_mm = 5.5; //[3:8:0.1]
counterbore_diameter_mm = 10; //[6:16:0.1]
counterbore_depth_mm = 4; //[2:10:0.1]
edge_margin_mm = 7; //[4:14:0.5]
retention_shoulder_depth_mm = 1.5; //[0.5:4:0.1]
bore_overlap_mm = 1; //[0.5:2:0.1]
clamp_style_split = 1; //[0:1:1]
clamp_slot_width_mm = 2; //[0.5:4:0.1]
clamp_slot_height_mm = 18; //[8:26:0.5]
clamp_screw_diameter_mm = 4.5; //[3:6:0.1]
clamp_boss_diameter_mm = 12; //[8:20:0.5]
clamp_boss_length_mm = 10; //[6:20:0.5]

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    // Block body
    difference() {
      cube([block_width_mm, block_length_mm, block_height_mm], center=true);
      // Shaft bore
      translate([0, 0, 0])
        rotate([90, 0, 0])
        cylinder(h=block_length_mm + 2*bore_overlap_mm, r=(shaft_diameter_mm + shaft_clearance_mm)/2, center=true);
      // Bearing seat
      translate([0, 0, 0])
        rotate([90, 0, 0])
        cylinder(h=bearing_length_mm + 2*bore_overlap_mm, r=(bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2, center=true);
      // Split clamp slot
      if (clamp_style_split == 1) {
        translate([0, 0, block_height_mm/2 - clamp_slot_height_mm/2])
          cube([clamp_slot_width_mm, block_length_mm + 2*bore_overlap_mm, clamp_slot_height_mm], center=true);
      }
    }
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (block_width_mm/2 - edge_margin_mm), y * (block_length_mm/2 - edge_margin_mm), 0])
        cylinder(h=block_height_mm + 2*bore_overlap_mm, r=mounting_hole_diameter_mm/2, center=true);
      translate([x * (block_width_mm/2 - edge_margin_mm), y * (block_length_mm/2 - edge_margin_mm), -(block_height_mm/2) + (counterbore_depth_mm + bore_overlap_mm)/2])
        cylinder(h=counterbore_depth_mm + bore_overlap_mm, r=counterbore_diameter_mm/2, center=true);
    }
    // Retention shoulders
    for (y = [-1, 1]) {
      translate([0, y * (bearing_length_mm/2 + retention_shoulder_depth_mm/2), 0])
        rotate([90, 0, 0])
        cylinder(h=retention_shoulder_depth_mm + bore_overlap_mm, r=(bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2, center=true);
    }
    // Clamp bosses
    if (clamp_style_split == 1) {
      for (x = [-1, 1]) {
        translate([x * (block_width_mm/2 + clamp_boss_diameter_mm/2 - bore_overlap_mm), 0, block_height_mm/2 - clamp_slot_height_mm + clamp_boss_diameter_mm/2])
          rotate([90, 0, 0])
          cylinder(h=clamp_boss_length_mm, r=clamp_boss_diameter_mm/2, center=true);
        translate([x * (block_width_mm/2 + clamp_boss_diameter_mm/2 - bore_overlap_mm), 0, block_height_mm/2 - clamp_slot_height_mm + clamp_boss_diameter_mm/2])
          rotate([0, 90, 0])
          cylinder(h=clamp_boss_diameter_mm + block_width_mm + 2*bore_overlap_mm, r=clamp_screw_diameter_mm/2, center=true);
      }
    }
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("DimGray") {
    // Placeholder for SCS bearing block geometry
    // Implement detailed geometry based on specifications
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  color("Black") {
    // Placeholder for SBR bearing block geometry
    // Implement detailed geometry based on specifications
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("White") {
    // Placeholder for SCS bearing block hole positions
    // Implement detailed geometry based on specifications
  }
}

// Assembly
module assembly() {
  sbr_bearing_block_assembly();
  translate([0, 0, block_height_mm + 10]) scs_bearing_block();
  translate([0, 0, block_height_mm + 20]) sbr_bearing_block();
  translate([0, 0, block_height_mm + 30]) scs_bearing_block_hole_positions();
}

assembly();