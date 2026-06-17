// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.5; //[1.75:7:0.1]
body_length = 40; //[20:80:0.5]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
shaft_diameter = 8; //[4:16:0.1]
shaft_length = 20; //[10:40:0.5]
shaft_boss_diameter = 22; //[11:44:0.1]
shaft_boss_height = 2; //[1:6:0.1]
mounting_hole_spacing = 31; //[15.5:62:0.1]
mounting_hole_diameter = 3.5; //[2:6:0.1]
mounting_hole_depth = 10; //[5:25:0.5]
mounting_hole_extra_through = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.1]
pattern_marker_diameter = 2; //[1:5:0.1]
pattern_marker_height = 1.5; //[0.5:4:0.1]
ttrack_length = 60; //[30:120:1]
ttrack_pitch = 20; //[10:40:1]
ttrack_edge_clearance = 7; //[3:15:0.5]
ttrack_insert_hole_count = 3; //[1:8:1]
rail_hole_spacing = 25; //[10:60:1]
grill_hole_spacing = 8; //[4:16:0.5]

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
    for (i = [0:ttrack_insert_hole_count-1]) {
      translate([0, ttrack_length/2 - ttrack_edge_clearance - i*ttrack_pitch, 0])
        cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    for (i = [1:ttrack_insert_hole_count]) {
      translate([ttrack_length/2 - i*(ttrack_length/(ttrack_insert_hole_count+1)), 0, 0])
        cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    translate([body_width/2 - pattern_marker_diameter/2, rail_hole_spacing/2, 0])
      cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
    translate([body_width/2 - pattern_marker_diameter/2, -rail_hole_spacing/2, 0])
      cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    for (x = [-1, 1]) {
      for (y = [-1, 1]) {
        translate([x*grill_hole_spacing/2, y*grill_hole_spacing/2, 0])
          cylinder(r=pattern_marker_diameter/2, h=pattern_marker_height, center=true, $fn=16);
      }
    }
  }
}

// Motor Body with Mounting Holes
module motor_with_mounting_holes() {
  color("Black") {
    difference() {
      union() {
        // Motor Body
        translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
          cube([body_width, body_height, body_length], center=true);
        // Front Face Plate
        translate([0, 0, 0])
          cube([face_width, face_width, face_thickness], center=true);
        // Shaft Boss
        translate([0, 0, face_thickness/2 + shaft_boss_height/2 - overlap])
          cylinder(r=shaft_boss_diameter/2, h=shaft_boss_height, center=true, $fn=32);
        // Motor Shaft
        motor_shaft();
      }
      // Mounting Holes
      for (x = [-1, 1]) {
        for (y = [-1, 1]) {
          translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2, -(mounting_hole_depth/2)])
            cylinder(r=mounting_hole_diameter/2, h=face_thickness + mounting_hole_depth + mounting_hole_extra_through, center=true, $fn=16);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  motor_with_mounting_holes();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  grill_hole_positions();
}

assembly();