// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
shaft_clearance_mm = 0.1; //[0:0.5:0.05]
block_length_mm = 40; //[20:80:1]
block_width_mm = 35; //[18:70:1]
block_height_mm = 28; //[14:56:1]
bearing_outer_diameter_mm = 15; //[10:30:0.1]
bearing_length_mm = 24; //[12:48:0.5]
bearing_bore_extra_mm = 0.05; //[-0.05:0.3:0.01]
mounting_hole_count = 4; //[2:4:1]
mounting_hole_diameter_mm = 5; //[3:8:0.1]
mounting_counterbore_diameter_mm = 9; //[6:14:0.1]
mounting_counterbore_depth_mm = 4; //[1:10:0.1]
mounting_hole_spacing_x_mm = 28; //[14:56:0.5]
mounting_hole_spacing_y_mm = 22; //[11:44:0.5]
edge_margin_mm = 3; //[1.5:8:0.5]
chamfer_mm = 0.5; //[0:2:0.1]
set_screw_diameter_mm = 4; //[2:6:0.1]
set_screw_axis_z_offset_mm = 0; //[-6:6:0.5]
split_clamp_enabled = 1; //[0:1:1]
split_clamp_slot_width_mm = 2; //[0.8:4:0.1]
split_clamp_slot_depth_mm = 18; //[8:26:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Modules
module bearing_block_body() {
  color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
  cube([block_length_mm, block_width_mm, block_height_mm], center=true);
}

module central_bearing_bore() {
  cylinder(r=(bearing_outer_diameter_mm + bearing_bore_extra_mm)/2, 
           h=block_length_mm + 2*overlap_mm, center=true, $fn=64);
}

module shaft_axis_clearance() {
  cylinder(r=(shaft_diameter_mm + shaft_clearance_mm)/2, 
           h=block_length_mm + 2*overlap_mm, center=true, $fn=64);
}

module bearing_retention_features_set_screw() {
  rotate([90, 0, 0])
  cylinder(r=set_screw_diameter_mm/2, 
           h=block_width_mm + 2*overlap_mm, center=true, $fn=32);
}

module split_clamp_slot() {
  if (split_clamp_enabled) {
    translate([0, 0, block_height_mm/2 - (split_clamp_slot_depth_mm + overlap_mm)/2])
    cube([block_length_mm + 2*overlap_mm, split_clamp_slot_width_mm, split_clamp_slot_depth_mm + overlap_mm], center=true);
  }
}

module mounting_hole_pattern() {
  union() {
    translate([mounting_hole_spacing_x_mm/2, mounting_hole_spacing_y_mm/2, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
    translate([-mounting_hole_spacing_x_mm/2, mounting_hole_spacing_y_mm/2, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
    translate([mounting_hole_spacing_x_mm/2, -mounting_hole_spacing_y_mm/2, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
    translate([-mounting_hole_spacing_x_mm/2, -mounting_hole_spacing_y_mm/2, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true, $fn=32);
  }
}

module counterbore_or_countersink_features() {
  union() {
    translate([mounting_hole_spacing_x_mm/2, mounting_hole_spacing_y_mm/2, -block_height_mm/2 + (mounting_counterbore_depth_mm + overlap_mm)/2])
    cylinder(r=mounting_counterbore_diameter_mm/2, h=mounting_counterbore_depth_mm + overlap_mm, center=true, $fn=32);
    translate([-mounting_hole_spacing_x_mm/2, mounting_hole_spacing_y_mm/2, -block_height_mm/2 + (mounting_counterbore_depth_mm + overlap_mm)/2])
    cylinder(r=mounting_counterbore_diameter_mm/2, h=mounting_counterbore_depth_mm + overlap_mm, center=true, $fn=32);
    translate([mounting_hole_spacing_x_mm/2, -mounting_hole_spacing_y_mm/2, -block_height_mm/2 + (mounting_counterbore_depth_mm + overlap_mm)/2])
    cylinder(r=mounting_counterbore_diameter_mm/2, h=mounting_counterbore_depth_mm + overlap_mm, center=true, $fn=32);
    translate([-mounting_hole_spacing_x_mm/2, -mounting_hole_spacing_y_mm/2, -block_height_mm/2 + (mounting_counterbore_depth_mm + overlap_mm)/2])
    cylinder(r=mounting_counterbore_diameter_mm/2, h=mounting_counterbore_depth_mm + overlap_mm, center=true, $fn=32);
  }
}

module bearing_block_body_with_bores() {
  difference() {
    bearing_block_body();
    central_bearing_bore();
    shaft_axis_clearance();
  }
}

module bearing_block_body_with_mounting() {
  difference() {
    bearing_block_body_with_bores();
    mounting_hole_pattern();
    counterbore_or_countersink_features();
  }
}

module bearing_block_body_with_retention() {
  difference() {
    bearing_block_body_with_mounting();
    bearing_retention_features_set_screw();
  }
}

module bearing_block_body_with_optional_split_clamp() {
  difference() {
    bearing_block_body_with_retention();
    split_clamp_slot();
  }
}

module scs_bearing_block_hole_positions() {
  union() {
    mounting_hole_pattern();
    counterbore_or_countersink_features();
  }
}

module scs_bearing_block() {
  bearing_block_body_with_optional_split_clamp();
}

module sbr_bearing_block() {
  union() {
    scs_bearing_block();
    bearing_retention_features_set_screw();
  }
}

module sbr_bearing_block_assembly() {
  union() {
    sbr_bearing_block();
    bearing_block_body_with_optional_split_clamp();
  }
}

module assembly() {
  sbr_bearing_block_assembly();
}

assembly();