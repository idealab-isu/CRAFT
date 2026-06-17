// Parameters
block_width = 8.0; //[4.0:16.0:0.25]
block_height = 12.75; //[6.0:25.5:0.25]
block_length = 19.0; //[10.0:38.0:0.25]
tolerance_clearance = 0.2; //[0.0:0.6:0.05]
bore_diameter = 6.0; //[2.0:10.0:0.1]
nut_capture_depth = 0.0; //[0.0:10.0:0.25]
mount_hole_count = 2; //[0:4:1]
mount_hole_diameter = 3.0; //[1.5:5.0:0.1]
mount_hole_spacing = 10.0; //[6.0:16.0:0.25]
counterbore_diameter = 5.5; //[3.5:9.0:0.1]
counterbore_depth = 2.0; //[0.5:6.0:0.1]
anti_rotation_flat_depth = 0.8; //[0.0:2.0:0.05]
anti_rotation_flat_width = 2.0; //[0.5:5.0:0.1]
edge_chamfer = 0.0; //[0.0:1.5:0.1]
edge_fillet_radius = 0.0; //[0.0:2.0:0.1]
leadscrew_diameter = 5.8; //[2.0:9.5:0.1]
leadscrew_length = 35.0; //[19.0:80.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Leadscrew - detailed geometry
module leadscrew() {
  color("Silver") {
    cylinder(d=leadscrew_diameter, h=leadscrew_length, center=true, $fn=32);
  }
}

// Main block with features
module housing_block() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Main body
      cube([block_width, block_height, block_length], center=true);
      
      // Central bore
      translate([0, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=bore_diameter + tolerance_clearance, h=block_length + 2*overlap, center=true, $fn=32);
      
      // Mounting holes
      if (mount_hole_count > 0) {
        translate([0, 0, mount_hole_spacing/2])
          cylinder(d=mount_hole_diameter + tolerance_clearance, h=block_height + 2*overlap, center=true, $fn=16);
        translate([0, 0, -mount_hole_spacing/2])
          cylinder(d=mount_hole_diameter + tolerance_clearance, h=block_height + 2*overlap, center=true, $fn=16);
      }
      
      // Counterbores
      translate([0, block_height/2 - (counterbore_depth + overlap)/2, mount_hole_spacing/2])
        cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=16);
      translate([0, block_height/2 - (counterbore_depth + overlap)/2, -mount_hole_spacing/2])
        cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=16);
      
      // Anti-rotation feature
      translate([(bore_diameter + tolerance_clearance)/2 - (anti_rotation_flat_depth + overlap)/2, 0, 0])
        cube([anti_rotation_flat_depth + overlap, anti_rotation_flat_width, block_length + 2*overlap], center=true);
    }
  }
}

// Assembly
module assembly() {
  housing_block();
  translate([0, 0, 0]) leadscrew();
}

assembly();