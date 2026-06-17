// Parameters
shaft_diameter = 8.0; //[4.0:16.0:0.1]
bore_clearance = 0.2; //[0.0:0.6:0.05]
base_length = 55.0; //[30.0:110.0:1]
base_width = 42.0; //[21.0:84.0:1]
base_thickness = 8.0; //[4.0:16.0:0.5]
overall_height = 30.0; //[18.0:60.0:1]
mount_hole_diameter = 6.5; //[3.0:10.0:0.1]
mount_hole_center_spacing = 42.0; //[20.0:90.0:1]
mount_hole_edge_margin_length = 6.5; //[3.0:15.0:0.5]
mount_hole_edge_margin_width = 8.0; //[4.0:16.0:0.5]
fillet_radius = 2.0; //[0.0:6.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
housing_length = 40.0; //[25.0:80.0:1]
housing_outer_diameter = 24.0; //[16.0:48.0:0.5]
pedestal_length = 40.0; //[25.0:80.0:1]
pedestal_width = 26.0; //[16.0:52.0:1]
pedestal_height = 10.0; //[6.0:20.0:0.5]
seat_diameter = 18.0; //[12.0:36.0:0.5]
seat_depth = 6.0; //[2.0:12.0:0.5]
trapezoid_base = 10.0; //[5.0:25.0:0.5]
trapezoid_top = 6.0; //[3.0:20.0:0.5]
trapezoid_height = 10.0; //[5.0:25.0:0.5]
trapezoid_thickness = 12.0; //[6.0:30.0:1]

// Right Trapezoid
module right_trapezoid() {
  color("Silver") {
    linear_extrude(height=trapezoid_thickness) {
      polygon(points=[
        [0, 0],
        [trapezoid_base, 0],
        [trapezoid_top, trapezoid_height],
        [0, trapezoid_height]
      ]);
    }
  }
}

// Sbr Bearing Block Assembly
module sbr_bearing_block_assembly() {
  color("DimGray") {
    // Placeholder for detailed geometry
    cube([20, 20, 20], center=true);
  }
}

// Kp Pillow Block Assembly
module kp_pillow_block_assembly() {
  color("Black") {
    // Base Plate
    translate([0, 0, base_thickness/2])
      cube([base_length, base_width, base_thickness], center=true);
    // Pedestal
    translate([0, 0, base_thickness + pedestal_height/2 - overlap])
      cube([pedestal_length, pedestal_width, pedestal_height], center=true);
    // Housing
    translate([0, 0, base_thickness + pedestal_height + housing_outer_diameter/2 - overlap])
      rotate([0, 90, 0])
      cylinder(r=housing_outer_diameter/2, h=housing_length, center=true);
  }
}

// Scs Bearing Block
module scs_bearing_block() {
  color("DimGray") {
    // Placeholder for detailed geometry
    cube([20, 20, 20], center=true);
  }
}

// Kp Pillow Block Hole Positions
module kp_pillow_block_hole_positions() {
  color("Silver") {
    // Left Mounting Hole
    translate([-mount_hole_center_spacing/2, 0, 0])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
    // Right Mounting Hole
    translate([mount_hole_center_spacing/2, 0, 0])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true);
  }
}

// Assembly
module assembly() {
  kp_pillow_block_assembly();
  kp_pillow_block_hole_positions();
  translate([0, pedestal_width/2 - overlap, base_thickness/2 + overlap])
    rotate([0, 90, 0])
    right_trapezoid();
  translate([0, 0, overall_height + 10])
    sbr_bearing_block_assembly();
  translate([0, 0, overall_height + 30])
    scs_bearing_block();
}

assembly();