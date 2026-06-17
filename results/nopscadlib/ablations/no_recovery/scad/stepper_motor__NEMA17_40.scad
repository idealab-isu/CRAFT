// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 40.0; //[20.0:80.0:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
rear_cap_thickness = 2.0; //[1.0:4.0:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
front_boss_diameter = 22.0; //[11.0:44.0:0.1]
front_boss_height = 2.0; //[1.0:4.0:0.1]
mount_hole_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_diameter = 3.5; //[1.75:7.0:0.1]
corner_radius = 2.0; //[1.0:4.0:0.1]
shaft_center_bore_diameter = 2.0; //[0.5:4.0:0.1]
shaft_center_bore_depth = 6.0; //[2.0:12.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
pattern_marker_diameter = 1.5; //[0.8:3.0:0.1]
pattern_marker_height = 0.8; //[0.4:2.0:0.1]
ttrack_length = 60.0; //[30.0:120.0:0.5]
ttrack_pitch = 20.0; //[10.0:40.0:0.5]
ttrack_insert_num_holes = 3.0; //[1.0:8.0:1.0]
rail_hole_spacing = 25.0; //[12.5:50.0:0.5]
grill_hole_spacing = 8.0; //[4.0:16.0:0.5]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true, $fn=32);
    translate([0, 0, face_thickness/2 + shaft_length - shaft_center_bore_depth/2])
      cylinder(r=shaft_center_bore_diameter/2, h=shaft_center_bore_depth + overlap*2, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DimGray") {
    for (i = [0:ttrack_insert_num_holes-1]) {
      translate([face_width/2 - pattern_marker_diameter/2, ttrack_length/2 - (i+1)*ttrack_pitch, face_thickness/2 + pattern_marker_height/2 - overlap])
        cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [-1, 0, 1]) {
      translate([face_width/2 - pattern_marker_diameter/2, i*ttrack_length/(ttrack_insert_num_holes+1), face_thickness/2 + pattern_marker_height/2 - overlap])
        cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    for (i = [-1, 1]) {
      translate([-face_width/2 + pattern_marker_diameter/2, i*rail_hole_spacing/2, face_thickness/2 + pattern_marker_height/2 - overlap])
        cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
    }
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    for (i = [-1, 1]) {
      for (j = [-1, 1]) {
        translate([i*grill_hole_spacing, j*grill_hole_spacing, -(face_thickness/2 + body_length + rear_cap_thickness/2 - overlap) + rear_cap_thickness/2 - pattern_marker_height/2 + overlap])
          cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
      }
    }
  }
}

// Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
    // Rear Cap
    translate([0, 0, -(face_thickness/2 + body_length + rear_cap_thickness/2 - overlap)])
      cube([body_width, body_height, rear_cap_thickness], center=true);
    // Front Boss Register
    translate([0, 0, face_thickness/2 + front_boss_height/2 - overlap])
      cylinder(r=front_boss_diameter/2, h=front_boss_height, center=true, $fn=32);
  }
  
  // Mounting Holes
  color("Silver") {
    for (x = [-1, 1]) {
      for (y = [-1, 1]) {
        translate([x*mount_hole_spacing/2, y*mount_hole_spacing/2, 0])
          cylinder(r=mount_hole_diameter/2, h=face_thickness + overlap*2, center=true, $fn=16);
      }
    }
  }
  
  // Include detailed components
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
}

assembly();