// Parameters
block_length = 40.0; //[20.0:80.0:0.5]
block_width = 35.0; //[18.0:70.0:0.5]
block_height = 28.0; //[14.0:56.0:0.5]
shaft_diameter = 8.0; //[4.0:16.0:0.1]
bearing_bore_diameter = 8.0; //[4.0:16.0:0.1]
bearing_outer_diameter = 15.0; //[8.0:30.0:0.1]
bearing_length = 24.0; //[12.0:48.0:0.5]
bearing_seat_tolerance = 0.2; //[0.0:0.6:0.05]
mount_hole_count = 4; //[2:4:1]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x = 28.0; //[14.0:56.0:0.5]
mount_hole_spacing_y = 22.0; //[11.0:44.0:0.5]
mount_hole_edge_margin = 4.0; //[2.0:10.0:0.5]
counterbore_diameter = 9.0; //[6.0:16.0:0.1]
counterbore_depth = 4.0; //[1.0:10.0:0.5]
clamp_slot_width = 2.0; //[1.0:5.0:0.1]
clamp_slot_depth = 10.0; //[5.0:20.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// SCS Bearing Block
module scs_bearing_block() {
  color("Silver") {
    cube([block_length, block_width, block_height], center=true);
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  color("Black") {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_x / 2, y * mount_hole_spacing_y / 2, 0])
          cylinder(r=mount_hole_diameter/2, h=block_height + 2*overlap, center=true);
  }
}

// SBR Bearing Block Hole Positions
module sbr_bearing_block_hole_positions() {
  color("Black") {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_x / 2, y * mount_hole_spacing_y / 2, 0])
          cylinder(r=mount_hole_diameter/2, h=block_height + 2*overlap, center=true);
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  difference() {
    scs_bearing_block();
    union() {
      // Bearing bore
      rotate([0, 90, 0])
        cylinder(r=(bearing_outer_diameter + bearing_seat_tolerance)/2, h=bearing_length + 2*overlap, center=true);
      // Shaft clearance
      rotate([0, 90, 0])
        cylinder(r=shaft_diameter/2, h=block_length + 2*overlap, center=true);
      // Mounting holes
      scs_bearing_block_hole_positions();
      // Counterbores
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mount_hole_spacing_x / 2, y * mount_hole_spacing_y / 2, block_height/2 - (counterbore_depth + overlap)/2])
            cylinder(r=counterbore_diameter/2, h=counterbore_depth + overlap, center=true);
      // Clamp slot
      translate([0, block_width/2 - (clamp_slot_depth + overlap)/2, 0])
        cube([bearing_length + 2*overlap, clamp_slot_depth + overlap, clamp_slot_width], center=true);
    }
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
  sbr_bearing_block_hole_positions();
}

assembly();