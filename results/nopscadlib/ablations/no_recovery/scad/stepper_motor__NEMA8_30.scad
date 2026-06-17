// Parameters
face_width = 20.0; //[10.0:40.0:0.5]
body_length = 30.0; //[15.0:60.0:0.5]
shaft_diameter = 4.0; //[2.0:8.0:0.1]
shaft_length = 10.0; //[5.0:20.0:0.5]
mount_hole_spacing = 16.0; //[8.0:32.0:0.5]
mount_hole_diameter = 3.0; //[1.5:6.0:0.1]
face_thickness = 2.0; //[1.0:6.0:0.25]
shaft_offset_from_face = 0.0; //[-2.0:5.0:0.25]
overlap = 1.0; //[0.5:2.0:0.1]
pattern_marker_diameter = 1.0; //[0.5:2.0:0.1]
pattern_marker_height = 1.0; //[0.5:3.0:0.1]
ttrack_length = 30.0; //[15.0:60.0:0.5]
ttrack_pitch = 10.0; //[5.0:20.0:0.5]
ttrack_num_insert_holes = 2; //[1:6:1]
rail_hole_spacing = 12.0; //[6.0:24.0:0.5]
grill_hole_spacing = 6.0; //[3.0:12.0:0.5]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap + shaft_offset_from_face])
      cylinder(h=shaft_length, r=shaft_diameter/2, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DimGray") {
    translate([0, ttrack_pitch/2, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    translate([0, -ttrack_pitch/2, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_num_insert_holes]) {
      translate([i*ttrack_length/(ttrack_num_insert_holes+1) - ttrack_length/2, 0, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
        cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    translate([rail_hole_spacing/2, 0, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    translate([-rail_hole_spacing/2, 0, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    translate([grill_hole_spacing/2, grill_hole_spacing/2, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    translate([-grill_hole_spacing/2, grill_hole_spacing/2, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    translate([grill_hole_spacing/2, -grill_hole_spacing/2, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    translate([-grill_hole_spacing/2, -grill_hole_spacing/2, -(face_thickness/2 + pattern_marker_height/2 - overlap)])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([face_width, face_width, body_length], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
  }
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
  // Mounting Holes
  color("Black") {
    translate([mount_hole_spacing/2, mount_hole_spacing/2, 0])
      cylinder(h=face_thickness + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=16);
    translate([-mount_hole_spacing/2, mount_hole_spacing/2, 0])
      cylinder(h=face_thickness + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=16);
    translate([mount_hole_spacing/2, -mount_hole_spacing/2, 0])
      cylinder(h=face_thickness + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=16);
    translate([-mount_hole_spacing/2, -mount_hole_spacing/2, 0])
      cylinder(h=face_thickness + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=16);
  }
}

assembly();