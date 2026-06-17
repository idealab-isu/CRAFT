// Parameters
shaft_diameter_mm = 10; //[5:20:0.5]
base_length_mm = 67; //[34:134:1]
base_width_mm = 53; //[27:106:1]
base_thickness_mm = 12; //[6:24:1]
housing_outer_diameter_mm = 38; //[25:60:1]
housing_length_mm = 53; //[30:90:1]
housing_center_height_mm = 28; //[18:50:1]
mounting_hole_diameter_mm = 11; //[6:16:0.5]
mounting_hole_separation_mm = 50; //[30:90:1]
mounting_hole_edge_margin_x_mm = 8.5; //[4:20:0.5]
mounting_hole_offset_y_mm = 10; //[5:20:0.5]
bearing_seat_diameter_mm = 26; //[16:45:0.5]
bearing_seat_depth_mm = 6; //[2:15:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    linear_extrude(height=base_width_mm, center=true) {
      polygon(points=[
        [0, 0],
        [base_length_mm, 0],
        [base_length_mm * 0.70, housing_center_height_mm - base_thickness_mm / 2],
        [0, housing_center_height_mm - base_thickness_mm / 2]
      ]);
    }
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("DimGray") {
    union() {
      translate([-mounting_hole_separation_mm / 2, (-base_width_mm / 2) + mounting_hole_offset_y_mm, 0])
        cylinder(r=mounting_hole_diameter_mm / 2, h=base_thickness_mm + 2 * overlap_mm, center=true);
      translate([mounting_hole_separation_mm / 2, (-base_width_mm / 2) + mounting_hole_offset_y_mm, 0])
        cylinder(r=mounting_hole_diameter_mm / 2, h=base_thickness_mm + 2 * overlap_mm, center=true);
    }
  }
}

// KP Pillow Block
module kp_pillow_block() {
  color("Black") {
    rotate([90, 0, 0])
      translate([0, 0, (-base_thickness_mm / 2) + housing_center_height_mm])
      cylinder(r=housing_outer_diameter_mm / 2, h=housing_length_mm, center=true);
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  color("Silver") {
    union() {
      translate([0, 0, 0])
        cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
      right_trapezoid();
      kp_pillow_block();
    }
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  color("Silver") {
    difference() {
      kp_pillow_block_assembly();
      translate([0, 0, (-base_thickness_mm / 2) + housing_center_height_mm])
        rotate([0, 90, 0])
        cylinder(r=shaft_diameter_mm / 2, h=base_length_mm + 2 * overlap_mm, center=true);
      translate([(base_length_mm / 2) - (bearing_seat_depth_mm / 2) + overlap_mm, 0, (-base_thickness_mm / 2) + housing_center_height_mm])
        rotate([0, 90, 0])
        cylinder(r=bearing_seat_diameter_mm / 2, h=bearing_seat_depth_mm + 2 * overlap_mm, center=true);
      kp_pillow_block_hole_positions();
    }
  }
}

// Final Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();