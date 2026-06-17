// Parameters
shaft_diameter = 8.0; //[4.0:16.0:0.1]
base_length = 55.0; //[30.0:110.0:0.5]
base_width = 42.0; //[21.0:84.0:0.5]
base_thickness = 8.0; //[4.0:16.0:0.5]
overall_height = 28.0; //[14.0:56.0:0.5]
mount_hole_diameter = 6.5; //[3.0:12.0:0.1]
mount_hole_spacing = 42.0; //[20.0:90.0:0.5]
mount_hole_edge_offset = 10.0; //[5.0:20.0:0.5]
bearing_outer_diameter = 22.0; //[14.0:44.0:0.1]
bearing_width = 7.0; //[4.0:20.0:0.1]
fillet_radius = 2.0; //[0.5:6.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
housing_length_x = 40.0; //[25.0:80.0:0.5]
housing_width_y = 26.0; //[16.0:52.0:0.5]
housing_base_height = 12.0; //[6.0:24.0:0.5]
housing_top_radius = 14.0; //[8.0:28.0:0.5]
housing_top_length_y = 24.0; //[14.0:48.0:0.5]
bearing_seat_depth = 10.0; //[5.0:20.0:0.5]

// Right Trapezoid
module right_trapezoid() {
  color("DimGray") {
    linear_extrude(height=housing_width_y, center=true) {
      polygon(points=[
        [0, 0],
        [housing_length_x/2, 0],
        [housing_length_x/2 - (housing_length_x*0.15), housing_base_height],
        [0, housing_base_height]
      ]);
    }
  }
}

// KP Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Silver") {
    translate([-mount_hole_spacing/2, base_width/2 - mount_hole_edge_offset, 0])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    translate([mount_hole_spacing/2, base_width/2 - mount_hole_edge_offset, 0])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
  }
}

// KP Pillow Block
module kp_pillow_block() {
  color("Black") {
    union() {
      translate([0, 0, base_thickness/2 + housing_base_height/2 - overlap])
        cube([housing_length_x, housing_width_y, housing_base_height], center=true);
      translate([0, 0, base_thickness/2 + housing_base_height - overlap + (overall_height - base_thickness - housing_base_height)/2])
        rotate([90, 0, 0])
        cylinder(r=housing_top_radius, h=housing_top_length_y, center=true);
      right_trapezoid();
    }
  }
}

// KP Pillow Block Assembly
module kp_pillow_block_assembly() {
  difference() {
    kp_pillow_block();
    translate([0, 0, base_thickness/2 + housing_base_height - overlap + (overall_height - base_thickness - housing_base_height)/2])
      rotate([90, 0, 0])
      cylinder(r=shaft_diameter/2, h=base_width + housing_top_length_y + 2*overlap, center=true);
    translate([0, 0, base_thickness/2 + housing_base_height - overlap + (overall_height - base_thickness - housing_base_height)/2])
      rotate([90, 0, 0])
      cylinder(r=bearing_outer_diameter/2, h=bearing_seat_depth, center=true);
    kp_pillow_block_hole_positions();
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  kp_pillow_block_assembly();
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();