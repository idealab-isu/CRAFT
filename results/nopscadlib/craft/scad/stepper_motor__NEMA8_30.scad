// Parameters
face_width = 20.0; //[10.0:40.0:0.5]
body_length = 30.0; //[15.0:60.0:0.5]
body_width = 20.0; //[10.0:40.0:0.5]
body_height = 20.0; //[10.0:40.0:0.5]
front_face_thickness = 2.0; //[1.0:6.0:0.25]
shaft_diameter = 4.0; //[2.0:10.0:0.25]
shaft_length = 10.0; //[5.0:25.0:0.5]
mounting_hole_spacing = 16.0; //[8.0:32.0:0.5]
mounting_hole_diameter = 3.0; //[2.0:6.0:0.25]
overlap = 1.0; //[0.5:2.0:0.1]
hole_clearance = 0.2; //[0.0:0.6:0.05]
mount_hole_depth_extra = 2.0; //[1.0:6.0:0.5]
screw_length = 12.0; //[6.0:30.0:0.5]
screw_head_diameter = 5.5; //[3.0:12.0:0.25]
washer_diameter = 7.0; //[4.0:16.0:0.25]
washer_thickness = 1.0; //[0.5:3.0:0.1]
pattern_post_diameter = 2.0; //[1.0:6.0:0.25]
pattern_post_height = 3.0; //[1.0:10.0:0.5]
ttrack_length = 40.0; //[20.0:120.0:1.0]
ttrack_pitch = 20.0; //[10.0:40.0:1.0]
rail_length = 50.0; //[20.0:150.0:1.0]
rail_pitch = 25.0; //[10.0:50.0:1.0]
rail_hole_count = 3.0; //[2.0:8.0:1.0]
insert_length = 30.0; //[15.0:80.0:1.0]
insert_pitch = 15.0; //[8.0:30.0:1.0]
d_plug_diameter = 10.0; //[6.0:20.0:0.5]
d_plug_length = 8.0; //[4.0:20.0:0.5]
d_flat_depth = 2.0; //[0.5:5.0:0.25]

// Modules
module motor_body() {
  color("Black") {
    translate([0, 0, -(front_face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
  }
}

module front_face_with_mounting_holes() {
  color("DimGray") {
    difference() {
      translate([0, 0, 0])
        cube([face_width, face_width, front_face_thickness], center=true);
      union() {
        for (x = [-1, 1])
          for (y = [-1, 1])
            translate([x * mounting_hole_spacing/2, y * mounting_hole_spacing/2, 0])
              cylinder(r=(mounting_hole_diameter + hole_clearance)/2, h=front_face_thickness + mount_hole_depth_extra, center=true);
      }
    }
  }
}

module output_shaft() {
  color("Silver") {
    translate([0, 0, front_face_thickness/2 + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
  }
}

module screw_and_washer() {
  color("Silver") {
    union() {
      translate([mounting_hole_spacing/2, mounting_hole_spacing/2, front_face_thickness/2 + screw_length/2 - overlap])
        cylinder(r=mounting_hole_diameter/2, h=screw_length, center=true);
      translate([mounting_hole_spacing/2, mounting_hole_spacing/2, front_face_thickness/2 + washer_thickness - overlap])
        cylinder(r=screw_head_diameter/2, h=washer_thickness*2, center=true);
      translate([mounting_hole_spacing/2, mounting_hole_spacing/2, front_face_thickness/2 + washer_thickness/2 - overlap])
        cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
    }
  }
}

module ttrack_hole_positions() {
  color("Blue") {
    union() {
      for (i = [0:2])
        translate([0, ttrack_length/2 - ((ttrack_length - (floor(ttrack_length/ttrack_pitch) - 1) * ttrack_pitch)/2 + i*ttrack_pitch), -front_face_thickness/2 - pattern_post_height/2 + overlap])
          cylinder(r=pattern_post_diameter/2, h=pattern_post_height, center=true);
    }
  }
}

module rail_hole_positions() {
  color("Green") {
    union() {
      for (i = [0:rail_hole_count-1])
        translate([-rail_length/2 + (rail_length - (rail_hole_count - 1) * rail_pitch)/2 + i*rail_pitch, 0, -front_face_thickness/2 - pattern_post_height/2 + overlap])
          cylinder(r=pattern_post_diameter/2, h=pattern_post_height, center=true);
    }
  }
}

module ttrack_insert_hole_positions() {
  color("Red") {
    union() {
      for (i = [0:2])
        translate([face_width/2 - pattern_post_diameter/2, -insert_length/2 + (insert_length - (floor(insert_length/insert_pitch) - 1) * insert_pitch)/2 + i*insert_pitch, -front_face_thickness/2 - pattern_post_height/2 + overlap])
          cylinder(r=pattern_post_diameter/2, h=pattern_post_height, center=true);
    }
  }
}

module d_plug_D() {
  color("Yellow") {
    difference() {
      translate([-face_width/2 - d_plug_length/2 + overlap, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=d_plug_diameter/2, h=d_plug_length, center=true);
      translate([-face_width/2 - d_plug_length/2 + overlap, d_plug_diameter/2 - d_flat_depth, 0])
        rotate([0, 90, 0])
        cube([d_plug_length + 2*overlap, d_plug_diameter, d_plug_diameter], center=true);
    }
  }
}

module assembly() {
  motor_body();
  front_face_with_mounting_holes();
  output_shaft();
  ttrack_hole_positions();
  rail_hole_positions();
  ttrack_insert_hole_positions();
  d_plug_D();
  screw_and_washer();
}

assembly();