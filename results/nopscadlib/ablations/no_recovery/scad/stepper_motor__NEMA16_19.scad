// Parameters
face_width = 39.5; //[20:80:0.1]
face_thickness = 3; //[1.5:8:0.1]
body_length = 19.2; //[10:60:0.1]
body_width = 39.5; //[20:80:0.1]
body_height = 39.5; //[20:80:0.1]
rear_face_thickness = 2; //[1:6:0.1]
shaft_diameter = 5; //[2:12:0.1]
shaft_length = 20; //[5:60:0.1]
shaft_boss_diameter = 22; //[10:40:0.1]
shaft_boss_length = 2; //[1:8:0.1]
mount_hole_spacing = 31; //[15:60:0.1]
mount_hole_diameter = 3.2; //[2:8:0.1]
mount_hole_depth = 6; //[2:20:0.1]
overlap = 1; //[0.5:2:0.1]
ref_marker_diameter = 1.5; //[0.5:5:0.1]
ref_marker_length = 1.2; //[0.5:5:0.1]
ttrack_length = 60; //[20:200:1]
ttrack_pitch = 20; //[5:50:0.5]
ttrack_insert_hole_count = 3; //[1:10:1]
rail_hole_count = 2; //[1:10:1]
grill_hole_count = 4; //[1:20:1]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_insert_hole_count]) {
      translate([0, ttrack_length/2 - (ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 - i*ttrack_pitch, -(face_thickness/2 + ref_marker_length/2 - overlap)])
        cylinder(r=ref_marker_diameter/2, h=ref_marker_length, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_insert_hole_count]) {
      translate([ttrack_length/2 - i*(ttrack_length/(ttrack_insert_hole_count+1)), 0, -(face_thickness/2 + ref_marker_length/2 - overlap)])
        cylinder(r=ref_marker_diameter/2, h=ref_marker_length, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    for (i = [1:rail_hole_count]) {
      translate([face_width/2 - ref_marker_diameter/2, face_width/2 - i*(face_width/(rail_hole_count+1)), -(face_thickness/2 + ref_marker_length/2 - overlap)])
        cylinder(r=ref_marker_diameter/2, h=ref_marker_length, center=true, $fn=16);
    }
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    for (i = [1:grill_hole_count]) {
      translate([-face_width/2 + i*(face_width/(grill_hole_count+1)), -face_width/2 + i*(face_width/(grill_hole_count+1)), -(face_thickness/2 + ref_marker_length/2 - overlap)])
        cylinder(r=ref_marker_diameter/2, h=ref_marker_length, center=true, $fn=16);
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
    // Rear Face
    translate([0, 0, -(face_thickness/2 + body_length - overlap + rear_face_thickness/2)])
      cube([body_width, body_height, rear_face_thickness], center=true);
    // Shaft Boss
    translate([0, 0, face_thickness/2 + shaft_boss_length/2 - overlap])
      cylinder(r=shaft_boss_diameter/2, h=shaft_boss_length, center=true, $fn=32);
  }
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
  // Mounting Holes
  color("Black") {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*mount_hole_spacing/2, y*mount_hole_spacing/2, -mount_hole_depth/2])
        cylinder(r=mount_hole_diameter/2, h=face_thickness + mount_hole_depth, center=true, $fn=16);
    }
  }
}

assembly();