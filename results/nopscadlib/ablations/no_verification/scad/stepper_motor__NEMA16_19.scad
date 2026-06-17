// Parameters
face_width = 39.5; //[20:80:0.1]
face_height = 39.5; //[20:80:0.1]
body_length = 19.2; //[10:40:0.1]
front_face_thickness = 2.0; //[1:6:0.1]
shaft_diameter = 5.0; //[2:10:0.1]
shaft_length = 15.0; //[5:40:0.1]
mounting_hole_spacing = 31.0; //[20:60:0.1]
mounting_hole_diameter = 3.2; //[2:6:0.1]
mounting_hole_depth = 6.0; //[2:20:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
grill_hole_diameter = 3.0; //[1:8:0.1]
grill_hole_depth = 1.2; //[0.5:3:0.1]
grill_margin = 6.0; //[2:12:0.1]
d_plug_length = 12.0; //[6:30:0.1]
d_plug_width = 10.0; //[5:25:0.1]
d_plug_height = 4.0; //[2:10:0.1]
d_plug_rad = 2.0; //[0.5:6:0.1]
screw_shank_diameter = 3.0; //[2:6:0.1]
screw_length = 6.0; //[3:20:0.1]
washer_diameter = 7.0; //[4:16:0.1]
washer_thickness = 1.0; //[0.5:3:0.1]
rail_hole_diameter = 4.0; //[2:10:0.1]
rail_hole_depth = 1.5; //[0.5:4:0.1]

// Grill Hole Positions
module grill_hole_positions() {
  color([0.2, 0.2, 0.22]) {
    for (x = [-1, 0, 1])
      for (y = [-1, 0, 1])
        translate([x * (face_width/2 - grill_margin), y * (face_height/2 - grill_margin), body_length/2 + front_face_thickness/2 - overlap])
          cylinder(r=grill_hole_diameter/2, h=grill_hole_depth + overlap, center=true);
  }
}

// D Plug D
module d_plug_D() {
  color([0.8, 0.6, 0.2]) {
    translate([0, -(face_height/2 - grill_margin), body_length/2 + front_face_thickness - overlap + d_plug_height/2])
      linear_extrude(height=d_plug_height, center=true)
        offset(r=d_plug_rad)
          polygon(points=[
            [-d_plug_length/2, -d_plug_width/2],
            [d_plug_length/2, -d_plug_width/2],
            [d_plug_length/2, d_plug_width/2],
            [-d_plug_length/2, d_plug_width/2]
          ]);
  }
}

// Motor Shaft
module motor_shaft() {
  color("Silver") {
    translate([0, 0, body_length/2 + front_face_thickness - overlap + shaft_length/2])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
  }
}

// Screw And Washer
module screw_and_washer() {
  color([0.4, 0.4, 0.43]) {
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2, body_length/2 + front_face_thickness - overlap + screw_length/2])
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2, body_length/2 + front_face_thickness - overlap + washer_thickness/2])
      cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
  }
}

// Rail Hole Positions
module rail_hole_positions() {
  color([0.15, 0.15, 0.17]) {
    for (x = [-1, 1])
      translate([x * face_width/4, 0, -(body_length/2 - (rail_hole_depth/2))])
        cylinder(r=rail_hole_diameter/2, h=rail_hole_depth + overlap, center=true);
  }
}

// Motor Body
module motor_body() {
  color("Black") {
    cube([face_width, face_height, body_length], center=true);
  }
}

// Front Face
module front_face() {
  color("Black") {
    translate([0, 0, body_length/2 + front_face_thickness/2 - overlap])
      cube([face_width, face_height, front_face_thickness], center=true);
  }
}

// Assembly
module assembly() {
  union() {
    motor_body();
    front_face();
    motor_shaft();
    d_plug_D();
    screw_and_washer();
    grill_hole_positions();
    rail_hole_positions();
  }
}

assembly();