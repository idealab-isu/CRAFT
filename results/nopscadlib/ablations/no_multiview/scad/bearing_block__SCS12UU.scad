// Parameters
shaft_diameter = 8; //[4:16:0.1]
block_length = 42; //[21:84:0.5]
block_width = 36; //[18:72:0.5]
block_height = 28; //[14:56:0.5]
bearing_outer_diameter = 15; //[10:30:0.1]
bearing_length = 24; //[12:48:0.5]
bearing_fit_clearance = 0.2; //[0:0.6:0.05]
material_clearance = 0.2; //[0:0.6:0.05]
mount_hole_count = 4; //[2:4:1]
mount_hole_diameter = 5; //[3:8:0.1]
mount_hole_spacing_x = 30; //[15:60:0.5]
mount_hole_spacing_y = 24; //[12:48:0.5]
mount_hole_counterbore_diameter = 9; //[6:16:0.1]
mount_hole_counterbore_depth = 4; //[2:10:0.1]
clamp_slot_width = 3; //[1.5:6:0.1]
clamp_slot_height = 18; //[10:26:0.5]
clamp_slot_length = 18; //[10:30:0.5]
clamp_slot_x_offset = 0; //[-6:6:0.5]
edge_chamfer = 1.2; //[0:3:0.1]
minkowski_segments_radius = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// Bearing Block Body with Chamfers
module bearing_block_body() {
  color([0.85, 0.85, 0.8]) {
    minkowski() {
      cube([block_length, block_width, block_height], center=true);
      sphere(r=minkowski_segments_radius, center=true);
    }
  }
}

// Central Bearing Bore
module central_bearing_bore() {
  cylinder(h=block_length + 2*overlap, r=(shaft_diameter/2) + material_clearance/2, center=true);
}

// Bearing Seat Bore
module bearing_seat_bore() {
  cylinder(h=bearing_length + 2*overlap, r=(bearing_outer_diameter/2) + bearing_fit_clearance/2, center=true);
}

// Clamp Slot
module clamp_slot() {
  translate([clamp_slot_x_offset, 0, (block_height/2) - (clamp_slot_height/2) - overlap])
    cube([clamp_slot_length, clamp_slot_width, clamp_slot_height], center=true);
}

// Mounting Holes
module mounting_hole_pattern() {
  union() {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, 0])
          cylinder(h=block_height + 2*overlap, r=(mount_hole_diameter/2) + material_clearance/2, center=true);
  }
}

// Mounting Hole Counterbores
module mounting_hole_counterbore() {
  union() {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, (-block_height/2) + (mount_hole_counterbore_depth/2)])
          cylinder(h=mount_hole_counterbore_depth + overlap, r=mount_hole_counterbore_diameter/2, center=true);
  }
}

// SCS Bearing Block
module scs_bearing_block() {
  difference() {
    bearing_block_body();
    central_bearing_bore();
    bearing_seat_bore();
    clamp_slot();
    mounting_hole_pattern();
    mounting_hole_counterbore();
  }
}

// SCS Bearing Block Assembly
module scs_bearing_block_assembly() {
  union() {
    scs_bearing_block();
    translate([0, 0, -block_height/2])
      cube([block_length, block_width, overlap], center=true);
  }
}

// Assembly
module assembly() {
  scs_bearing_block_assembly();
}

assembly();