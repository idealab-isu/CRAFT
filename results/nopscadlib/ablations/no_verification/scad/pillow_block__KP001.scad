// Parameters
shaft_diameter_mm = 12; //[6:24:0.5]
base_length_mm = 71; //[35.5:142:0.5]
base_width_mm = 56; //[28:112:0.5]
mounting_hole_diameter_mm = 9; //[5:14:0.5]
mounting_hole_center_distance_mm = 55; //[35:90:0.5]
base_thickness_mm = 10; //[5:20:0.5]
overall_height_mm = 36; //[20:72:0.5]
bearing_outer_diameter_mm = 32; //[20:60:0.5]
bearing_width_mm = 12; //[6:30:0.5]
fillet_radius_mm = 2; //[0.5:6:0.5]
housing_wall_mm = 6; //[3:15:0.5]
housing_length_mm = 46; //[30:80:0.5]
housing_width_mm = 40; //[25:80:0.5]
rib_thickness_mm = 6; //[3:15:0.5]
rib_height_mm = 14; //[6:30:0.5]
hole_edge_margin_y_mm = 12; //[6:25:0.5]
overlap_mm = 1; //[0.5:2:0.1]
bore_clearance_mm = 0.3; //[0:1:0.05]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    translate([-housing_length_mm/2 + (housing_length_mm/4), 0, base_thickness_mm/2 + rib_height_mm/2 - overlap_mm])
    rotate([90, 0, 0])
    linear_extrude(height=housing_width_mm, center=true) {
      polygon(points=[
        [0, 0],
        [housing_length_mm/2, 0],
        [housing_length_mm/2 - rib_height_mm, rib_height_mm],
        [0, rib_height_mm]
      ]);
    }
  }
}

// KP Pillow Block
module kp_pillow_block() {
  color("DimGray") {
    // Base
    translate([0, 0, 0])
    cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);

    // Pillow Block Body
    translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2 - overlap_mm])
    cube([housing_length_mm, housing_width_mm, overall_height_mm - base_thickness_mm], center=true);

    // Bearing Seat Geometry
    translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2])
    rotate([90, 0, 0])
    cylinder(r=(bearing_outer_diameter_mm/2) + housing_wall_mm, h=housing_width_mm, center=true);

    // Housing Top Profile
    translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2])
    rotate([0, 90, 0])
    cylinder(r=(bearing_outer_diameter_mm/2) + housing_wall_mm, h=housing_length_mm, center=true);

    // Ribs
    translate([0, -base_width_mm/2 + rib_thickness_mm/2, base_thickness_mm/2 + rib_height_mm/2 - overlap_mm])
    cube([base_length_mm - 2*fillet_radius_mm, rib_thickness_mm, rib_height_mm], center=true);

    translate([0, base_width_mm/2 - rib_thickness_mm/2, base_thickness_mm/2 + rib_height_mm/2 - overlap_mm])
    cube([base_length_mm - 2*fillet_radius_mm, rib_thickness_mm, rib_height_mm], center=true);
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Black") {
    // Mounting Holes
    translate([-mounting_hole_center_distance_mm/2, -base_width_mm/2 + hole_edge_margin_y_mm, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);

    translate([mounting_hole_center_distance_mm/2, -base_width_mm/2 + hole_edge_margin_y_mm, 0])
    cylinder(r=mounting_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  difference() {
    kp_pillow_block();
    kp_pillow_block_hole_positions();
    // Bearing Bore
    translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2])
    rotate([90, 0, 0])
    cylinder(r=(shaft_diameter_mm + bore_clearance_mm)/2, h=base_width_mm + 2*(housing_wall_mm + overlap_mm), center=true);
  }
}

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  union() {
    kp_pillow_block_assembly();
    right_trapezoid();
  }
}

// Final Assembly
module assembly() {
  sbr_bearing_block_assembly();
}

assembly();