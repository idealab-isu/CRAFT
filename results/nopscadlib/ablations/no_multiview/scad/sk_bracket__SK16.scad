// Parameters
rod_diameter = 16; //[8:32:0.1]
overall_height = 27; //[14:54:0.1]
base_width = 40; //[20:80:0.5]
base_length = 60; //[30:120:0.5]
base_thickness = 10; //[5:20:0.1]
seat_depth = 9; //[5:16:0.1]
seat_clearance = 0.2; //[0:1:0.05]
mount_hole_diameter = 6.5; //[3:12:0.1]
mount_hole_spacing = 40; //[20:90:0.5]
clamp_bolt_diameter = 5.5; //[3:10:0.1]
clamp_bolt_spacing = 24; //[12:50:0.5]
split_gap = 2; //[0.5:6:0.1]
edge_chamfer = 1; //[0:3:0.1]
overlap = 1; //[0.5:2:0.1]
rod_length = 70; //[30:140:1]

// Rod - complete geometry
module rod() {
  color("Silver") {
    cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
  }
}

// Bracket - complete geometry
module bracket() {
  color("Silver") {
    // Base block with chamfer
    minkowski() {
      translate([0, 0, overall_height/2])
        cube([base_width, base_length, overall_height], center=true);
      sphere(r=edge_chamfer, $fn=32);
    }
    
    // Cutouts
    difference() {
      // Rod seat
      translate([0, 0, overall_height - seat_depth + (rod_diameter + 2*seat_clearance)/2])
        rotate([90, 0, 0])
        cylinder(r=(rod_diameter + 2*seat_clearance)/2, h=base_length + 2*overlap, center=true, $fn=64);
      
      // Mounting holes
      translate([0, mount_hole_spacing/2, overall_height/2])
        cylinder(r=mount_hole_diameter/2, h=overall_height + 2*overlap, center=true, $fn=32);
      translate([0, -mount_hole_spacing/2, overall_height/2])
        cylinder(r=mount_hole_diameter/2, h=overall_height + 2*overlap, center=true, $fn=32);
      
      // Split gap
      translate([0, 0, overall_height/2])
        cube([base_width + 2*overlap, split_gap, overall_height + 2*overlap], center=true);
      
      // Clamp bolt holes
      translate([0, clamp_bolt_spacing/2, overall_height - seat_depth/2])
        rotate([0, 90, 0])
        cylinder(r=clamp_bolt_diameter/2, h=base_width + 2*overlap, center=true, $fn=32);
      translate([0, -clamp_bolt_spacing/2, overall_height - seat_depth/2])
        rotate([0, 90, 0])
        cylinder(r=clamp_bolt_diameter/2, h=base_width + 2*overlap, center=true, $fn=32);
    }
  }
}

// Assembly
module assembly() {
  union() {
    bracket();
    translate([0, 0, overall_height - seat_depth + rod_diameter/2])
      rotate([90, 0, 0])
      rod();
  }
}

assembly();