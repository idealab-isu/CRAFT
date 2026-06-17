// Parameters
shaft_diameter_mm = 9.0; //[4.5:18.0:0.1]
block_length_mm = 50.0; //[25.0:100.0:0.5]
block_width_mm = 44.0; //[22.0:88.0:0.5]
block_height_mm = 30.0; //[15.0:60.0:0.5]
bore_type = 0; //[0:1:1]
shaft_clearance_mm = 0.3; //[0.05:0.8:0.05]
bearing_press_fit_mm = -0.1; //[-0.3:0.2:0.05]
bearing_bore_extra_mm = 6.0; //[3.0:12.0:0.5]
bore_diameter_mm = 15.0; //[9.5:30.0:0.1]
mount_hole_count = 4; //[2:4:1]
mount_hole_diameter_mm = 5.5; //[3.0:10.0:0.1]
mount_hole_counterbore_diameter_mm = 10.0; //[6.0:18.0:0.1]
mount_hole_counterbore_depth_mm = 4.0; //[1.5:10.0:0.1]
mount_hole_edge_margin_mm = 6.0; //[3.0:12.0:0.5]
mount_hole_spacing_x_mm = 38.0; //[20.0:80.0:0.5]
mount_hole_spacing_y_mm = 32.0; //[16.0:70.0:0.5]
clamp_style = 0; //[0:0:1]
clamp_slot_width_mm = 2.0; //[1.0:4.0:0.1]
clamp_screw_count = 2; //[1:3:1]
clamp_screw_diameter_mm = 4.5; //[3.0:8.0:0.1]
clamp_screw_boss_diameter_mm = 12.0; //[8.0:20.0:0.5]
clamp_screw_boss_height_mm = 10.0; //[6.0:20.0:0.5]
clamp_screw_head_counterbore_diameter_mm = 8.5; //[6.0:14.0:0.1]
clamp_screw_head_counterbore_depth_mm = 3.0; //[1.0:8.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    difference() {
      union() {
        // Main block body
        translate([0, 0, 0])
          cube([block_length_mm, block_width_mm, block_height_mm], center=true);
        
        // Bearing retention features
        translate([0, 0, block_height_mm/2 - (block_height_mm*0.25)/2])
          cube([block_length_mm, block_width_mm, block_height_mm*0.25], center=true);
        
        // Clamp bosses
        translate([-(block_length_mm/4), block_width_mm/2 + clamp_screw_boss_diameter_mm/2 - overlap_mm, block_height_mm/2 - clamp_screw_boss_height_mm/2])
          cylinder(r=clamp_screw_boss_diameter_mm/2, h=clamp_screw_boss_height_mm, center=true);
        translate([(block_length_mm/4), block_width_mm/2 + clamp_screw_boss_diameter_mm/2 - overlap_mm, block_height_mm/2 - clamp_screw_boss_height_mm/2])
          cylinder(r=clamp_screw_boss_diameter_mm/2, h=clamp_screw_boss_height_mm, center=true);
      }
      
      // Shaft bore or bearing bore
      translate([0, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=((bore_type==0) ? (shaft_diameter_mm + shaft_clearance_mm)/2 : (bore_diameter_mm + bearing_press_fit_mm)/2), h=block_length_mm + 2*eps_mm, center=true);
      
      // Split clamp slot and clamp screw bosses
      translate([0, ((bore_type==0) ? (shaft_diameter_mm + shaft_clearance_mm)/2 : (bore_diameter_mm + bearing_press_fit_mm)/2) + clamp_slot_width_mm/2, 0])
        cube([block_length_mm + 2*eps_mm, clamp_slot_width_mm, block_height_mm + 2*eps_mm], center=true);
      
      // Clamp screw holes
      translate([-(block_length_mm/4), 0, block_height_mm/2 - clamp_screw_boss_height_mm/2])
        rotate([90, 0, 0])
        cylinder(r=clamp_screw_diameter_mm/2, h=block_width_mm + clamp_screw_boss_diameter_mm + 2*eps_mm, center=true);
      translate([(block_length_mm/4), 0, block_height_mm/2 - clamp_screw_boss_height_mm/2])
        rotate([90, 0, 0])
        cylinder(r=clamp_screw_diameter_mm/2, h=block_width_mm + clamp_screw_boss_diameter_mm + 2*eps_mm, center=true);
      
      // Clamp screw head counterbores
      translate([-(block_length_mm/4), block_width_mm/2 + clamp_screw_boss_diameter_mm/2 - overlap_mm, block_height_mm/2 - (clamp_screw_head_counterbore_depth_mm + eps_mm)/2])
        cylinder(r=clamp_screw_head_counterbore_diameter_mm/2, h=clamp_screw_head_counterbore_depth_mm + eps_mm, center=true);
      translate([(block_length_mm/4), block_width_mm/2 + clamp_screw_boss_diameter_mm/2 - overlap_mm, block_height_mm/2 - (clamp_screw_head_counterbore_depth_mm + eps_mm)/2])
        cylinder(r=clamp_screw_head_counterbore_diameter_mm/2, h=clamp_screw_head_counterbore_depth_mm + eps_mm, center=true);
      
      // Mounting holes
      translate([-(block_length_mm/2 - mount_hole_edge_margin_mm), -(block_width_mm/2 - mount_hole_edge_margin_mm), 0])
        cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*eps_mm, center=true);
      translate([(block_length_mm/2 - mount_hole_edge_margin_mm), -(block_width_mm/2 - mount_hole_edge_margin_mm), 0])
        cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*eps_mm, center=true);
      translate([-(block_length_mm/2 - mount_hole_edge_margin_mm), (block_width_mm/2 - mount_hole_edge_margin_mm), 0])
        cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*eps_mm, center=true);
      translate([(block_length_mm/2 - mount_hole_edge_margin_mm), (block_width_mm/2 - mount_hole_edge_margin_mm), 0])
        cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*eps_mm, center=true);
      
      // Mounting hole counterbores
      translate([-(block_length_mm/2 - mount_hole_edge_margin_mm), -(block_width_mm/2 - mount_hole_edge_margin_mm), -block_height_mm/2 + (mount_hole_counterbore_depth_mm + eps_mm)/2])
        cylinder(r=mount_hole_counterbore_diameter_mm/2, h=mount_hole_counterbore_depth_mm + eps_mm, center=true);
      translate([(block_length_mm/2 - mount_hole_edge_margin_mm), -(block_width_mm/2 - mount_hole_edge_margin_mm), -block_height_mm/2 + (mount_hole_counterbore_depth_mm + eps_mm)/2])
        cylinder(r=mount_hole_counterbore_diameter_mm/2, h=mount_hole_counterbore_depth_mm + eps_mm, center=true);
      translate([-(block_length_mm/2 - mount_hole_edge_margin_mm), (block_width_mm/2 - mount_hole_edge_margin_mm), -block_height_mm/2 + (mount_hole_counterbore_depth_mm + eps_mm)/2])
        cylinder(r=mount_hole_counterbore_diameter_mm/2, h=mount_hole_counterbore_depth_mm + eps_mm, center=true);
      translate([(block_length_mm/2 - mount_hole_edge_margin_mm), (block_width_mm/2 - mount_hole_edge_margin_mm), -block_height_mm/2 + (mount_hole_counterbore_depth_mm + eps_mm)/2])
        cylinder(r=mount_hole_counterbore_diameter_mm/2, h=mount_hole_counterbore_depth_mm + eps_mm, center=true);
    }
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("DimGray") {
    cube([block_length_mm, block_width_mm, block_height_mm], center=true);
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  color("Black") {
    cube([block_length_mm, block_width_mm, block_height_mm], center=true);
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("Silver") {
    translate([0, 0, -block_height_mm/2 + eps_mm/2])
      cube([mount_hole_spacing_x_mm, mount_hole_spacing_y_mm, eps_mm], center=true);
  }
}

// Assembly
module assembly() {
  sbr_bearing_block_assembly();
  translate([0, 0, block_height_mm/2 + 1])
    scs_bearing_block();
  translate([0, 0, block_height_mm + 2])
    sbr_bearing_block();
  translate([0, 0, block_height_mm + 3])
    scs_bearing_block_hole_positions();
}

assembly();