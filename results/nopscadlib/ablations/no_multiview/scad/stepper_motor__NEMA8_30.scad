// Parameters
face_width_mm = 20; //[10:40:1]
body_length_mm = 30; //[15:60:1]
body_back_extension_mm = 2; //[1:6:1]
shaft_diameter_mm = 4; //[2:10:0.5]
shaft_length_mm = 10; //[5:30:1]
front_face_thickness_mm = 3; //[1.5:8:0.5]
corner_radius_mm = 1.5; //[0:5:0.5]
mounting_hole_spacing_mm = 16; //[8:32:1]
mounting_hole_diameter_mm = 3; //[1.5:6:0.5]
mounting_hole_depth_mm = 6; //[3:15:1]
eps_overlap_mm = 1; //[0.5:2:0.5]
d_plug_length_mm = 10; //[5:25:1]
d_plug_width_mm = 6; //[3:15:1]
d_plug_rad_mm = 1; //[0.5:4:0.5]
grill_width_mm = 12; //[6:30:1]
grill_height_mm = 12; //[6:30:1]
grill_hole_diameter_mm = 2; //[1:5:0.5]
grill_hole_depth_mm = 2; //[1:6:1]
screw_shank_diameter_mm = 3; //[2:6:0.5]
screw_length_mm = 8; //[4:25:1]
washer_outer_diameter_mm = 6; //[4:14:0.5]
washer_thickness_mm = 1; //[0.5:3:0.5]
ttrack_hole_diameter_mm = 2.5; //[1.5:6:0.5]
rail_hole_diameter_mm = 2.5; //[1.5:6:0.5]

// D Plug D - Custom component
module d_plug_D() {
  color("Silver") {
    linear_extrude(height=front_face_thickness_mm) {
      offset(r=d_plug_rad_mm) {
        polygon(points=[
          [-d_plug_length_mm/2, -d_plug_width_mm/2],
          [d_plug_length_mm/2, -d_plug_width_mm/2],
          [d_plug_length_mm/2, d_plug_width_mm/2],
          [-d_plug_length_mm/2, d_plug_width_mm/2]
        ]);
      }
    }
  }
}

// Grill Hole Positions - Custom component
module grill_hole_positions() {
  color("DimGray") {
    for (x = [-grill_width_mm/4, grill_width_mm/4])
      for (y = [-grill_height_mm/4, grill_height_mm/4])
        translate([x, y, front_face_thickness_mm/2 - grill_hole_depth_mm/2])
          cylinder(r=grill_hole_diameter_mm/2, h=grill_hole_depth_mm + eps_overlap_mm, center=true);
  }
}

// Screw And Washer - Custom component
module screw_and_washer() {
  color("Black") {
    translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, front_face_thickness_mm/2 + screw_length_mm/2 - eps_overlap_mm])
      cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
    translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, front_face_thickness_mm/2 + washer_thickness_mm/2 - eps_overlap_mm])
      cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
  }
}

// Ttrack Hole Positions - Custom component
module ttrack_hole_positions() {
  color("DimGray") {
    translate([face_width_mm/2 - ttrack_hole_diameter_mm/2 - eps_overlap_mm, 0, 0])
      cylinder(r=ttrack_hole_diameter_mm/2, h=front_face_thickness_mm + eps_overlap_mm, center=true);
  }
}

// Rail Hole Positions - Custom component
module rail_hole_positions() {
  color("DimGray") {
    translate([0, face_width_mm/2 - rail_hole_diameter_mm/2 - eps_overlap_mm, 0])
      cylinder(r=rail_hole_diameter_mm/2, h=front_face_thickness_mm + eps_overlap_mm, center=true);
  }
}

// Motor Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -front_face_thickness_mm/2 - body_length_mm/2 + body_back_extension_mm])
      cube([face_width_mm, face_width_mm, body_length_mm], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width_mm, face_width_mm, front_face_thickness_mm], center=true);
    // Shaft
    translate([0, 0, front_face_thickness_mm/2 + shaft_length_mm/2 - eps_overlap_mm])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_mm, center=true);
  }
  // Mounting Holes
  color("Silver") {
    for (x = [-mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2])
      for (y = [-mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2])
        translate([x, y, mounting_hole_depth_mm/2 - eps_overlap_mm])
          cylinder(r=mounting_hole_diameter_mm/2, h=mounting_hole_depth_mm + eps_overlap_mm, center=true);
  }
  // D Plug D
  translate([0, 0, -front_face_thickness_mm/2 + front_face_thickness_mm/2 - eps_overlap_mm])
    d_plug_D();
  // Grill Hole Positions
  grill_hole_positions();
  // Screw And Washer
  screw_and_washer();
  // Ttrack Hole Positions
  ttrack_hole_positions();
  // Rail Hole Positions
  rail_hole_positions();
}

assembly();