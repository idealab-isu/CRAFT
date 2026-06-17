// Parameters
face_width = 39.5; //[20:80:0.1]
face_thickness = 3; //[1.5:8:0.1]
body_length = 19.2; //[10:60:0.1]
body_width = 39.5; //[20:80:0.1]
body_height = 39.5; //[20:80:0.1]
corner_radius = 2; //[0:6:0.1]
shaft_diameter = 5; //[2:12:0.1]
shaft_length = 20; //[5:60:0.1]
front_boss_diameter = 22; //[10:40:0.1]
front_boss_thickness = 2; //[0.5:8:0.1]
mounting_hole_spacing = 31; //[15:60:0.1]
mounting_hole_diameter = 3.2; //[2:6:0.1]
hole_through_extra = 2; //[0.5:6:0.1]
overlap = 1; //[0.5:2:0.1]
d_plug_length = 14; //[7:28:0.1]
d_plug_width = 10; //[5:20:0.1]
d_plug_rad = 2; //[0.5:5:0.1]
grill_width = 18; //[8:35:0.1]
grill_height = 18; //[8:35:0.1]
grill_hole_diameter = 2; //[1:5:0.1]
grill_hole_depth = 1.5; //[0.5:5:0.1]
screw_shank_diameter = 3; //[2:6:0.1]
screw_length = 10; //[4:30:0.1]
washer_outer_diameter = 7; //[4:14:0.1]
washer_thickness = 1; //[0.5:3:0.1]
ttrack_hole_diameter = 4; //[2:8:0.1]
ttrack_hole_depth = 2; //[0.5:6:0.1]
rail_hole_diameter = 4; //[2:8:0.1]
rail_hole_depth = 2; //[0.5:6:0.1]

// Modules
module d_plug_D() {
  color("Gray") {
    translate([0, 0, -face_thickness/2])
      linear_extrude(height=face_thickness)
        offset(r=d_plug_rad)
          square([d_plug_length, d_plug_width], center=true);
  }
}

module grill_hole_positions() {
  color("DarkGray") {
    translate([0, 0, face_thickness/2 - grill_hole_depth/2])
      cylinder(r=grill_hole_diameter/2, h=grill_hole_depth, center=true);
  }
}

module screw_and_washer() {
  color("Silver") {
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2, face_thickness/2 - overlap - screw_length/2])
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2, face_thickness/2 - overlap - washer_thickness/2])
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
  }
}

module ttrack_hole_positions() {
  color("DarkGray") {
    translate([face_width/2 - ttrack_hole_diameter/2 - overlap, 0, face_thickness/2 - ttrack_hole_depth/2])
      cylinder(r=ttrack_hole_diameter/2, h=ttrack_hole_depth, center=true);
  }
}

module rail_hole_positions() {
  color("DarkGray") {
    translate([0, face_width/2 - rail_hole_diameter/2 - overlap, face_thickness/2 - rail_hole_depth/2])
      cylinder(r=rail_hole_diameter/2, h=rail_hole_depth, center=true);
  }
}

module motor_body() {
  color("Black") {
    translate([0, 0, -(face_thickness/2 + body_length/2 - overlap)])
      cube([body_width, body_height, body_length], center=true);
  }
}

module front_face() {
  color("Black") {
    translate([0, 0, 0])
      cube([face_width, face_width, face_thickness], center=true);
  }
}

module front_boss() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + front_boss_thickness/2 - overlap])
      cylinder(r=front_boss_diameter/2, h=front_boss_thickness, center=true);
  }
}

module output_shaft() {
  color("Silver") {
    translate([0, 0, face_thickness/2 + front_boss_thickness - overlap + shaft_length/2])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
  }
}

module mounting_holes_pattern() {
  union() {
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2, 0])
      cylinder(r=mounting_hole_diameter/2, h=face_thickness + hole_through_extra, center=true);
    translate([-mounting_hole_spacing/2, mounting_hole_spacing/2, 0])
      cylinder(r=mounting_hole_diameter/2, h=face_thickness + hole_through_extra, center=true);
    translate([-mounting_hole_spacing/2, -mounting_hole_spacing/2, 0])
      cylinder(r=mounting_hole_diameter/2, h=face_thickness + hole_through_extra, center=true);
    translate([mounting_hole_spacing/2, -mounting_hole_spacing/2, 0])
      cylinder(r=mounting_hole_diameter/2, h=face_thickness + hole_through_extra, center=true);
  }
}

module motor_with_mounting_holes() {
  difference() {
    union() {
      motor_body();
      front_face();
      front_boss();
      output_shaft();
      screw_and_washer();
    }
    mounting_holes_pattern();
  }
}

module motor_with_all_reference_holes() {
  difference() {
    motor_with_mounting_holes();
    grill_hole_positions();
    ttrack_hole_positions();
    rail_hole_positions();
  }
}

module final_model() {
  union() {
    motor_with_all_reference_holes();
    d_plug_D();
  }
}

module assembly() {
  final_model();
}

assembly();