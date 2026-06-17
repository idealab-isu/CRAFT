// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
block_length_mm = 42; //[21:84:0.5]
block_width_mm = 36; //[18:72:0.5]
block_height_mm = 28; //[14:56:0.5]
bearing_outer_diameter_mm = 15; //[10:30:0.1]
bearing_length_mm = 24; //[12:48:0.5]
bearing_bore_clearance_mm = 0; //[-0.2:0.5:0.01]
mounting_hole_diameter_mm = 5; //[3:8:0.1]
mounting_hole_spacing_x_mm = 30; //[18:60:0.5]
mounting_hole_spacing_y_mm = 24; //[14:50:0.5]
mounting_counterbore_diameter_mm = 9; //[6:16:0.1]
mounting_counterbore_depth_mm = 3; //[0:10:0.1]
clamp_slot_width_mm = 2; //[1:6:0.1]
fillet_radius_mm = 1; //[0:4:0.1]
eps_mm = 0.8; //[0.2:2:0.1]

// SBR Bearing Block - complete geometry
module sbr_bearing_block() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Block body
      cube([block_length_mm, block_width_mm, block_height_mm], center=true);
      
      // Bearing bore with shaft relief
      union() {
        rotate([0, 90, 0]) translate([0, 0, 0])
          cylinder(h=block_length_mm + 2*eps_mm, r=(bearing_outer_diameter_mm + bearing_bore_clearance_mm)/2, center=true);
        rotate([0, 90, 0]) translate([0, 0, 0])
          cylinder(h=block_length_mm + 2*eps_mm, r=shaft_diameter_mm/2, center=true);
      }
      
      // Mounting holes
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * mounting_hole_spacing_x_mm/2, y * mounting_hole_spacing_y_mm/2, 0])
          cylinder(h=block_height_mm + 2*eps_mm, r=mounting_hole_diameter_mm/2, center=true);
      }
      
      // Counterbores
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * mounting_hole_spacing_x_mm/2, y * mounting_hole_spacing_y_mm/2, -block_height_mm/2 + (mounting_counterbore_depth_mm + eps_mm)/2])
          cylinder(h=mounting_counterbore_depth_mm + eps_mm, r=mounting_counterbore_diameter_mm/2, center=true);
      }
      
      // Clamp slot
      translate([0, 0, 0])
        cube([block_length_mm + 2*eps_mm, clamp_slot_width_mm, block_height_mm + 2*eps_mm], center=true);
    }
  }
}

// SCS Bearing Block - complete geometry
module scs_bearing_block() {
  color([0.85, 0.85, 0.8]) {
    sbr_bearing_block();
  }
}

// SCS Bearing Block Hole Positions - complete geometry
module scs_bearing_block_hole_positions() {
  color([0.85, 0.85, 0.8]) {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mounting_hole_spacing_x_mm/2, y * mounting_hole_spacing_y_mm/2, 0])
        cylinder(h=block_height_mm + 2*eps_mm, r=mounting_hole_diameter_mm/2, center=true);
    }
  }
}

// SBR Bearing Block Assembly - complete geometry
module sbr_bearing_block_assembly() {
  color([0.85, 0.85, 0.8]) {
    sbr_bearing_block();
    scs_bearing_block_hole_positions();
  }
}

// Assembly
module assembly() {
  sbr_bearing_block_assembly();
}

assembly();