// Parameters
face_width_mm = 42.3; //[21.15:84.6:0.1]
body_length_mm = 40; //[20:80:0.5]
body_depth_mm = 42.3; //[21.15:84.6:0.1]
body_height_mm = 42.3; //[21.15:84.6:0.1]
front_face_thickness_mm = 3; //[1.5:6:0.1]
shaft_diameter_mm = 8; //[4:16:0.1]
shaft_length_mm = 20; //[10:40:0.5]
mounting_hole_spacing_mm = 31; //[15.5:62:0.1]
mounting_hole_diameter_mm = 3.5; //[2:6:0.1]
mounting_hole_depth_mm = 6; //[3:15:0.5]
corner_radius_mm = 2; //[0:6:0.1]
boss_diameter_mm = 22; //[11:44:0.1]
boss_height_mm = 2; //[0:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]
hole_clearance_extra_mm = 0.2; //[0:0.6:0.05]
d_plug_length_mm = 18; //[9:36:0.5]
d_plug_width_mm = 12; //[6:24:0.5]
d_plug_rad_mm = 2; //[0.5:6:0.1]
grill_hole_diameter_mm = 3; //[1:8:0.1]
grill_gap_mm = 2; //[0.5:6:0.1]
pattern_stub_size_mm = 0.5; //[0.2:2:0.1]
screw_shank_diameter_mm = 3; //[2:6:0.1]
screw_length_mm = 10; //[5:30:0.5]
washer_outer_diameter_mm = 7; //[4:16:0.1]
washer_thickness_mm = 1; //[0.5:3:0.1]

// NEMA-style stepper motor
module NEMA_motor() {
  color("Black") {
    // Motor body
    translate([front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm, 0, 0])
      cube([body_length_mm, body_depth_mm, body_height_mm], center=true);
    // Front face plate
    translate([0, 0, 0])
      cube([front_face_thickness_mm, face_width_mm, face_width_mm], center=true);
    // Shaft
    color("Silver")
    translate([-front_face_thickness_mm/2 - shaft_length_mm/2 + overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
    // Optional boss
    translate([-front_face_thickness_mm/2 - boss_height_mm/2 + overlap_mm, 0, 0])
      rotate([0, 90, 0])
      cylinder(r=boss_diameter_mm/2, h=boss_height_mm, center=true);
  }
}

// D Plug D
module d_plug_D() {
  color("DimGray") {
    translate([-front_face_thickness_mm/2 + pattern_stub_size_mm/2 - overlap_mm, 0, 0])
      rotate([0, 90, 0])
      linear_extrude(height=pattern_stub_size_mm, center=true)
      offset(r=d_plug_rad_mm)
      polygon(points=[
        [-d_plug_length_mm/2 + d_plug_rad_mm, -d_plug_width_mm/2],
        [d_plug_length_mm/2 - d_plug_rad_mm, -d_plug_width_mm/2],
        [d_plug_length_mm/2, -d_plug_width_mm/2 + d_plug_rad_mm],
        [d_plug_length_mm/2, d_plug_width_mm/2 - d_plug_rad_mm],
        [d_plug_length_mm/2 - d_plug_rad_mm, d_plug_width_mm/2],
        [-d_plug_length_mm/2 + d_plug_rad_mm, d_plug_width_mm/2],
        [-d_plug_length_mm/2, d_plug_width_mm/2 - d_plug_rad_mm],
        [-d_plug_length_mm/2, -d_plug_width_mm/2 + d_plug_rad_mm]
      ]);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("Silver") {
    translate([front_face_thickness_mm/2 + pattern_stub_size_mm/2 - overlap_mm, 0, 0])
      sphere(r=pattern_stub_size_mm);
  }
}

// Screw and Washer
module screw_and_washer() {
  color("Silver") {
    // Screw shank
    translate([-front_face_thickness_mm/2 - screw_length_mm/2 + overlap_mm, mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2])
      rotate([0, 90, 0])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    // Washer
    translate([-front_face_thickness_mm/2 - washer_thickness_mm/2 + overlap_mm, mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2])
      rotate([0, 90, 0])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("Silver") {
    translate([front_face_thickness_mm/2 + pattern_stub_size_mm/2 - overlap_mm, pattern_stub_size_mm, 0])
      sphere(r=pattern_stub_size_mm);
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("Silver") {
    translate([front_face_thickness_mm/2 + pattern_stub_size_mm/2 - overlap_mm, -pattern_stub_size_mm, 0])
      sphere(r=pattern_stub_size_mm);
  }
}

// Assembly
module assembly() {
  NEMA_motor();
  d_plug_D();
  grill_hole_positions();
  screw_and_washer();
  ttrack_hole_positions();
  rail_hole_positions();
}

assembly();