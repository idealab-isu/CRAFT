// Parameters
shaft_diameter = 8.0; //[4.0:16.0:0.1]
block_width = 42.0; //[21.0:84.0:0.5]
block_length = 70.0; //[35.0:140.0:0.5]
block_height = 28.0; //[14.0:56.0:0.5]
shaft_bore_clearance = 0.1; //[0.0:0.5:0.05]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_edge_margin = 5.0; //[2.5:10.0:0.5]
mount_hole_spacing_x = 32.0; //[16.0:64.0:0.5]
mount_hole_spacing_y = 50.0; //[25.0:100.0:0.5]
counterbore_diameter = 9.0; //[6.0:14.0:0.1]
counterbore_depth = 4.0; //[1.0:10.0:0.1]
clamp_slit_width = 1.5; //[0.5:3.0:0.1]
clamp_slit_depth = 18.0; //[8.0:30.0:0.5]
bore_to_top_min_wall = 6.0; //[3.0:12.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
bearing_outer_diameter = 15.0; //[10.0:30.0:0.1]
bearing_length = 24.0; //[12.0:60.0:0.5]

// Modules
module scs_bearing_block() {
  color("Silver") {
    cube([block_width, block_length, block_height], center=true);
  }
}

module scs_bearing_block_hole_positions() {
  color("DimGray") {
    translate([mount_hole_spacing_x/2, mount_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mount_hole_diameter/2, center=true);
    translate([-mount_hole_spacing_x/2, mount_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mount_hole_diameter/2, center=true);
    translate([mount_hole_spacing_x/2, -mount_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mount_hole_diameter/2, center=true);
    translate([-mount_hole_spacing_x/2, -mount_hole_spacing_y/2, 0])
      cylinder(h=block_height + 2*overlap, r=mount_hole_diameter/2, center=true);
  }
}

module sbr_bearing_block_hole_positions() {
  color("DimGray") {
    translate([mount_hole_spacing_x/2, mount_hole_spacing_y/2, -block_height/2 + (counterbore_depth + overlap)/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
    translate([-mount_hole_spacing_x/2, mount_hole_spacing_y/2, -block_height/2 + (counterbore_depth + overlap)/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
    translate([mount_hole_spacing_x/2, -mount_hole_spacing_y/2, -block_height/2 + (counterbore_depth + overlap)/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
    translate([-mount_hole_spacing_x/2, -mount_hole_spacing_y/2, -block_height/2 + (counterbore_depth + overlap)/2])
      cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
  }
}

module scs_bearing_block_assembly() {
  color("Silver") {
    difference() {
      scs_bearing_block();
      translate([0, 0, block_height/2 - bore_to_top_min_wall - (shaft_diameter + shaft_bore_clearance)/2])
        rotate([90, 0, 0])
        cylinder(h=block_length + 2*overlap, r=(shaft_diameter + shaft_bore_clearance)/2, center=true);
      scs_bearing_block_hole_positions();
      sbr_bearing_block_hole_positions();
      translate([0, 0, block_height/2 - (clamp_slit_depth + overlap)/2])
        cube([clamp_slit_width, block_length + 2*overlap, clamp_slit_depth + overlap], center=true);
    }
  }
}

module assembly() {
  scs_bearing_block_assembly();
}

assembly();