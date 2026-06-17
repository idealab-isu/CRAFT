// Parameters
shaft_diameter_mm = 6.0; //[3.0:12.0:0.1]
block_length_mm = 34.0; //[17.0:68.0:0.5]
block_width_mm = 30.0; //[15.0:60.0:0.5]
block_height_mm = 20.0; //[10.0:40.0:0.5]
shaft_bore_clearance_mm = 0.2; //[0.0:1.0:0.05]
mount_hole_diameter_mm = 4.0; //[2.0:8.0:0.1]
mount_hole_edge_margin_mm = 5.0; //[2.5:10.0:0.5]
mount_hole_pattern_length_mm = 24.0; //[12.0:48.0:0.5]
mount_hole_pattern_width_mm = 20.0; //[10.0:40.0:0.5]
chamfer_mm = 0.5; //[0.0:2.0:0.1]
eps_mm = 0.8; //[0.2:2.0:0.1]
retention_slot_width_mm = 2.0; //[1.0:5.0:0.1]
retention_slot_depth_mm = 8.0; //[4.0:16.0:0.5]
bearing_outer_diameter_mm = 12.0; //[8.0:24.0:0.1]
bearing_length_mm = 24.0; //[12.0:40.0:0.5]
bearing_shell_thickness_mm = 1.0; //[0.5:3.0:0.1]
trapezoid_base_mm = 10.0; //[5.0:20.0:0.5]
trapezoid_top_mm = 6.0; //[3.0:15.0:0.5]
trapezoid_height_mm = 6.0; //[3.0:15.0:0.5]
assembly_plate_thickness_mm = 3.0; //[1.0:10.0:0.5]

// Linear Bearing - complete geometry
module linear_bearing() {
  color("Silver") {
    difference() {
      // Outer shell
      cylinder(r=bearing_outer_diameter_mm/2, h=bearing_length_mm, center=true, $fn=64);
      // Inner bore
      cylinder(r=(bearing_outer_diameter_mm/2) - bearing_shell_thickness_mm, h=bearing_length_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Right Trapezoid - complete geometry
module right_trapezoid() {
  color("DimGray") {
    translate([block_length_mm/2 - trapezoid_base_mm/2, -block_width_mm/2 + trapezoid_height_mm/2, -block_height_mm/2 - assembly_plate_thickness_mm/2 + eps_mm])
    linear_extrude(height=assembly_plate_thickness_mm, center=true) {
      polygon(points=[[0, 0], [trapezoid_base_mm, 0], [trapezoid_top_mm, trapezoid_height_mm], [0, trapezoid_height_mm]]);
    }
  }
}

// Sbr Bearing Block Assembly - complete geometry
module sbr_bearing_block_assembly() {
  color("Black") {
    difference() {
      // Main block
      cube([block_length_mm, block_width_mm, block_height_mm], center=true);
      // Shaft bore
      translate([0, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=(shaft_diameter_mm + shaft_bore_clearance_mm)/2, h=block_length_mm + 2*eps_mm, center=true, $fn=64);
      // Retention slot
      translate([0, 0, block_height_mm/2 - (retention_slot_depth_mm + eps_mm)/2])
      cube([block_length_mm + 2*eps_mm, retention_slot_width_mm, retention_slot_depth_mm + eps_mm], center=true);
      // Chamfers
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * (block_length_mm/2 - chamfer_mm/2), y * (block_width_mm/2 - chamfer_mm/2), 0])
          cube([chamfer_mm, chamfer_mm, block_height_mm + 2*eps_mm], center=true);
    }
  }
}

// Scs Bearing Block Assembly - complete geometry
module scs_bearing_block_assembly() {
  color("Black") {
    union() {
      sbr_bearing_block_assembly();
      // Assembly plate
      translate([0, 0, -block_height_mm/2 - assembly_plate_thickness_mm/2 + eps_mm])
      cube([block_length_mm, block_width_mm, assembly_plate_thickness_mm], center=true);
      // Right trapezoid
      right_trapezoid();
    }
  }
}

// Sbr Bearing Block Hole Positions - complete geometry
module sbr_bearing_block_hole_positions() {
  color("Silver") {
    union() {
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mount_hole_pattern_length_mm/2, y * mount_hole_pattern_width_mm/2, 0])
          cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*eps_mm, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
  sbr_bearing_block_hole_positions();
  linear_bearing();
}

assembly();