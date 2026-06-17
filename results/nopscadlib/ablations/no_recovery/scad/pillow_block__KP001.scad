// Parameters
shaft_diameter_mm = 12; //[6:24:0.5]
base_length_mm = 71; //[35.5:142:0.5]
base_width_mm = 56; //[28:112:0.5]
base_thickness_mm = 10; //[5:20:0.5]
overall_height_mm = 36; //[18:72:0.5]
mount_hole_diameter_mm = 8; //[4:16:0.5]
mount_hole_spacing_mm = 54; //[27:108:0.5]
bearing_outer_diameter_mm = 32; //[16:64:0.5]
bearing_width_mm = 12; //[6:24:0.5]
housing_wall_thickness_mm = 6; //[3:12:0.5]
fillet_radius_mm = 3; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
clearance_mm = 0.3; //[0.1:0.8:0.05]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    linear_extrude(height=bearing_width_mm + 2*housing_wall_thickness_mm) {
      polygon(points=[
        [0, 0],
        [base_length_mm*0.78, 0],
        [base_length_mm*0.78*0.72, overall_height_mm - base_thickness_mm],
        [0, overall_height_mm - base_thickness_mm]
      ]);
    }
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Black") {
    union() {
      translate([mount_hole_spacing_mm/2, 0, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
      translate([-mount_hole_spacing_mm/2, 0, 0])
        cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  color("DimGray") {
    difference() {
      union() {
        translate([0, 0, 0])
          cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
        translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm + overlap_mm)/2 - overlap_mm])
          cube([base_length_mm*0.78, bearing_width_mm + 2*housing_wall_thickness_mm, overall_height_mm - base_thickness_mm + overlap_mm], center=true);
        translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm) - (bearing_outer_diameter_mm/2 + housing_wall_thickness_mm) + overlap_mm])
          rotate([90, 0, 0])
          cylinder(r=bearing_outer_diameter_mm/2 + housing_wall_thickness_mm, h=bearing_width_mm + 2*housing_wall_thickness_mm, center=true);
        translate([(-base_length_mm*0.78)/2, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm)/2])
          rotate([90, 0, 0])
          right_trapezoid();
      }
      translate([0, 0, base_thickness_mm/2 + (overall_height_mm - base_thickness_mm) - (bearing_outer_diameter_mm/2) + overlap_mm])
        rotate([90, 0, 0])
        cylinder(r=(shaft_diameter_mm + clearance_mm)/2, h=base_width_mm + 2*overlap_mm, center=true);
      kp_pillow_block_hole_positions();
    }
  }
}

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    kp_pillow_block_assembly();
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  color("Silver") {
    sbr_bearing_block_assembly();
  }
}

// Assembly
module assembly() {
  scs_bearing_block();
}

assembly();