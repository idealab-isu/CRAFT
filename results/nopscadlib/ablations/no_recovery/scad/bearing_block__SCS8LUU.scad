// Parameters
shaft_diameter_mm = 6; //[3:12:0.1]
shaft_bore_clearance_mm = 0.2; //[0.05:0.6:0.05]
block_width_mm = 34; //[17:68:0.5]
block_length_mm = 58; //[29:116:0.5]
block_height_mm = 24; //[12:48:0.5]
corner_radius_mm = 2; //[0:6:0.25]
bearing_outer_diameter_mm = 12; //[8:24:0.1]
bearing_length_mm = 19; //[10:40:0.5]
bearing_seat_clearance_mm = 0.1; //[0:0.4:0.05]
mount_hole_diameter_mm = 5; //[3:8:0.1]
mount_hole_spacing_x_mm = 24; //[12:48:0.5]
mount_hole_spacing_y_mm = 44; //[22:88:0.5]
counterbore_enabled = 1; //[0:1:1]
counterbore_diameter_mm = 9; //[6:14:0.1]
counterbore_depth_mm = 3; //[0:8:0.25]
clamp_enabled = 1; //[0:1:1]
clamp_slot_width_mm = 2; //[1:4:0.1]
clamp_slot_depth_mm = 14; //[6:22:0.5]
clamp_screw_diameter_mm = 3.2; //[2.2:6.5:0.1]
clamp_boss_diameter_mm = 10; //[6:18:0.5]
clamp_boss_height_mm = 6; //[3:12:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    // Main block with rounded corners
    minkowski() {
      cube([block_width_mm, block_length_mm, block_height_mm], center=true);
      sphere(r=corner_radius_mm, center=true);
    }
    // Clamp bosses
    if (clamp_enabled) {
      translate([-(clamp_slot_width_mm/2 + clamp_boss_diameter_mm/4 - overlap_mm), 0, block_height_mm/2 + clamp_boss_height_mm/2 - overlap_mm])
        rotate([90, 0, 0]) cylinder(r=clamp_boss_diameter_mm/2, h=clamp_boss_height_mm, center=true);
      translate([(clamp_slot_width_mm/2 + clamp_boss_diameter_mm/4 - overlap_mm), 0, block_height_mm/2 + clamp_boss_height_mm/2 - overlap_mm])
        rotate([90, 0, 0]) cylinder(r=clamp_boss_diameter_mm/2, h=clamp_boss_height_mm, center=true);
    }
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("DimGray") {
    // Shaft bore
    rotate([90, 0, 0])
      translate([0, 0, 0])
      cylinder(r=(shaft_diameter_mm + shaft_bore_clearance_mm)/2, h=block_length_mm + 2*overlap_mm, center=true);
    // Bearing seat
    rotate([90, 0, 0])
      translate([0, 0, 0])
      cylinder(r=(bearing_outer_diameter_mm + bearing_seat_clearance_mm)/2, h=bearing_length_mm + 2*overlap_mm, center=true);
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  color("Black") {
    // Clamp slot
    if (clamp_enabled) {
      translate([0, 0, block_height_mm/2 - clamp_slot_depth_mm/2])
        cube([clamp_slot_width_mm, block_length_mm + 2*overlap_mm, clamp_slot_depth_mm], center=true);
    }
    // Clamp screw hole
    if (clamp_enabled) {
      rotate([0, 90, 0])
        translate([0, 0, block_height_mm/2 + clamp_boss_height_mm/2 - overlap_mm])
        cylinder(r=clamp_screw_diameter_mm/2, h=block_width_mm + clamp_boss_diameter_mm + 2*overlap_mm, center=true);
    }
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("Silver") {
    // Mount holes
    translate([mount_hole_spacing_x_mm/2, mount_hole_spacing_y_mm/2, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
    translate([-mount_hole_spacing_x_mm/2, mount_hole_spacing_y_mm/2, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
    translate([mount_hole_spacing_x_mm/2, -mount_hole_spacing_y_mm/2, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
    translate([-mount_hole_spacing_x_mm/2, -mount_hole_spacing_y_mm/2, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
    // Counterbores
    if (counterbore_enabled) {
      translate([mount_hole_spacing_x_mm/2, mount_hole_spacing_y_mm/2, -block_height_mm/2 + counterbore_depth_mm/2])
        cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
      translate([-mount_hole_spacing_x_mm/2, mount_hole_spacing_y_mm/2, -block_height_mm/2 + counterbore_depth_mm/2])
        cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
      translate([mount_hole_spacing_x_mm/2, -mount_hole_spacing_y_mm/2, -block_height_mm/2 + counterbore_depth_mm/2])
        cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
      translate([-mount_hole_spacing_x_mm/2, -mount_hole_spacing_y_mm/2, -block_height_mm/2 + counterbore_depth_mm/2])
        cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  sbr_bearing_block_assembly();
  scs_bearing_block();
  sbr_bearing_block();
  scs_bearing_block_hole_positions();
}

assembly();