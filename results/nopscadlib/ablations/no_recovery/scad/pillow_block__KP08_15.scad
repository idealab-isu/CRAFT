// Parameters
shaft_diameter = 8; //[4:16:0.1]
shaft_bore_clearance = 0.2; //[0.05:0.6:0.05]
base_length = 55; //[30:110:0.5]
base_width = 42; //[21:84:0.5]
base_thickness = 8; //[4:16:0.5]
overall_height = 28; //[18:56:0.5]
mounting_hole_diameter = 6; //[3:10:0.1]
mounting_hole_clearance = 0.4; //[0.1:1.2:0.1]
mounting_hole_spacing_length = 40; //[25:80:0.5]
mounting_hole_spacing_width = 28; //[16:60:0.5]
bearing_outer_diameter = 22; //[14:44:0.5]
bearing_width = 12; //[6:24:0.5]
housing_length = 40; //[25:80:0.5]
housing_width = 34; //[20:70:0.5]
housing_top_extra = 6; //[2:16:0.5]
trapezoid_top_shrink = 10; //[4:20:0.5]
edge_chamfer = 1; //[0.5:3:0.25]
overlap = 1; //[0.5:2:0.1]

// Right Trapezoid
module right_trapezoid() {
  color("DimGray") {
    translate([0, 0, base_thickness/2 + (overall_height - base_thickness)/2 - overlap/2])
    rotate([0, 90, 0])
    linear_extrude(height=housing_length, center=true) {
      polygon(points=[
        [0, 0],
        [housing_width, 0],
        [housing_width - trapezoid_top_shrink, overall_height - base_thickness],
        [0, overall_height - base_thickness]
      ]);
    }
  }
}

// Sbr Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("Silver") {
    union() {
      translate([0, 0, base_thickness/2 + (bearing_outer_diameter/2 + housing_top_extra) - overlap])
      rotate([0, 90, 0])
      cylinder(r=bearing_outer_diameter/2, h=bearing_width + 2*overlap, center=true);
    }
  }
}

// Kp Pillow Block Assembly
module kp_pillow_block_assembly() {
  color("Black") {
    union() {
      translate([0, 0, base_thickness/2 + (overall_height - base_thickness + overlap)/2 - overlap])
      cube([housing_length, housing_width, overall_height - base_thickness + overlap], center=true);
    }
  }
}

// Scs Bearing Block
module scs_bearing_block() {
  color("Silver") {
    union() {
      translate([0, 0, base_thickness/2 + (bearing_outer_diameter/2 + housing_top_extra) - overlap])
      rotate([0, 90, 0])
      cylinder(r=(shaft_diameter + shaft_bore_clearance)/2, h=housing_length + 2*overlap, center=true);
    }
  }
}

// Kp Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Black") {
    union() {
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mounting_hole_spacing_length/2, y * mounting_hole_spacing_width/2, 0])
          cylinder(r=(mounting_hole_diameter + mounting_hole_clearance)/2, h=base_thickness + 2*overlap, center=true);
    }
  }
}

// Base Plate with Chamfers
module base_plate_with_chamfers() {
  color("Silver") {
    difference() {
      translate([0, 0, 0])
      cube([base_length, base_width, base_thickness], center=true);
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * (base_length/2 - edge_chamfer), y * (base_width/2 - edge_chamfer), 0])
          rotate([0, 0, 45])
          cube([edge_chamfer*2, base_width + 2*overlap, base_thickness + 2*overlap], center=true);
    }
  }
}

// Assembly
module assembly() {
  base_plate_with_chamfers();
  kp_pillow_block_hole_positions();
  kp_pillow_block_assembly();
  right_trapezoid();
  sbr_bearing_block_assembly();
  scs_bearing_block();
}

assembly();