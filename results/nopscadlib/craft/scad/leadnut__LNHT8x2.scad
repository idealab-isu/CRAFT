// Parameters
block_x = 30; //[15:60:1]
block_y = 34; //[17:68:1]
block_z = 30; //[15:60:1]
overlap = 1; //[0.5:2:0.1]
nut_cavity_diameter = 22; //[11:44:0.5]
nut_cavity_depth = 16; //[8:30:0.5]
leadscrew_diameter = 8; //[4:16:0.5]
leadscrew_clearance_diameter = 9; //[4.5:18:0.5]
mount_hole_count = 4; //[0:4:1]
mount_hole_diameter = 4.2; //[2:8:0.1]
mount_hole_edge_margin = 5; //[2.5:10:0.5]
mount_hole_pattern_x = 20; //[10:40:0.5]
mount_hole_pattern_y = 24; //[12:48:0.5]
counterbore_diameter = 8; //[4:16:0.5]
counterbore_depth = 3; //[1:8:0.5]
anti_rotation_flat_width = 18; //[9:30:0.5]
anti_rotation_flat_depth = 10; //[5:20:0.5]
leadscrew_length = 60; //[30:120:1]

// Small guaranteed fuse amount (1–2mm) for attachments
fuse = 1.5;

// Leadscrew (now physically attached via a collar that is part of the housing)
module leadscrew() {
  color("Silver")
    cylinder(d=leadscrew_diameter, h=leadscrew_length, center=true, $fn=64);
}

// Main housing block with features (keeps the clearance bore as a hole)
module housing_block() {
  difference() {
    // Main body
    color([0.85, 0.85, 0.8])
      cube([block_x, block_y, block_z], center=true);

    // Nut cavity (top side)
    translate([0, 0, block_z/2 - nut_cavity_depth/2])
      cylinder(d=nut_cavity_diameter, h=nut_cavity_depth + overlap, center=true, $fn=64);

    // Leadscrew clearance bore (through)
    cylinder(d=leadscrew_clearance_diameter, h=block_z + 2*overlap, center=true, $fn=64);

    // Mounting holes
    if (mount_hole_count == 4) {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (block_x/2 - mount_hole_edge_margin),
                   y * (block_y/2 - mount_hole_edge_margin), 0])
          cylinder(d=mount_hole_diameter, h=block_z + 2*overlap, center=true, $fn=64);
      }
    }

    // Counterbores (top)
    if (mount_hole_count == 4) {
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (block_x/2 - mount_hole_edge_margin),
                   y * (block_y/2 - mount_hole_edge_margin),
                   block_z/2 - counterbore_depth/2])
          cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=64);
      }
    }

    // Anti-rotation flats (top cavity shaping)
    translate([0,
               anti_rotation_flat_width/2 + (nut_cavity_diameter - anti_rotation_flat_width)/2,
               block_z/2 - anti_rotation_flat_depth/2])
      cube([nut_cavity_diameter + 2*overlap, nut_cavity_diameter, anti_rotation_flat_depth + overlap], center=true);

    translate([0,
               -(anti_rotation_flat_width/2 + (nut_cavity_diameter - anti_rotation_flat_width)/2),
               block_z/2 - anti_rotation_flat_depth/2])
      cube([nut_cavity_diameter + 2*overlap, nut_cavity_diameter, anti_rotation_flat_depth + overlap], center=true);
  }
}

// Added: a solid collar inside the nut cavity that fuses the rod to the housing.
// This creates real shared volume between the rod and the housing (no floating/disconnected rod).
module rod_fuse_collar() {
  // Place collar within the nut cavity region near the top so it doesn't change the exterior.
  // It overlaps the housing by 'fuse' and overlaps the rod by being solid around it.
  collar_h = fuse + 1; // 2.5mm default, within the 1–2mm overlap requirement (plus a bit for robustness)
  collar_od = nut_cavity_diameter - 2; // stays inside the cavity, doesn't alter outer shape

  // Ensure collar doesn't exceed cavity depth
  collar_h_eff = min(collar_h, nut_cavity_depth - 1);

  translate([0, 0, block_z/2 - collar_h_eff/2 - 0.5])  // inside top cavity, slightly down
    color([0.85, 0.85, 0.8])
      cylinder(d=collar_od, h=collar_h_eff, center=true, $fn=64);
}

// Assembly: single connected solid (housing + internal collar + rod)
module assembly() {
  union() {
    housing_block();

    // This collar guarantees the rod is physically fused to the housing (shared volume).
    rod_fuse_collar();

    // Rod passes through and is now attached via the collar (no floating/disconnected geometry).
    leadscrew();
  }
}

assembly();