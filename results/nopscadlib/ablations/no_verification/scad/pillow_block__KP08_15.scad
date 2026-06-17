// Parameters
shaft_diameter_mm = 8; //[4:16:0.5]
base_length_mm = 55; //[28:110:1]
base_width_mm = 42; //[21:84:1]
base_thickness_mm = 8; //[4:16:0.5]
housing_outer_diameter_mm = 28; //[16:56:0.5]
housing_length_mm = 22; //[12:44:0.5]
housing_center_height_mm = 24; //[12:48:0.5]
mounting_hole_diameter_mm = 6; //[3:12:0.5]
mounting_hole_edge_margin_x_mm = 10; //[5:20:0.5]
mounting_hole_y_offset_mm = 0; //[-10:10:0.5]
trapezoid_top_width_mm = 18; //[10:36:0.5]
trapezoid_base_width_mm = 26; //[14:52:0.5]
rib_height_mm = 16; //[8:32:0.5]
rib_thickness_y_mm = 10; //[6:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]
bore_clearance_mm = 0.3; //[0:1:0.05]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    linear_extrude(height=rib_thickness_y_mm, center=true) {
      polygon(points=[
        [0, 0],
        [trapezoid_base_width_mm, 0],
        [trapezoid_top_width_mm, rib_height_mm],
        [0, rib_height_mm]
      ]);
    }
  }
}

// KP Pillow Block
module kp_pillow_block() {
  color("DimGray") {
    // Mounting Base
    translate([0, 0, 0])
      cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
    
    // Bearing Housing Outer
    translate([0, 0, (-base_thickness_mm/2) + housing_center_height_mm])
      rotate([90, 0, 0])
      cylinder(r=housing_outer_diameter_mm/2, h=housing_length_mm, center=true);
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Black") {
    // Mounting Holes
    translate([(-base_length_mm/2) + mounting_hole_edge_margin_x_mm, mounting_hole_y_offset_mm, 0])
      cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
    translate([(base_length_mm/2) - mounting_hole_edge_margin_x_mm, mounting_hole_y_offset_mm, 0])
      cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  difference() {
    kp_pillow_block();
    // Bearing Housing Bore
    translate([0, 0, (-base_thickness_mm/2) + housing_center_height_mm])
      rotate([90, 0, 0])
      cylinder(r=(shaft_diameter_mm + bore_clearance_mm)/2, h=housing_length_mm + 2*overlap_mm, center=true);
    kp_pillow_block_hole_positions();
  }
}

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  union() {
    kp_pillow_block_assembly();
    // Left Rib
    translate([(-trapezoid_base_width_mm/2) - overlap_mm, (base_width_mm/2) - (rib_thickness_y_mm/2) - overlap_mm, (base_thickness_mm/2) + (rib_height_mm/2) - overlap_mm])
      right_trapezoid();
    // Right Rib
    mirror([0, 1, 0])
      translate([(-trapezoid_base_width_mm/2) - overlap_mm, (-base_width_mm/2) + (rib_thickness_y_mm/2) + overlap_mm, (base_thickness_mm/2) + (rib_height_mm/2) - overlap_mm])
      right_trapezoid();
  }
}

// Final Assembly
module assembly() {
  sbr_bearing_block_assembly();
}

assembly();