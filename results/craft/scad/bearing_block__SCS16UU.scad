// Parameters
shaft_diameter_mm = 9.0; //[4.5:18.0:0.1]
shaft_clearance_mm = 0.2; //[0.0:1.0:0.05]
shaft_bore_diameter_mm = 9.2; //[4.6:19.0:0.1]
block_length_mm = 50.0; //[25.0:100.0:1]
block_width_mm = 44.0; //[22.0:88.0:1]
block_height_mm = 20.0; //[10.0:40.0:1]
mount_hole_count = 4; //[2:8:1]
mount_hole_diameter_mm = 5.0; //[2.5:10.0:0.1]
mount_hole_edge_margin_mm = 6.0; //[3.0:12.0:0.5]
mount_hole_spacing_x_mm = 38.0; //[19.0:76.0:1]
mount_hole_spacing_y_mm = 32.0; //[16.0:64.0:1]
insert_outer_diameter_mm = 15.0; //[7.5:30.0:0.1]
insert_length_mm = 24.0; //[12.0:48.0:1]
insert_fit_clearance_mm = 0.1; //[0.0:0.5:0.05]
retention_lip_thickness_mm = 1.5; //[0.5:3.0:0.1]
retention_lip_radial_mm = 1.0; //[0.5:3.0:0.1]
counterbore_diameter_mm = 9.0; //[6.0:16.0:0.1]
counterbore_depth_mm = 3.0; //[1.0:8.0:0.5]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// SCS Bearing Block
module scs_bearing_block() {
  color("Silver") {
    difference() {
      // Main block
      translate([0, 0, 0])
        cube([block_length_mm, block_width_mm, block_height_mm], center=true);
      // Shaft bore
      translate([0, 0, 0])
        cylinder(h=block_height_mm + 2*overlap_mm, r=shaft_bore_diameter_mm/2, center=true);
      // Insert pocket with retention lip
      difference() {
        translate([0, 0, 0])
          cylinder(h=insert_length_mm + 2*overlap_mm, r=(insert_outer_diameter_mm + insert_fit_clearance_mm)/2, center=true);
        translate([0, 0, block_height_mm/2 - retention_lip_thickness_mm/2])
          cylinder(h=retention_lip_thickness_mm + overlap_mm, r=((insert_outer_diameter_mm + insert_fit_clearance_mm) - 2*retention_lip_radial_mm)/2, center=true);
      }
      // Mounting holes
      scs_bearing_block_hole_positions();
    }
  }
}

// Linear Bearing
module linear_bearing() {
  color("Black") {
    translate([0, 0, 0])
      cylinder(h=insert_length_mm, r=insert_outer_diameter_mm/2, center=true);
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  color("DimGray") {
    difference() {
      // Main block
      translate([0, 0, 0])
        cube([block_length_mm, block_width_mm, block_height_mm], center=true);
      // Shaft bore
      translate([0, 0, 0])
        cylinder(h=block_height_mm + 2*overlap_mm, r=shaft_bore_diameter_mm/2, center=true);
      // Insert pocket with retention lip
      difference() {
        translate([0, 0, 0])
          cylinder(h=insert_length_mm + 2*overlap_mm, r=(insert_outer_diameter_mm + insert_fit_clearance_mm)/2, center=true);
        translate([0, 0, block_height_mm/2 - retention_lip_thickness_mm/2])
          cylinder(h=retention_lip_thickness_mm + overlap_mm, r=((insert_outer_diameter_mm + insert_fit_clearance_mm) - 2*retention_lip_radial_mm)/2, center=true);
      }
      // Mounting holes
      sbr_bearing_block_hole_positions();
    }
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  scs_bearing_block();
  translate([0, 0, 0])
    linear_bearing();
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("Silver") {
    for (x = [-1, 1])
      for (y = [-1, 1]) {
        translate([x * mount_hole_spacing_x_mm/2, y * mount_hole_spacing_y_mm/2, 0])
          cylinder(h=block_height_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
        translate([x * mount_hole_spacing_x_mm/2, y * mount_hole_spacing_y_mm/2, block_height_mm/2 - counterbore_depth_mm/2])
          cylinder(h=counterbore_depth_mm + overlap_mm, r=counterbore_diameter_mm/2, center=true);
      }
  }
}

// SBR Bearing Block Hole Positions
module sbr_bearing_block_hole_positions() {
  color("Silver") {
    for (x = [-1, 1])
      for (y = [-1, 1]) {
        translate([x * mount_hole_spacing_x_mm/2, y * mount_hole_spacing_y_mm/2, 0])
          cylinder(h=block_height_mm + 2*overlap_mm, r=mount_hole_diameter_mm/2, center=true);
        translate([x * mount_hole_spacing_x_mm/2, y * mount_hole_spacing_y_mm/2, block_height_mm/2 - counterbore_depth_mm/2])
          cylinder(h=counterbore_depth_mm + overlap_mm, r=counterbore_diameter_mm/2, center=true);
      }
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();