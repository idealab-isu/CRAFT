// Parameters
shaft_diameter = 6; //[3:12:0.1]
block_length = 34; //[17:68:0.5]
block_width = 30; //[15:60:0.5]
block_height = 24; //[12:48:0.5]
base_flange_thickness = 6; //[3:12:0.5]
base_flange_overhang_y = 6; //[3:12:0.5]
bearing_outer_diameter = 12; //[8:24:0.1]
bearing_length = 19; //[10:38:0.5]
bore_diameter = 12.1; //[11.5:12.6:0.01]
bore_center_height_from_base = 12; //[8:20:0.5]
bore_length_extra = 2; //[0.5:6:0.5]
bearing_retention_lip_depth = 1.2; //[0.5:3:0.1]
bearing_retention_lip_length = 2; //[1:6:0.5]
mount_hole_diameter = 4.5; //[3:8:0.1]
mount_hole_spacing_x = 24; //[12:30:0.5]
mount_hole_spacing_y = 20; //[10:30:0.5]
counterbore_diameter = 8.5; //[6:14:0.1]
counterbore_depth = 3; //[1:6:0.5]
alignment_boss_diameter = 8; //[4:16:0.5]
alignment_boss_height = 1.5; //[0.5:4:0.25]
alignment_boss_offset_x = 10; //[6:14:0.5]
overlap = 1; //[0.5:2:0.1]

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    union() {
      // Base flange
      translate([0, 0, 0])
        cube([block_length, block_width + 2 * base_flange_overhang_y, base_flange_thickness], center=true);
      
      // Bearing block body
      translate([0, 0, base_flange_thickness/2 + block_height/2 - overlap])
        cube([block_length, block_width, block_height], center=true);
      
      // Alignment bosses
      translate([alignment_boss_offset_x, 0, -base_flange_thickness/2 - alignment_boss_height/2 + overlap])
        cylinder(r=alignment_boss_diameter/2, h=alignment_boss_height, center=true);
      translate([-alignment_boss_offset_x, 0, -base_flange_thickness/2 - alignment_boss_height/2 + overlap])
        cylinder(r=alignment_boss_diameter/2, h=alignment_boss_height, center=true);
    }
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("DimGray") {
    difference() {
      sbr_bearing_block_assembly();
      
      // Central bearing bore
      translate([0, 0, -base_flange_thickness/2 + bore_center_height_from_base])
        rotate([0, 90, 0])
        cylinder(r=bore_diameter/2, h=bearing_length + bore_length_extra, center=true);
      
      // Bearing retention lip cut
      translate([-(bearing_length + bore_length_extra)/2 + bearing_retention_lip_length/2, 0, -base_flange_thickness/2 + bore_center_height_from_base])
        rotate([0, 90, 0])
        cylinder(r=(bore_diameter/2) - bearing_retention_lip_depth, h=bearing_retention_lip_length + overlap, center=true);
    }
  }
}

// SBR Bearing Block
module sbr_bearing_block() {
  color("Black") {
    scs_bearing_block();
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("Silver") {
    union() {
      // Mount holes
      translate([mount_hole_spacing_x/2, mount_hole_spacing_y/2, base_flange_thickness/2 + block_height/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=base_flange_thickness + block_height + 2*overlap, center=true);
      translate([mount_hole_spacing_x/2, -mount_hole_spacing_y/2, base_flange_thickness/2 + block_height/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=base_flange_thickness + block_height + 2*overlap, center=true);
      translate([-mount_hole_spacing_x/2, mount_hole_spacing_y/2, base_flange_thickness/2 + block_height/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=base_flange_thickness + block_height + 2*overlap, center=true);
      translate([-mount_hole_spacing_x/2, -mount_hole_spacing_y/2, base_flange_thickness/2 + block_height/2 - overlap])
        cylinder(r=mount_hole_diameter/2, h=base_flange_thickness + block_height + 2*overlap, center=true);
      
      // Counterbores
      translate([mount_hole_spacing_x/2, mount_hole_spacing_y/2, -base_flange_thickness/2 + counterbore_depth/2])
        cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
      translate([mount_hole_spacing_x/2, -mount_hole_spacing_y/2, -base_flange_thickness/2 + counterbore_depth/2])
        cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
      translate([-mount_hole_spacing_x/2, mount_hole_spacing_y/2, -base_flange_thickness/2 + counterbore_depth/2])
        cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
      translate([-mount_hole_spacing_x/2, -mount_hole_spacing_y/2, -base_flange_thickness/2 + counterbore_depth/2])
        cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  sbr_bearing_block();
  scs_bearing_block_hole_positions();
}

assembly();