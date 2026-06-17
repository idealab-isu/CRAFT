// Parameters
block_width = 16; //[8:32:0.1]
block_height = 28; //[14:56:0.1]
block_length = 42.5; //[21.25:85:0.1]
tolerance_clearance = 0.2; //[0.05:0.6:0.01]
nut_outer_diameter = 12; //[6:24:0.1]
nut_length = 18; //[8:36:0.1]
leadscrew_thread_diameter = 8; //[4:16:0.1]
nut_bore_diameter = 8.4; //[4.2:16.8:0.1]
nut_cavity_depth = 14; //[6:28:0.1]
mount_hole_diameter = 3.4; //[2:6.8:0.1]
mount_hole_spacing_x = 10; //[6:14:0.1]
mount_hole_spacing_y = 30; //[18:38:0.1]
counterbore_diameter = 6.5; //[4:13:0.1]
counterbore_depth = 3; //[1:8:0.1]
clamp_slot_width = 2; //[1:5:0.1]
clamp_slot_length = 20; //[10:40:0.1]
clamp_slot_depth = 18; //[8:26:0.1]
set_screw_diameter = 3; //[2:6:0.1]
set_screw_offset_z = 8; //[4:14:0.1]
anti_rotation_flat_depth = 1.5; //[0.5:4:0.1]
access_slot_width = 6; //[3:12:0.1]
access_slot_height = 10; //[5:20:0.1]
access_slot_length = 18; //[8:36:0.1]
overlap = 1; //[0.5:2:0.1]

// Leadscrew - complete geometry
module leadscrew() {
  color("Silver") {
    cylinder(r=leadscrew_thread_diameter/2, h=block_length + block_length, center=true, $fn=64);
  }
}

// Main body block with features
module housing_block_with_features() {
  difference() {
    // Main body block
    color([0.85, 0.85, 0.8]) cube([block_width, block_length, block_height], center=true);
    
    // Nut cavity or bore
    translate([0, 0, block_height/2 - nut_cavity_depth/2])
      rotate([90, 0, 0])
      cylinder(r=(nut_outer_diameter + 2*tolerance_clearance)/2, h=nut_length + 2*overlap, center=true, $fn=64);
    
    // Leadscrew bore
    translate([0, 0, 0])
      rotate([90, 0, 0])
      cylinder(r=(nut_bore_diameter + 2*tolerance_clearance)/2, h=block_length + 2*overlap, center=true, $fn=64);
    
    // Nut retention feature: clamp slot
    translate([0, 0, block_height/2 - (clamp_slot_depth + overlap)/2])
      cube([clamp_slot_width, clamp_slot_length, clamp_slot_depth + overlap], center=true);
    
    // Nut retention feature: set screw holes
    translate([0, -mount_hole_spacing_y/4, block_height/2 - set_screw_offset_z])
      rotate([0, 90, 0])
      cylinder(r=(set_screw_diameter + 2*tolerance_clearance)/2, h=block_width + 2*overlap, center=true, $fn=64);
    
    translate([0, mount_hole_spacing_y/4, block_height/2 - set_screw_offset_z])
      rotate([0, 90, 0])
      cylinder(r=(set_screw_diameter + 2*tolerance_clearance)/2, h=block_width + 2*overlap, center=true, $fn=64);
    
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, 0])
        cylinder(r=(mount_hole_diameter + 2*tolerance_clearance)/2, h=block_height + 2*overlap, center=true, $fn=64);
    }
    
    // Fastener counterbores
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_hole_spacing_x/2, y * mount_hole_spacing_y/2, block_height/2 - (counterbore_depth + overlap)/2])
        cylinder(r=(counterbore_diameter + 2*tolerance_clearance)/2, h=counterbore_depth + overlap, center=true, $fn=64);
    }
    
    // Anti-rotation key or flat
    translate([(nut_outer_diameter + 2*tolerance_clearance)/2 - (anti_rotation_flat_depth + overlap)/2, 0, block_height/2 - nut_cavity_depth/2])
      cube([anti_rotation_flat_depth + overlap, nut_length + 2*overlap, nut_cavity_depth + 2*overlap], center=true);
    
    // Access slot or clearance cut
    translate([0, 0, -block_height/2 + access_slot_height/2])
      cube([access_slot_width, access_slot_length, access_slot_height], center=true);
  }
}

// Assembly
module assembly() {
  union() {
    housing_block_with_features();
    leadscrew();
  }
}

assembly();