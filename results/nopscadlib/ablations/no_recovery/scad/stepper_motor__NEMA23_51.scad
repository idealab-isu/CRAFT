// Parameters
face_width = 56.4; //[28.2:112.8:0.1]
front_face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 51.2; //[25.6:102.4:0.1]
body_width = 56.4; //[28.2:112.8:0.1]
body_height = 56.4; //[28.2:112.8:0.1]
shaft_diameter = 6.35; //[3.0:12.7:0.01]
shaft_length = 20.0; //[10.0:40.0:0.1]
boss_diameter = 22.0; //[11.0:44.0:0.1]
boss_thickness = 2.0; //[1.0:6.0:0.1]
mounting_hole_spacing = 47.1; //[23.55:94.2:0.1]
mounting_hole_diameter = 3.5; //[2.0:6.0:0.1]
mounting_hole_depth = 6.0; //[3.0:20.0:0.1]
hole_clearance_extra = 0.2; //[0.0:0.6:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
tab_thickness = 2.0; //[1.0:6.0:0.1]
tab_width = 10.0; //[5.0:25.0:0.1]
tab_length = 18.0; //[8.0:40.0:0.1]
ttrack_length = 80.0; //[40.0:160.0:0.5]
ttrack_pitch = 25.0; //[10.0:50.0:0.5]
ttrack_hole_diameter = 5.0; //[3.0:8.0:0.1]
ttrack_num_insert_holes = 3; //[1:8:1]
rail_length = 70.0; //[35.0:140.0:0.5]
rail_pitch = 20.0; //[10.0:40.0:0.5]
rail_hole_diameter = 4.0; //[2.5:7.0:0.1]
post_4mm_hole_diameter = 4.0; //[3.0:6.0:0.1]
post_block_size = 12.0; //[6.0:24.0:0.1]

// Motor Shaft - Detailed Geometry
module motor_shaft() {
  color("Silver") {
    translate([0, 0, front_face_thickness/2 + boss_thickness - overlap + shaft_length/2])
      cylinder(d=shaft_diameter, h=shaft_length, center=true, $fn=32);
  }
}

// Ttrack Hole Positions - Detailed Geometry
module ttrack_hole_positions() {
  color("DimGray") {
    translate([body_width/2 + tab_length - overlap + ttrack_length/2 - overlap, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
      cube([ttrack_length, tab_width, tab_thickness], center=true);
  }
}

// Ttrack Insert Hole Positions - Detailed Geometry
module ttrack_insert_hole_positions() {
  color("DimGray") {
    translate([body_width/2 + tab_length - overlap + ttrack_length/2 - overlap, tab_width/2 + (tab_width*0.7)/2 - overlap, -(front_face_thickness/2 + body_length/2 - overlap)])
      cube([ttrack_length, tab_width*0.7, tab_thickness], center=true);
  }
}

// Rail Hole Positions - Detailed Geometry
module rail_hole_positions() {
  color("DimGray") {
    translate([-body_width/2 - tab_length + overlap - rail_length/2 + overlap, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
      cube([rail_length, tab_width, tab_thickness], center=true);
  }
}

// Post 4Mm Hole - Detailed Geometry
module post_4mm_hole() {
  color("DimGray") {
    translate([0, body_height/2 + tab_length - overlap + post_block_size/2 - overlap, -(front_face_thickness/2 + body_length/2 - overlap)])
      rotate([90, 0, 0])
      cylinder(d=post_4mm_hole_diameter + hole_clearance_extra, h=post_block_size + 2*overlap, center=true, $fn=32);
  }
}

// Assembly
module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
    // Front Face
    translate([0, 0, 0])
      cube([face_width, face_width, front_face_thickness], center=true);
    // Shaft Boss
    translate([0, 0, front_face_thickness/2 + boss_thickness/2 - overlap])
      cylinder(d=boss_diameter, h=boss_thickness, center=true, $fn=32);
  }
  motor_shaft();
  ttrack_hole_positions();
  ttrack_insert_hole_positions();
  rail_hole_positions();
  post_4mm_hole();
}

assembly();