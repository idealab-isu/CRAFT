// Parameters
face_width = 56.4; //[28.2:112.8:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 51.2; //[25.6:102.4:0.1]
body_width = 56.4; //[28.2:112.8:0.1]
body_height = 56.4; //[28.2:112.8:0.1]
shaft_diameter = 6.35; //[3.0:12.7:0.05]
shaft_length = 20.0; //[8.0:40.0:0.1]
shaft_boss_diameter = 22.0; //[11.0:44.0:0.1]
shaft_boss_thickness = 2.0; //[1.0:6.0:0.1]
mount_hole_spacing = 47.1; //[23.55:94.2:0.1]
mount_hole_diameter = 3.5; //[2.0:6.0:0.1]
mount_hole_depth = 8.0; //[3.0:20.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
grill_hole_diameter = 2.5; //[1.0:6.0:0.1]
grill_hole_spacing = 8.0; //[4.0:16.0:0.1]
grill_hole_depth = 1.5; //[0.5:4.0:0.1]
d_plug_flat_depth = 0.8; //[0.2:2.0:0.05]
d_plug_flat_width_factor = 0.65; //[0.4:0.9:0.01]
screw_shank_diameter = 3.0; //[2.0:5.0:0.1]
screw_length = 10.0; //[5.0:25.0:0.1]
washer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 1.0; //[0.5:2.5:0.1]

// NEMA motor - complete geometry
module NEMA() {
  color("Black") {
    // Body
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
    // Shaft Boss
    translate([0, 0, face_thickness/2 + shaft_boss_thickness/2 - overlap])
      cylinder(r=shaft_boss_diameter/2, h=shaft_boss_thickness, center=true, $fn=32);
    // Shaft
    color("Silver")
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
      difference() {
        cylinder(r=shaft_diameter/2, h=shaft_length, center=true, $fn=32);
        translate([shaft_diameter/2 - d_plug_flat_depth, 0, 0])
          cube([shaft_diameter, shaft_diameter*d_plug_flat_width_factor, shaft_length + 2*overlap], center=true);
      }
  }
}

// Post 4mm Hole
module post_4mm_hole() {
  color("DimGray")
  translate([0, 0, 0])
    cylinder(r=2, h=face_thickness + 2*overlap, center=true, $fn=32);
}

// Screw and Washer
module screw_and_washer() {
  color("Silver")
  translate([mount_hole_spacing/2, mount_hole_spacing/2, face_thickness/2 + screw_length/2 - overlap])
    union() {
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true, $fn=32);
      translate([0, 0, -screw_length/2 + washer_thickness/2])
        cylinder(r=washer_diameter/2, h=washer_thickness, center=true, $fn=32);
    }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("Black")
  union() {
    translate([grill_hole_spacing, 0, face_thickness/2 - grill_hole_depth/2])
      cylinder(r=grill_hole_diameter/2, h=grill_hole_depth + 2*overlap, center=true, $fn=32);
    translate([-grill_hole_spacing, 0, face_thickness/2 - grill_hole_depth/2])
      cylinder(r=grill_hole_diameter/2, h=grill_hole_depth + 2*overlap, center=true, $fn=32);
    translate([0, grill_hole_spacing, face_thickness/2 - grill_hole_depth/2])
      cylinder(r=grill_hole_diameter/2, h=grill_hole_depth + 2*overlap, center=true, $fn=32);
    translate([0, -grill_hole_spacing, face_thickness/2 - grill_hole_depth/2])
      cylinder(r=grill_hole_diameter/2, h=grill_hole_depth + 2*overlap, center=true, $fn=32);
  }
}

// D Plug D
module d_plug_D() {
  // Placeholder for D Plug D geometry
  // Add detailed geometry as needed
}

// Assembly
module assembly() {
  difference() {
    NEMA();
    union() {
      grill_hole_positions();
      post_4mm_hole();
      translate([mount_hole_spacing/2, mount_hole_spacing/2, -mount_hole_depth/2])
        cylinder(r=mount_hole_diameter/2, h=face_thickness + mount_hole_depth + 2*overlap, center=true, $fn=32);
      translate([-mount_hole_spacing/2, mount_hole_spacing/2, -mount_hole_depth/2])
        cylinder(r=mount_hole_diameter/2, h=face_thickness + mount_hole_depth + 2*overlap, center=true, $fn=32);
      translate([-mount_hole_spacing/2, -mount_hole_spacing/2, -mount_hole_depth/2])
        cylinder(r=mount_hole_diameter/2, h=face_thickness + mount_hole_depth + 2*overlap, center=true, $fn=32);
      translate([mount_hole_spacing/2, -mount_hole_spacing/2, -mount_hole_depth/2])
        cylinder(r=mount_hole_diameter/2, h=face_thickness + mount_hole_depth + 2*overlap, center=true, $fn=32);
    }
  }
  screw_and_washer();
}

assembly();