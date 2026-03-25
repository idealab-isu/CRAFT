// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 40.0; //[20.0:80.0:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
shaft_boss_diameter = 22.0; //[11.0:44.0:0.1]
shaft_boss_height = 2.0; //[1.0:5.0:0.1]
mount_hole_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
hole_through_extra = 2.0; //[1.0:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
screw_shank_diameter = 3.0; //[2.0:6.0:0.1]
screw_length = 8.0; //[4.0:20.0:0.1]
washer_outer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 1.0; //[0.5:3.0:0.1]

// NEMA motor - complete geometry
module NEMA() {
  color("Black") {
    // Body
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_width, body_length], center=true);
    // Front face
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
    // Shaft boss
    translate([0, 0, face_thickness/2 + shaft_boss_height/2 - overlap])
      cylinder(d=shaft_boss_diameter, h=shaft_boss_height, center=true, $fn=32);
    // Shaft
    color("Silver")
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
      cylinder(d=shaft_diameter, h=shaft_length, center=true, $fn=16);
    // Mounting holes
    color("DimGray")
    for (x = [-1, 1], y = [-1, 1])
      translate([x * mount_hole_spacing/2, y * mount_hole_spacing/2, 0])
        cylinder(d=mount_hole_diameter, h=face_thickness + hole_through_extra, center=true, $fn=16);
  }
}

// Motor shaft - detailed geometry
module motor_shaft() {
  color("Silver")
  translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
    cylinder(d=shaft_diameter, h=shaft_length, center=true, $fn=16);
}

// Screw and washer - detailed geometry
module screw_and_washer() {
  color("DimGray")
  for (x = [-1, 1], y = [-1, 1]) {
    // Screw shank
    translate([x * mount_hole_spacing/2, y * mount_hole_spacing/2, face_thickness/2 + screw_length/2 - overlap])
      cylinder(d=screw_shank_diameter, h=screw_length, center=true, $fn=16);
    // Washer
    translate([x * mount_hole_spacing/2, y * mount_hole_spacing/2, face_thickness/2 + washer_thickness/2 - overlap])
      cylinder(d=washer_outer_diameter, h=washer_thickness, center=true, $fn=16);
  }
}

// Grill hole positions - placeholder geometry
module grill_hole_positions() {
  // Placeholder for grill hole positions
  color("Gray")
  translate([0, 0, 0])
    cube([20, 20, face_thickness], center=true);
}

// D Plug D - placeholder geometry
module d_plug_D() {
  // Placeholder for D Plug D
  color("Gray")
  translate([0, 0, 0])
    cube([10, 10, face_thickness], center=true);
}

// Ttrack hole positions - placeholder geometry
module ttrack_hole_positions() {
  // Placeholder for Ttrack hole positions
  color("Gray")
  translate([0, 0, 0])
    cube([face_width, face_width, face_thickness], center=true);
}

// Assembly
module assembly() {
  NEMA();
  motor_shaft();
  screw_and_washer();
  grill_hole_positions();
  d_plug_D();
  ttrack_hole_positions();
}

assembly();