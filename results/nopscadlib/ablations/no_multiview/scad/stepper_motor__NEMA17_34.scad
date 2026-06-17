// Parameters
face_width_mm = 42.3; //[21.15:84.6:0.1]
front_face_thickness_mm = 3.0; //[1.5:6.0:0.1]
body_length_mm = 34.0; //[17.0:68.0:0.1]
body_width_mm = 42.3; //[21.15:84.6:0.1]
body_height_mm = 42.3; //[21.15:84.6:0.1]
rear_cap_thickness_mm = 2.5; //[1.25:5.0:0.1]
shaft_diameter_mm = 5.0; //[2.5:10.0:0.1]
shaft_length_out_mm = 20.0; //[10.0:40.0:0.1]
shaft_boss_diameter_mm = 22.0; //[11.0:44.0:0.1]
shaft_boss_height_mm = 2.0; //[1.0:4.0:0.1]
mounting_hole_spacing_mm = 31.0; //[15.5:62.0:0.1]
mounting_hole_diameter_mm = 3.5; //[1.75:7.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]
d_plug_length_mm = 18.0; //[9.0:36.0:0.1]
d_plug_width_mm = 12.0; //[6.0:24.0:0.1]
d_plug_rad_mm = 2.0; //[1.0:4.0:0.1]
grill_hole_diameter_mm = 3.0; //[1.5:6.0:0.1]
grill_hole_pitch_mm = 6.0; //[3.0:12.0:0.1]
screw_shank_diameter_mm = 3.0; //[1.5:6.0:0.1]
screw_length_mm = 12.0; //[6.0:24.0:0.1]
washer_outer_diameter_mm = 7.0; //[3.5:14.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.0:0.1]
ttrack_hole_diameter_mm = 5.0; //[2.5:10.0:0.1]
rail_hole_diameter_mm = 4.0; //[2.0:8.0:0.1]

// D Plug D
module d_plug_D() {
  color("DimGray") {
    hull() {
      translate([(face_width_mm/2 - d_plug_rad_mm - overlap_mm) + (d_plug_length_mm/2 - d_plug_rad_mm), 0, 0])
        cylinder(r=d_plug_rad_mm, h=front_face_thickness_mm, center=true);
      translate([(face_width_mm/2 - d_plug_rad_mm - overlap_mm) - (d_plug_length_mm/2 - d_plug_rad_mm), 0, 0])
        cylinder(r=d_plug_rad_mm, h=front_face_thickness_mm, center=true);
      translate([(face_width_mm/2 - d_plug_rad_mm - overlap_mm) + (d_plug_length_mm/2 - d_plug_rad_mm), (d_plug_width_mm/2 - d_plug_rad_mm), 0])
        cylinder(r=d_plug_rad_mm, h=front_face_thickness_mm, center=true);
      translate([(face_width_mm/2 - d_plug_rad_mm - overlap_mm) - (d_plug_length_mm/2 - d_plug_rad_mm), (d_plug_width_mm/2 - d_plug_rad_mm), 0])
        cylinder(r=d_plug_rad_mm, h=front_face_thickness_mm, center=true);
      translate([(face_width_mm/2 - d_plug_rad_mm - overlap_mm) + (d_plug_length_mm/2 - d_plug_rad_mm), -(d_plug_width_mm/2 - d_plug_rad_mm), 0])
        cylinder(r=d_plug_rad_mm, h=front_face_thickness_mm, center=true);
      translate([(face_width_mm/2 - d_plug_rad_mm - overlap_mm) - (d_plug_length_mm/2 - d_plug_rad_mm), -(d_plug_width_mm/2 - d_plug_rad_mm), 0])
        cylinder(r=d_plug_rad_mm, h=front_face_thickness_mm, center=true);
    }
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("Silver") {
    for (i = [-1, 1], j = [-1, 1]) {
      translate([i * grill_hole_pitch_mm, j * grill_hole_pitch_mm, -(front_face_thickness_mm/2 + body_length_mm - overlap_mm + rear_cap_thickness_mm/2)])
        cylinder(r=grill_hole_diameter_mm/2, h=rear_cap_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Screw and Washer
module screw_and_washer() {
  color("SteelBlue") {
    union() {
      translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, front_face_thickness_mm/2 + screw_length_mm/2 - overlap_mm])
        cylinder(r=screw_shank_diameter_mm/2, h=screw_length_mm, center=true);
      translate([mounting_hole_spacing_mm/2, mounting_hole_spacing_mm/2, front_face_thickness_mm/2 + washer_thickness_mm/2 - overlap_mm])
        cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
    }
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DarkSlateGray") {
    for (i = [-1, 1]) {
      translate([i * body_width_mm/4, 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
        cylinder(r=ttrack_hole_diameter_mm/2, h=body_length_mm + front_face_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DarkOliveGreen") {
    for (i = [-1, 1]) {
      rotate([90, 0, 0])
        translate([0, i * (body_height_mm/2 - overlap_mm), -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
          cylinder(r=rail_hole_diameter_mm/2, h=body_height_mm + 2*overlap_mm, center=true);
    }
  }
}

// Motor Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width_mm, face_width_mm, front_face_thickness_mm], center=true);
    // Rear Cap Face
    translate([0, 0, -(front_face_thickness_mm/2 + body_length_mm - overlap_mm + rear_cap_thickness_mm/2)])
      cube([body_width_mm, body_height_mm, rear_cap_thickness_mm], center=true);
    // Shaft Boss
    translate([0, 0, front_face_thickness_mm/2 + shaft_boss_height_mm/2 - overlap_mm])
      cylinder(r=shaft_boss_diameter_mm/2, h=shaft_boss_height_mm, center=true);
    // Shaft
    translate([0, 0, front_face_thickness_mm/2 + shaft_boss_height_mm/2 + shaft_length_out_mm/2 - overlap_mm])
      cylinder(r=shaft_diameter_mm/2, h=shaft_length_out_mm + shaft_boss_height_mm + front_face_thickness_mm, center=true);
  }
  // D Plug D
  d_plug_D();
  // Grill Hole Positions
  grill_hole_positions();
  // Screw and Washer
  screw_and_washer();
  // Ttrack Hole Positions
  ttrack_hole_positions();
  // Rail Hole Positions
  rail_hole_positions();
}

assembly();