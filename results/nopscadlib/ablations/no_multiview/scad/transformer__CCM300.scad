// Parameters
overall_width_mm = 120; //[60:240:1]
overall_depth_mm = 88; //[44:176:1]
overall_height_mm = 120; //[60:240:1]
include_mounting_holes = 1; //[0:1:1]
mounting_hole_count = 4; //[2:4:1]
mounting_hole_diameter_mm = 6; //[3:10:0.5]
mounting_hole_pattern_mm = 90; //[50:160:1]
foot_thickness_mm = 6; //[3:12:0.5]
core_block_height_mm = 70; //[35:140:1]
bobbin_block_height_mm = 44; //[22:88:1]
corner_radius_mm = 2; //[0:8:0.5]
overlap_mm = 1; //[0.5:2:0.1]
foot_width_mm = 120; //[60:240:1]
foot_depth_mm = 88; //[44:176:1]
core_width_mm = 90; //[45:180:1]
core_depth_mm = 60; //[30:120:1]
bobbin_width_mm = 70; //[35:140:1]
bobbin_depth_mm = 88; //[44:176:1]

// Transformer - complete geometry
module transformer() {
  color("DimGray") {
    // Mounting Foot Plate
    translate([0, 0, foot_thickness_mm / 2])
      cube([foot_width_mm, foot_depth_mm, foot_thickness_mm], center=true);

    // Lamination Core Block
    translate([0, 0, foot_thickness_mm + core_block_height_mm / 2 - overlap_mm])
      cube([core_width_mm, core_depth_mm, core_block_height_mm], center=true);

    // Bobbin/Coil Block
    translate([0, 0, foot_thickness_mm + core_block_height_mm - overlap_mm + bobbin_block_height_mm / 2 - overlap_mm])
      cube([bobbin_width_mm, bobbin_depth_mm, bobbin_block_height_mm], center=true);
  }

  if (include_mounting_holes) {
    color("Black") {
      // Mounting Holes
      for (i = [-1, 1], j = [-1, 1]) {
        translate([i * mounting_hole_pattern_mm / 2, j * ((foot_depth_mm / 2) - (mounting_hole_diameter_mm) - corner_radius_mm), foot_thickness_mm / 2])
          cylinder(r=(mounting_hole_diameter_mm * include_mounting_holes) / 2, h=foot_thickness_mm + 2 * overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  difference() {
    transformer();
    if (include_mounting_holes) {
      union() {
        for (i = [-1, 1], j = [-1, 1]) {
          translate([i * mounting_hole_pattern_mm / 2, j * ((foot_depth_mm / 2) - (mounting_hole_diameter_mm) - corner_radius_mm), foot_thickness_mm / 2])
            cylinder(r=(mounting_hole_diameter_mm * include_mounting_holes) / 2, h=foot_thickness_mm + 2 * overlap_mm, center=true);
        }
      }
    }
  }
}

assembly();