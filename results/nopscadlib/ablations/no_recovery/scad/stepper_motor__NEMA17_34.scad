// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
body_length = 34.0; //[17.0:68.0:0.5]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
front_face_thickness = 3.0; //[1.5:6.0:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.5]
shaft_offset_from_face = 0.0; //[-2.0:5.0:0.1]
mount_hole_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
front_register_diameter = 22.0; //[11.0:44.0:0.1]
front_register_height = 2.0; //[1.0:5.0:0.1]
hole_depth = 20.0; //[10.0:60.0:1.0]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, front_face_thickness/2 + shaft_length/2 - 1 + shaft_offset_from_face])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  // Placeholder for detailed geometry
  color("Red") {
    translate([0, 0, 0])
      sphere(r=0.001, center=true);
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  // Placeholder for detailed geometry
  color("Green") {
    translate([0, 0, 0])
      sphere(r=0.001, center=true);
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  // Placeholder for detailed geometry
  color("Blue") {
    translate([0, 0, 0])
      sphere(r=0.001, center=true);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  // Placeholder for detailed geometry
  color("Yellow") {
    translate([0, 0, 0])
      sphere(r=0.001, center=true);
  }
}

// NEMA Motor Assembly
module NEMA_motor() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(front_face_thickness/2 + body_length/2 - 1)])
      cube([body_width, body_height, body_length], center=true);
    
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, front_face_thickness], center=true);
    
    // Front Register
    translate([0, 0, front_face_thickness/2 + front_register_height/2 - 1])
      cylinder(r=front_register_diameter/2, h=front_register_height, center=true, $fn=32);
  }
  
  // Mounting Holes
  color("DimGray") {
    translate([mount_hole_spacing/2, mount_hole_spacing/2, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_depth, center=true, $fn=16);
    translate([-mount_hole_spacing/2, mount_hole_spacing/2, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_depth, center=true, $fn=16);
    translate([-mount_hole_spacing/2, -mount_hole_spacing/2, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_depth, center=true, $fn=16);
    translate([mount_hole_spacing/2, -mount_hole_spacing/2, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_depth, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  NEMA_motor();
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
}

assembly();