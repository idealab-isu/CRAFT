// Parameters
block_width_x = 30; //[15:60:1]
block_depth_y = 34; //[17:68:1]
block_height_z = 30; //[15:60:1]
leadscrew_diameter = 8; //[4:16:0.5]
leadscrew_clearance = 0.3; //[0.1:1:0.05]
nut_pocket_diameter = 16; //[8:32:0.5]
nut_pocket_depth = 12; //[6:24:0.5]
mount_hole_diameter = 4; //[2:8:0.5]
mount_hole_pattern_x = 20; //[10:40:1]
mount_hole_pattern_y = 24; //[12:48:1]
anti_rotation_feature_size = 3; //[1.5:8:0.5]
anti_rotation_feature_z = 0; //[-10:10:0.5]
leadscrew_length = 60; //[30:120:1]
overlap = 1; //[0.5:2:0.1]

// Leadscrew - complete geometry
module leadscrew() {
  color("Silver") {
    cylinder(r=leadscrew_diameter/2, h=leadscrew_length, center=true, $fn=32);
  }
}

// Main housing block
module housing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Main body block
      cube([block_width_x, block_depth_y, block_height_z], center=true);
      
      // Nut capture pocket
      translate([0, 0, block_height_z/2 - nut_pocket_depth/2])
        cylinder(r=nut_pocket_diameter/2, h=nut_pocket_depth + overlap, center=true, $fn=32);
      
      // Leadscrew through-bore
      cylinder(r=(leadscrew_diameter + 2*leadscrew_clearance)/2, h=block_height_z + 2*overlap, center=true, $fn=32);
      
      // Mounting holes
      for (x = [-mount_hole_pattern_x/2, mount_hole_pattern_x/2])
        for (y = [-mount_hole_pattern_y/2, mount_hole_pattern_y/2])
          translate([x, y, 0])
            cylinder(r=mount_hole_diameter/2, h=block_height_z + 2*overlap, center=true, $fn=32);
      
      // Anti-rotation feature
      rotate([0, 90, 0])
        translate([0, 0, anti_rotation_feature_z])
          cylinder(r=anti_rotation_feature_size/2, h=block_width_x + 2*overlap, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  union() {
    housing();
    leadscrew();
  }
}

assembly();