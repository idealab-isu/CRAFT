// Parameters
shaft_diameter_mm = 12.0; //[6.0:24.0:0.1]
shaft_clearance_mm = 0.0; //[0.0:0.5:0.01]
housing_material_clearance_mm = 0.0; //[0.0:1.0:0.05]
base_length_mm = 71.0; //[35.5:142.0:0.5]
base_width_mm = 56.0; //[28.0:112.0:0.5]
base_thickness_mm = 12.0; //[6.0:24.0:0.5]
overall_height_mm = 40.0; //[20.0:80.0:0.5]
mounting_hole_count = 2; //[2:2:1]
mounting_hole_diameter_mm = 10.0; //[5.0:16.0:0.1]
mounting_hole_center_spacing_mm = 54.0; //[30.0:90.0:0.5]
mounting_hole_offset_from_edge_mm = 10.0; //[5.0:20.0:0.5]
housing_outer_diameter_mm = 38.0; //[24.0:76.0:0.5]
housing_length_x_mm = 46.0; //[30.0:80.0:0.5]
bearing_seat_diameter_mm = 28.0; //[18.0:56.0:0.5]
bearing_seat_depth_mm = 8.0; //[3.0:20.0:0.5]
side_overlap_mm = 1.0; //[0.5:2.0:0.1]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    linear_extrude(height=housing_length_x_mm, center=true) {
      polygon(points=[
        [0, 0],
        [housing_outer_diameter_mm/2, 0],
        [housing_outer_diameter_mm*0.35, (overall_height_mm - base_thickness_mm)/2],
        [0, (overall_height_mm - base_thickness_mm)/2]
      ]);
    }
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("DimGray") {
    union() {
      translate([-mounting_hole_center_spacing_mm/2, -base_width_mm/2 + mounting_hole_offset_from_edge_mm, 0])
        cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*side_overlap_mm, center=true);
      translate([mounting_hole_center_spacing_mm/2, -base_width_mm/2 + mounting_hole_offset_from_edge_mm, 0])
        cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*side_overlap_mm, center=true);
    }
  }
}

// KP Pillow Block
module kp_pillow_block() {
  color("Black") {
    difference() {
      union() {
        translate([0, 0, 0])
          cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
        translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2 - side_overlap_mm])
          intersection() {
            cylinder(r=housing_outer_diameter_mm/2, h=housing_length_x_mm, center=true);
            cube([housing_length_x_mm, housing_outer_diameter_mm, (overall_height_mm - base_thickness_mm)], center=true);
          }
        right_trapezoid();
      }
      translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2 - side_overlap_mm])
        cylinder(r=(shaft_diameter_mm + shaft_clearance_mm)/2, h=housing_length_x_mm + 2*side_overlap_mm, center=true);
      translate([housing_length_x_mm/2 - (bearing_seat_depth_mm + side_overlap_mm)/2, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2 - side_overlap_mm])
        cylinder(r=(bearing_seat_diameter_mm + housing_material_clearance_mm)/2, h=bearing_seat_depth_mm + side_overlap_mm, center=true);
      kp_pillow_block_hole_positions();
    }
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  kp_pillow_block();
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  kp_pillow_block_assembly();
}

// Final Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();