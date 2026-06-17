// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
shaft_clearance_mm = 0.3; //[0:1:0.05]
base_length_mm = 55; //[30:110:0.5]
base_width_mm = 42; //[21:84:0.5]
base_thickness_mm = 8; //[4:16:0.5]
overall_height_mm = 28; //[14:56:0.5]
housing_outer_diameter_mm = 28; //[16:56:0.5]
housing_length_mm = 20; //[10:40:0.5]
mount_hole_diameter_mm = 6.5; //[3:10:0.1]
mount_hole_edge_margin_x_mm = 10; //[5:20:0.5]
mount_hole_offset_y_mm = 10; //[6:18:0.5]
mount_hole_spacing_mm = 35; //[20:80:0.5]
fillet_radius_mm = 1; //[0:3:0.25]
trapezoid_height_mm = 10; //[5:20:0.5]
trapezoid_base_x_mm = 18; //[10:30:0.5]
trapezoid_top_x_mm = 10; //[6:24:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    linear_extrude(height=housing_length_mm, center=true) {
      polygon(points=[
        [0, 0],
        [trapezoid_base_x_mm, 0],
        [trapezoid_top_x_mm, trapezoid_height_mm],
        [0, trapezoid_height_mm]
      ]);
    }
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("DimGray") {
    translate([-mount_hole_spacing_mm/2, -base_width_mm/2 + mount_hole_offset_y_mm, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
    translate([mount_hole_spacing_mm/2, -base_width_mm/2 + mount_hole_offset_y_mm, 0])
      cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
  }
}

// KP Pillow Block
module kp_pillow_block() {
  color("Black") {
    difference() {
      union() {
        translate([0, 0, 0])
          cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
        translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
          rotate([90, 0, 0])
          cylinder(r=housing_outer_diameter_mm/2, h=housing_length_mm, center=true);
        translate([-housing_outer_diameter_mm/2 - trapezoid_base_x_mm/2 + overlap_mm, 0, -base_thickness_mm/2 + trapezoid_height_mm/2])
          right_trapezoid();
        mirror([1, 0, 0])
          translate([-housing_outer_diameter_mm/2 - trapezoid_base_x_mm/2 + overlap_mm, 0, -base_thickness_mm/2 + trapezoid_height_mm/2])
          right_trapezoid();
      }
      kp_pillow_block_hole_positions();
      translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
        rotate([90, 0, 0])
        cylinder(r=(shaft_diameter_mm + shaft_clearance_mm)/2, h=housing_length_mm + 2*overlap_mm, center=true);
    }
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  color("Silver") {
    kp_pillow_block();
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  // Placeholder for SCS Bearing Block Assembly
  // Add detailed geometry here if needed
}

// Final Assembly
module assembly() {
  kp_pillow_block_assembly();
  scs_bearing_block_assembly();
}

assembly();