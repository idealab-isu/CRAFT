// Parameters
block_width = 8.0; //[4.0:16.0:0.25]
block_height = 12.75; //[6.0:25.5:0.25]
block_length = 19.0; //[9.5:38.0:0.25]
tolerance_clearance = 0.2; //[0.0:0.6:0.05]
nut_capture_diameter = 7.0; //[4.0:12.0:0.1]
nut_capture_depth = 8.0; //[3.0:18.0:0.25]
leadscrew_clearance_diameter = 4.2; //[2.0:10.0:0.1]
mount_hole_count = 0; //[0:4:1]
mount_hole_diameter = 3.2; //[1.5:6.0:0.1]
mount_hole_spacing = 12.0; //[6.0:24.0:0.25]
counterbore_diameter = 6.0; //[3.5:10.0:0.1]
counterbore_depth = 2.0; //[0.5:6.0:0.1]
chamfer_size = 0.5; //[0.0:2.0:0.1]
anti_rotation_flat_depth = 0.8; //[0.0:2.5:0.1]
anti_rotation_flat_width = 3.0; //[1.0:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
leadscrew_length = 30.0; //[10.0:80.0:1]

// Leadscrew - detailed geometry
module leadscrew() {
  color("Silver") {
    // Leadscrew body
    cylinder(d=leadscrew_clearance_diameter, h=leadscrew_length, center=true, $fn=32);
    // Thread representation (simplified)
    translate([0, 0, -leadscrew_length/2])
      for (i = [0:leadscrew_length/2]) {
        rotate([0, 0, i * 360 / (leadscrew_length/2)])
          translate([leadscrew_clearance_diameter/2, 0, i * 2])
          cylinder(d=leadscrew_clearance_diameter + 0.5, h=2, $fn=16);
      }
  }
}

// Main block with features
module housing_block_with_features() {
  difference() {
    // Main block
    cube([block_width, block_length, block_height], center=true);
    
    // Nut capture pocket
    translate([0, 0, block_height/2 - (nut_capture_depth + overlap)/2])
      cylinder(r=(nut_capture_diameter + tolerance_clearance)/2, h=nut_capture_depth + overlap, center=true, $fn=32);
    
    // Leadscrew through bore
    translate([0, 0, 0])
      cylinder(r=(leadscrew_clearance_diameter + tolerance_clearance)/2, h=block_height + 2*overlap, center=true, $fn=32);
    
    // Anti-rotation flat cut
    translate([(nut_capture_diameter + tolerance_clearance)/2 - (anti_rotation_flat_depth + overlap)/2, 0, block_height/2 - nut_capture_depth/2])
      cube([anti_rotation_flat_depth + overlap, anti_rotation_flat_width, nut_capture_depth + 2*overlap], center=true);
    
    // Mounting holes and counterbores
    if (mount_hole_count >= 2) {
      translate([0, mount_hole_spacing/2, 0])
        cylinder(r=(mount_hole_diameter + tolerance_clearance)/2, h=block_height + 2*overlap, center=true, $fn=32);
      translate([0, -mount_hole_spacing/2, 0])
        cylinder(r=(mount_hole_diameter + tolerance_clearance)/2, h=block_height + 2*overlap, center=true, $fn=32);
      
      translate([0, mount_hole_spacing/2, block_height/2 - (counterbore_depth + overlap)/2])
        cylinder(r=(counterbore_diameter + tolerance_clearance)/2, h=counterbore_depth + overlap, center=true, $fn=32);
      translate([0, -mount_hole_spacing/2, block_height/2 - (counterbore_depth + overlap)/2])
        cylinder(r=(counterbore_diameter + tolerance_clearance)/2, h=counterbore_depth + overlap, center=true, $fn=32);
    }
    
    // Lead-in chamfers
    translate([block_width/2 - (chamfer_size + overlap)/2, block_length/2 - (chamfer_size + overlap)/2, block_height/2 - (chamfer_size + overlap)/2])
      cube([chamfer_size + overlap, chamfer_size + overlap, chamfer_size + overlap], center=true);
    translate([block_width/2 - (chamfer_size + overlap)/2, -block_length/2 + (chamfer_size + overlap)/2, block_height/2 - (chamfer_size + overlap)/2])
      cube([chamfer_size + overlap, chamfer_size + overlap, chamfer_size + overlap], center=true);
    translate([-block_width/2 + (chamfer_size + overlap)/2, block_length/2 - (chamfer_size + overlap)/2, block_height/2 - (chamfer_size + overlap)/2])
      cube([chamfer_size + overlap, chamfer_size + overlap, chamfer_size + overlap], center=true);
    translate([-block_width/2 + (chamfer_size + overlap)/2, -block_length/2 + (chamfer_size + overlap)/2, block_height/2 - (chamfer_size + overlap)/2])
      cube([chamfer_size + overlap, chamfer_size + overlap, chamfer_size + overlap], center=true);
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