// Parameters
shaft_diameter = 8.0; //[4.0:16.0:0.1]
block_width = 40.0; //[20.0:80.0:0.5]
block_length = 68.0; //[34.0:136.0:0.5]
block_height = 28.0; //[14.0:56.0:0.5]
bore_clearance = 0.1; //[0.0:0.5:0.05]
mounting_hole_diameter = 5.0; //[3.0:8.0:0.1]
mounting_hole_spacing_x = 30.0; //[15.0:60.0:0.5]
mounting_hole_spacing_y = 50.0; //[25.0:100.0:0.5]
counterbore_diameter = 9.0; //[6.0:14.0:0.1]
counterbore_depth = 4.0; //[2.0:10.0:0.1]
retention_set_screw_diameter = 3.0; //[2.0:6.0:0.1]
retention_set_screw_offset_y = 18.0; //[8.0:30.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Main block body
module block_body() {
  color("Silver") cube([block_width, block_length, block_height], center=true);
}

// Shaft bore
module shaft_bore() {
  rotate([90, 0, 0])
    translate([0, 0, 0])
    cylinder(h=block_length + 2*overlap, r=(shaft_diameter + bore_clearance)/2, center=true);
}

// Mounting holes
module mounting_holes() {
  union() {
    translate([mounting_hole_spacing_x/2, mounting_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mounting_hole_diameter/2, center=true);
    translate([-mounting_hole_spacing_x/2, mounting_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mounting_hole_diameter/2, center=true);
    translate([mounting_hole_spacing_x/2, -mounting_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mounting_hole_diameter/2, center=true);
    translate([-mounting_hole_spacing_x/2, -mounting_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mounting_hole_diameter/2, center=true);
  }
}

// Counterbores
module counterbores() {
  union() {
    translate([mounting_hole_spacing_x/2, mounting_hole_spacing_y/2, -block_height/2 + counterbore_depth/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
    translate([-mounting_hole_spacing_x/2, mounting_hole_spacing_y/2, -block_height/2 + counterbore_depth/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
    translate([mounting_hole_spacing_x/2, -mounting_hole_spacing_y/2, -block_height/2 + counterbore_depth/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
    translate([-mounting_hole_spacing_x/2, -mounting_hole_spacing_y/2, -block_height/2 + counterbore_depth/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
  }
}

// Retention set screw holes
module set_screw_holes() {
  union() {
    rotate([0, 90, 0])
      translate([0, retention_set_screw_offset_y, 0])
      cylinder(h=block_width + 2*overlap, r=retention_set_screw_diameter/2, center=true);
    rotate([0, 90, 0])
      translate([0, -retention_set_screw_offset_y, 0])
      cylinder(h=block_width + 2*overlap, r=retention_set_screw_diameter/2, center=true);
  }
}

// Final bearing block assembly
module bearing_block_final() {
  difference() {
    block_body();
    shaft_bore();
    mounting_holes();
    counterbores();
    set_screw_holes();
  }
}

// Assembly
module assembly() {
  bearing_block_final();
}

assembly();