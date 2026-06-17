// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 47.0; //[23.5:94.0:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
mount_hole_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_diameter = 3.5; //[2.0:6.0:0.1]
mount_hole_overcut = 1.0; //[0.5:3.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
pattern_marker_diameter = 2.0; //[1.0:6.0:0.1]
pattern_marker_height = 1.0; //[0.5:5.0:0.1]
ttrack_length = 60.0; //[30.0:120.0:0.1]
ttrack_screw_pitch = 20.0; //[10.0:40.0:0.1]
ttrack_insert_hole_count = 3; //[1:10:1]
rail_hole_spacing = 25.0; //[12.5:50.0:0.1]
grill_hole_spacing = 8.0; //[4.0:16.0:0.1]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
      cylinder(h=shaft_length, r=shaft_diameter/2, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_insert_hole_count]) {
      translate([face_width/2 - pattern_marker_diameter/2, 
                 ttrack_length/2 - (i * ttrack_screw_pitch), 
                 face_thickness/2 - pattern_marker_height/2])
        cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_insert_hole_count]) {
      translate([(ttrack_length/2) - (i * ttrack_length/(ttrack_insert_hole_count+1)), 
                 -face_width/2 + pattern_marker_diameter/2, 
                 face_thickness/2 - pattern_marker_height/2])
        cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    translate([-face_width/2 + pattern_marker_diameter/2, 
               rail_hole_spacing/2, 
               face_thickness/2 - pattern_marker_height/2])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
    translate([-face_width/2 + pattern_marker_diameter/2, 
               -rail_hole_spacing/2, 
               face_thickness/2 - pattern_marker_height/2])
      cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * grill_hole_spacing/2, 
                   y * grill_hole_spacing/2, 
                   face_thickness/2 - pattern_marker_height/2])
          cylinder(h=pattern_marker_height, r=pattern_marker_diameter/2, center=true, $fn=16);
  }
}

// Motor Body
module motor_body() {
  color("Black") {
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
  }
}

// Front Face with Mount Holes
module front_face_with_mount_holes() {
  color("Black") {
    difference() {
      translate([0, 0, 0])
        cube([face_width, face_width, face_thickness], center=true);
      for (x = [-1, 1])
        for (y = [-1, 1])
          translate([x * mount_hole_spacing/2, y * mount_hole_spacing/2, 0])
            cylinder(h=face_thickness + mount_hole_overcut, r=mount_hole_diameter/2, center=true, $fn=16);
    }
  }
}

// Assembly
module assembly() {
  motor_body();
  front_face_with_mount_holes();
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
}

assembly();