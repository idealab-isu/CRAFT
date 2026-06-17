// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
body_length = 26.5; //[13.25:53:0.1]
body_depth = 42.3; //[21.15:84.6:0.1]
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 20; //[10:40:0.5]
mounting_hole_spacing = 31; //[15.5:62:0.1]
mounting_hole_diameter = 3.2; //[2:6:0.1]
corner_radius = 2; //[0:6:0.1]
face_plate_thickness = 3; //[1.5:6:0.1]
shaft_offset_from_face = 0; //[-2:5:0.1]
shaft_boss_diameter = 22; //[11:44:0.1]
shaft_boss_length = 2; //[1:6:0.1]
rear_cap_thickness = 2; //[1:6:0.1]
overlap = 1; //[0.5:2:0.1]
ttrack_length = 60; //[30:120:1]
ttrack_pitch = 20; //[10:40:1]
ttrack_num_insert_holes = 3; //[1:10:1]
aux_hole_diameter = 3; //[1.5:6:0.1]
aux_hole_depth = 2.5; //[1:6:0.1]

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, face_plate_thickness/2 + shaft_offset_from_face + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true, $fn=32);
  }
}

// Ttrack Hole Positions
module ttrack_hole_positions() {
  color("DimGray") {
    union() {
      translate([0, ttrack_pitch, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([0, 0, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([0, -ttrack_pitch, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
    }
  }
}

// Ttrack Insert Hole Positions
module ttrack_insert_hole_positions() {
  color("DimGray") {
    union() {
      for (i = [1:ttrack_num_insert_holes]) {
        translate([-ttrack_length/2 + i*ttrack_length/(ttrack_num_insert_holes+1), 0, face_plate_thickness/2 - aux_hole_depth/2])
          cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      }
    }
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color("DimGray") {
    union() {
      translate([ttrack_pitch, 0, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([0, 0, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([-ttrack_pitch, 0, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
    }
  }
}

// Grill Hole Positions
module grill_hole_positions() {
  color("DimGray") {
    union() {
      translate([ttrack_pitch/2, ttrack_pitch/2, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([-ttrack_pitch/2, ttrack_pitch/2, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([ttrack_pitch/2, -ttrack_pitch/2, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
      translate([-ttrack_pitch/2, -ttrack_pitch/2, face_plate_thickness/2 - aux_hole_depth/2])
        cylinder(r=aux_hole_diameter/2, h=aux_hole_depth + 2*overlap, center=true, $fn=16);
    }
  }
}

// Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(face_plate_thickness/2 + body_length/2 - overlap)])
      cube([face_width, body_depth, body_length], center=true);
    // Front Face Plate
    translate([0, 0, 0])
      cube([face_width, face_width, face_plate_thickness], center=true);
    // Shaft Boss
    translate([0, 0, face_plate_thickness/2 + shaft_boss_length/2 - overlap])
      cylinder(r=shaft_boss_diameter/2, h=shaft_boss_length, center=true, $fn=32);
    // Rear Cap
    translate([0, 0, -(face_plate_thickness/2 + body_length - overlap + rear_cap_thickness/2)])
      cube([face_width, body_depth, rear_cap_thickness], center=true);
  }
  // Motor Shaft
  motor_shaft();
  // Mounting Holes
  difference() {
    union() {
      translate([mounting_hole_spacing/2, mounting_hole_spacing/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=face_plate_thickness + 2*overlap, center=true, $fn=16);
      translate([-mounting_hole_spacing/2, mounting_hole_spacing/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=face_plate_thickness + 2*overlap, center=true, $fn=16);
      translate([mounting_hole_spacing/2, -mounting_hole_spacing/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=face_plate_thickness + 2*overlap, center=true, $fn=16);
      translate([-mounting_hole_spacing/2, -mounting_hole_spacing/2, 0])
        cylinder(r=mounting_hole_diameter/2, h=face_plate_thickness + 2*overlap, center=true, $fn=16);
    }
    // Ttrack Hole Positions
    ttrack_hole_positions();
    // Ttrack Insert Hole Positions
    ttrack_insert_hole_positions();
    // Rail Hole Positions
    rail_hole_positions();
    // Grill Hole Positions
    grill_hole_positions();
  }
}

assembly();