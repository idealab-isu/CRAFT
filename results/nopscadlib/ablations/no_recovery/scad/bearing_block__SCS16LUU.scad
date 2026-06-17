// Parameters
shaft_diameter = 9.0; //[4.5:18.0:0.1]
bore_clearance = 0.1; //[0.0:0.5:0.05]
block_width = 50.0; //[25.0:100.0:0.5]
block_length = 85.0; //[42.5:170.0:0.5]
block_height = 30.0; //[15.0:60.0:0.5]
bearing_outer_diameter = 16.0; //[10.0:32.0:0.1]
bearing_length = 30.0; //[15.0:60.0:0.5]
mount_hole_count = 4; //[2:6:1]
mount_hole_diameter = 5.5; //[3.0:10.0:0.1]
mount_counterbore_diameter = 10.0; //[6.0:18.0:0.1]
mount_counterbore_depth = 4.0; //[1.0:10.0:0.1]
mount_hole_edge_margin = 6.0; //[3.0:15.0:0.5]
mount_hole_spacing_x = 38.0; //[20.0:80.0:0.5]
mount_hole_spacing_y = 70.0; //[30.0:140.0:0.5]
clamp_enabled = 1; //[0:1:1]
clamp_slot_width = 1.5; //[0.8:3.0:0.1]
clamp_slot_depth = 18.0; //[8.0:40.0:0.5]
clamp_screw_diameter = 4.2; //[2.5:8.0:0.1]
clamp_boss_diameter = 12.0; //[8.0:24.0:0.5]
clamp_boss_height = 10.0; //[6.0:20.0:0.5]
bottom_relief_depth = 2.0; //[0.5:6.0:0.1]
bottom_relief_margin = 4.0; //[2.0:10.0:0.5]
chamfer_size = 0.5; //[0.0:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Bearing Block Body with Chamfers
module bearing_block_body_chamfered() {
  minkowski() {
    cube([block_width, block_length, block_height], center=true);
    sphere(r=chamfer_size, center=true);
  }
}

// Mounting Holes with Counterbores
module mount_holes_with_counterbores() {
  union() {
    for (x = [-1, 1])
      for (y = [-1, 1]) {
        translate([x * mount_hole_spacing_x / 2, y * mount_hole_spacing_y / 2, 0]) {
          cylinder(r=mount_hole_diameter / 2, h=block_height + 2 * overlap, center=true);
          translate([0, 0, -block_height / 2 + mount_counterbore_depth / 2])
            cylinder(r=mount_counterbore_diameter / 2, h=mount_counterbore_depth + overlap, center=true);
        }
      }
  }
}

// Shaft Bore
module shaft_bore_or_bearing_bore() {
  rotate([90, 0, 0])
    cylinder(r=(shaft_diameter + bore_clearance) / 2, h=block_length + 2 * overlap, center=true);
}

// Split Clamp Slot and Clamping Screw Bosses
module split_clamp_slot_and_clamping_screw_bosses() {
  union() {
    translate([0, 0, block_height / 2 - clamp_slot_depth / 2])
      cube([clamp_slot_width, block_length + 2 * overlap, clamp_slot_depth + overlap], center=true);
    for (x = [-1, 1]) {
      translate([x * (clamp_slot_width / 2 + clamp_boss_diameter / 2 - overlap), 0, block_height / 2 + clamp_boss_height / 2 - overlap])
        rotate([90, 0, 0])
          cylinder(r=clamp_boss_diameter / 2, h=clamp_boss_height, center=true);
    }
  }
}

// Clamp Screw Hole
module clamp_screw_hole() {
  rotate([0, 90, 0])
    cylinder(r=clamp_screw_diameter / 2, h=block_width + 2 * clamp_boss_diameter + 2 * overlap, center=true);
}

// Bottom Relief Pocket
module bottom_relief_pocket() {
  translate([0, 0, -block_height / 2 + bottom_relief_depth / 2])
    cube([block_width - 2 * bottom_relief_margin, block_length - 2 * bottom_relief_margin, bottom_relief_depth + overlap], center=true);
}

// SBR Bearing Block
module sbr_bearing_block() {
  difference() {
    bearing_block_body_chamfered();
    union() {
      shaft_bore_or_bearing_bore();
      mount_holes_with_counterbores();
      if (clamp_enabled) {
        split_clamp_slot_and_clamping_screw_bosses();
        clamp_screw_hole();
      }
      bottom_relief_pocket();
    }
  }
}

// SCS Bearing Block Hole Positions
module scs_bearing_block_hole_positions() {
  mount_holes_with_counterbores();
  if (clamp_enabled) {
    clamp_screw_hole();
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  union() {
    sbr_bearing_block();
    scs_bearing_block_hole_positions();
  }
}

// SBR Bearing Block Assembly
module sbr_bearing_block_assembly() {
  union() {
    sbr_bearing_block();
    scs_bearing_block_hole_positions();
  }
}

// Final Assembly
module assembly() {
  sbr_bearing_block_assembly();
}

assembly();