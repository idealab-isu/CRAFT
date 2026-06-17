// Parameters
face_width_mm = 20; //[10:40:0.5]
front_face_thickness_mm = 2; //[1:6:0.5]
body_length_mm = 30; //[15:60:0.5]
body_width_mm = 20; //[10:40:0.5]
body_height_mm = 20; //[10:40:0.5]
shaft_diameter_mm = 5; //[2.5:10:0.1]
shaft_length_mm = 12; //[6:24:0.5]
mounting_hole_spacing_mm = 16; //[8:32:0.5]
mounting_hole_diameter_mm = 3; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]
ttrack_length_mm = 30; //[15:60:0.5]
ttrack_pitch_mm = 10; //[5:20:0.5]
ttrack_num_insert_holes = 3; //[1:10:1]
pattern_marker_diameter_mm = 1; //[0.5:2:0.1]
pattern_marker_height_mm = 0.6; //[0.3:2:0.1]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, front_face_thickness_mm/2 + shaft_length_mm/2 - overlap_mm])
      cylinder(d=shaft_diameter_mm, h=shaft_length_mm, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_num_insert_holes]) {
      translate([0, i * ttrack_pitch_mm, -(front_face_thickness_mm/2 + pattern_marker_height_mm/2 - overlap_mm)])
        cylinder(d=pattern_marker_diameter_mm, h=pattern_marker_height_mm, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_num_insert_holes]) {
      translate([ttrack_length_mm/2 - i * (ttrack_length_mm/(ttrack_num_insert_holes+1)), 0, -(front_face_thickness_mm/2 + pattern_marker_height_mm/2 - overlap_mm)])
        cylinder(d=pattern_marker_diameter_mm, h=pattern_marker_height_mm, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    translate([face_width_mm/2 - pattern_marker_diameter_mm/2, 0, -(front_face_thickness_mm/2 + pattern_marker_height_mm/2 - overlap_mm)])
      cylinder(d=pattern_marker_diameter_mm, h=pattern_marker_height_mm, center=true, $fn=16);
    translate([-(face_width_mm/2 - pattern_marker_diameter_mm/2), 0, -(front_face_thickness_mm/2 + pattern_marker_height_mm/2 - overlap_mm)])
      cylinder(d=pattern_marker_diameter_mm, h=pattern_marker_height_mm, center=true, $fn=16);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    translate([0, face_width_mm/4, -(front_face_thickness_mm/2 + pattern_marker_height_mm/2 - overlap_mm)])
      cylinder(d=pattern_marker_diameter_mm, h=pattern_marker_height_mm, center=true, $fn=16);
    translate([0, -face_width_mm/4, -(front_face_thickness_mm/2 + pattern_marker_height_mm/2 - overlap_mm)])
      cylinder(d=pattern_marker_diameter_mm, h=pattern_marker_height_mm, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(front_face_thickness_mm/2 + body_length_mm/2 - overlap_mm)])
      cube([body_width_mm, body_height_mm, body_length_mm], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width_mm, face_width_mm, front_face_thickness_mm], center=true);
  }
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
  
  // Mounting Holes
  color("Silver") {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mounting_hole_spacing_mm/2, y * mounting_hole_spacing_mm/2, 0])
        cylinder(d=mounting_hole_diameter_mm, h=front_face_thickness_mm + 2*overlap_mm, center=true, $fn=16);
    }
  }
}

assembly();