// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
body_length = 47; //[23.5:94:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
front_face_thickness = 3; //[1.5:6:0.1]
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 20; //[10:40:0.1]
shaft_offset_from_face = 0; //[-2:5:0.1]
mount_hole_spacing = 31; //[15.5:62:0.1]
mount_hole_diameter = 3.2; //[2:6.4:0.1]
mount_hole_depth = 6; //[3:12:0.1]
overlap = 1; //[0.5:2:0.1]
hole_clearance = 0.2; //[0:0.6:0.05]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, front_face_thickness/2 + shaft_length/2 - overlap + shaft_offset_from_face])
      cylinder(h=shaft_length, r=(shaft_diameter + hole_clearance)/2, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("Red") {
    translate([0, ttrack_length/2 - ttrack_pitch/2, 0])
      sphere(r=0.01, center=true);
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("Green") {
    translate([ttrack_length/2 - ttrack_length/(ttrack_num_insert_holes+1), 0, 0])
      sphere(r=0.01, center=true);
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("Blue") {
    translate([0, rail_length/2 - rail_pitch/2, 0])
      sphere(r=0.01, center=true);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("Yellow") {
    translate([-grill_width/2 + grill_width/(grill_cols+1), -grill_height/2 + grill_height/(grill_rows+1), 0])
      sphere(r=0.01, center=true);
  }
}

// NEMA Motor
module NEMA_motor() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, front_face_thickness], center=true);
  }
}

// Mounting Holes
module mounting_holes() {
  color("Gray") {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing/2, y * mount_hole_spacing/2, -(front_face_thickness/2) - (mount_hole_depth/2 - overlap)])
          cylinder(h=mount_hole_depth, r=(mount_hole_diameter + hole_clearance)/2, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      NEMA_motor();
      motor_shaft();
    }
    mounting_holes();
  }
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
}

assembly();