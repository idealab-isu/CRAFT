// Parameters
face_width = 35.2; //[17.6:70.4:0.1]
body_length = 36.0; //[18.0:72.0:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
shaft_offset_from_face = 0.0; //[-2.0:5.0:0.1]
mounting_hole_spacing = 26.0; //[13.0:52.0:0.1]
mounting_hole_diameter = 3.2; //[1.6:6.4:0.1]
hole_depth_extra = 2.0; //[1.0:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
ttrack_length = 60.0; //[30.0:120.0:0.5]
ttrack_pitch = 20.0; //[10.0:40.0:0.5]
ttrack_num_insert_holes = 3; //[1:10:1]
rail_hole_spacing = 20.0; //[10.0:40.0:0.5]
grill_hole_spacing = 6.0; //[3.0:12.0:0.5]
helper_marker_diameter = 2.0; //[1.0:5.0:0.1]
helper_marker_height = 1.0; //[0.5:5.0:0.1]

// Motor Shaft - Detailed Geometry
module motor_shaft() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + shaft_length/2 - overlap + shaft_offset_from_face])
      cylinder(d=shaft_diameter, h=shaft_length, center=true, $fn=32);
  }
}

// Ttrack Hole Positions - Detailed Geometry
module ttrack_hole_positions() {
  color("DimGray") {
    for (i = [0:ttrack_num_insert_holes-1]) {
      translate([face_width/2 - helper_marker_diameter/2, 
                 ttrack_length/2 - (ttrack_pitch/2 + i*ttrack_pitch), 
                 face_thickness/2 - helper_marker_height/2])
        cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions - Detailed Geometry
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_num_insert_holes]) {
      translate([ttrack_length/2 - (i*ttrack_length/(ttrack_num_insert_holes+1)), 
                 face_width/2 - helper_marker_diameter/2, 
                 face_thickness/2 - helper_marker_height/2])
        cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions - Detailed Geometry
module rail_hole_positions() {
  color("DimGray") {
    translate([-face_width/2 + helper_marker_diameter/2, rail_hole_spacing/2, face_thickness/2 - helper_marker_height/2])
      cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
    translate([-face_width/2 + helper_marker_diameter/2, -rail_hole_spacing/2, face_thickness/2 - helper_marker_height/2])
      cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
  }
}

// Grill Hole Positions - Detailed Geometry
module grill_hole_positions() {
  color("DimGray") {
    translate([grill_hole_spacing, 0, -(face_thickness/2 + body_length - helper_marker_height/2)])
      cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
    translate([-grill_hole_spacing, 0, -(face_thickness/2 + body_length - helper_marker_height/2)])
      cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
    translate([0, grill_hole_spacing, -(face_thickness/2 + body_length - helper_marker_height/2)])
      cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
    translate([0, -grill_hole_spacing, -(face_thickness/2 + body_length - helper_marker_height/2)])
      cylinder(d=helper_marker_diameter, h=helper_marker_height, center=true, $fn=16);
  }
}

// Assembly
module assembly() {
  // Motor Body and Face
  color("Black") {
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([face_width, face_width, body_length], center=true);
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
  }
  
  // Mounting Holes
  color("Silver") {
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2, 0])
        cylinder(d=mounting_hole_diameter, h=face_thickness + hole_depth_extra, center=true, $fn=16);
    }
  }
  
  // Motor Shaft
  motor_shaft();
  
  // Ttrack Hole Positions
  ttrack_hole_positions();
  
  // Ttrack Insert Hole Positions
  ttrack_insert_hole_positions();
  
  // Rail Hole Positions
  rail_hole_positions();
  
  // Grill Hole Positions
  grill_hole_positions();
}

assembly();