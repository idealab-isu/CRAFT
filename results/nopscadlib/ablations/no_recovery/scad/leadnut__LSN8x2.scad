// Parameters
block_width = 8.0; //[4.0:16.0:0.1]
block_depth = 10.2; //[5.1:20.4:0.1]
block_height = 15.0; //[7.5:30.0:0.1]
tolerance_clearance = 0.2; //[0.0:0.6:0.05]
nut_capture_style = 1; //[0:1:1]
bore_diameter = 5.2; //[2.6:10.4:0.1]
bore_depth = 12.0; //[6.0:15.0:0.1]
anti_rotation_flat_width = 6.6; //[3.3:8.0:0.1]
anti_rotation_flat_depth = 7.0; //[3.5:10.2:0.1]
anti_rotation_height = 6.0; //[3.0:12.0:0.1]
mount_hole_count = 2; //[0:4:1]
mount_hole_diameter = 2.2; //[1.0:4.4:0.1]
mount_hole_spacing = 5.0; //[2.5:7.0:0.1]
mount_hole_axis = 0; //[0:1:1]
counterbore_diameter = 4.2; //[2.0:8.4:0.1]
counterbore_depth = 2.0; //[0.5:5.0:0.1]
chamfer_size = 0.5; //[0.0:1.5:0.1]
leadscrew_diameter = 4.0; //[2.0:8.0:0.1]
leadscrew_length = 25.0; //[15.0:60.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]

// Leadscrew - complete geometry
module leadscrew() {
  color("Silver") {
    cylinder(d=leadscrew_diameter, h=leadscrew_length, center=true, $fn=32);
  }
}

// Main block with features
module main_block() {
  difference() {
    // Main block
    color([0.85, 0.85, 0.8]) cube([block_width, block_depth, block_height], center=true);
    
    // Nut bore or pocket
    translate([0, 0, 0])
      cylinder(d=bore_diameter + tolerance_clearance, h=block_height + 2*overlap, center=true, $fn=32);
    
    // Anti-rotation feature
    translate([0, 0, block_height/2 - (anti_rotation_height + tolerance_clearance)/2 - overlap])
      cube([anti_rotation_flat_width + tolerance_clearance, anti_rotation_flat_depth + tolerance_clearance, anti_rotation_height + tolerance_clearance], center=true);
    
    // Mounting holes
    if (mount_hole_count >= 2) {
      translate([mount_hole_spacing/2, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=mount_hole_diameter + tolerance_clearance, h=block_depth + 2*overlap, center=true, $fn=32);
      
      translate([-mount_hole_spacing/2, 0, 0])
        rotate([90, 0, 0])
        cylinder(d=mount_hole_diameter + tolerance_clearance, h=block_depth + 2*overlap, center=true, $fn=32);
      
      // Counterbores
      translate([mount_hole_spacing/2, block_depth/2 - (counterbore_depth + overlap)/2, 0])
        rotate([90, 0, 0])
        cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=32);
      
      translate([-mount_hole_spacing/2, block_depth/2 - (counterbore_depth + overlap)/2, 0])
        rotate([90, 0, 0])
        cylinder(d=counterbore_diameter, h=counterbore_depth + overlap, center=true, $fn=32);
    }
    
    // Lead-in chamfers
    translate([0, 0, block_height/2 - (2*chamfer_size + overlap)/2])
      cylinder(r1=(bore_diameter + tolerance_clearance)/2 + chamfer_size, r2=0, h=2*chamfer_size + overlap, center=true, $fn=32);
    
    translate([0, 0, -block_height/2 + (2*chamfer_size + overlap)/2])
      rotate([180, 0, 0])
      cylinder(r1=(bore_diameter + tolerance_clearance)/2 + chamfer_size, r2=0, h=2*chamfer_size + overlap, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  union() {
    main_block();
    leadscrew();
  }
}

assembly();