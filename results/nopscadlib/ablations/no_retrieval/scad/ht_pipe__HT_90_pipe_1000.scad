// Parameters
pipe_length = 1000; //[500:2000:1]
outer_diameter = 90; //[45:180:1]
wall_thickness = 3; //[1.5:6:0.1]
socket_enabled = 1; //[0:1:1]
socket_length = 70; //[35:140:1]
socket_radial_expansion = 4; //[0:10:0.5]
socket_wall_extra = 1; //[0:3:0.1]
chamfer_length = 2; //[0.5:6:0.5]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  cylinder(h = pipe_length, r = outer_diameter / 2, center = true);
}

module hollow_bore() {
  cylinder(h = pipe_length + 2 * overlap, r = outer_diameter / 2 - wall_thickness, center = true);
}

module socket_end() {
  cylinder(h = socket_length * socket_enabled, r = outer_diameter / 2 + socket_radial_expansion * socket_enabled, center = true);
}

module socket_bore() {
  cylinder(h = socket_length * socket_enabled + 2 * overlap, r = outer_diameter / 2 - wall_thickness - socket_wall_extra * socket_enabled, center = true);
}

module chamfer_cone_pos() {
  rotate([180, 0, 0])
    translate([0, 0, pipe_length / 2 - chamfer_length / 2])
      cylinder(h = chamfer_length, r1 = outer_diameter / 2 + socket_radial_expansion * socket_enabled + overlap, r2 = 0, center = true);
}

module chamfer_cone_neg() {
  translate([0, 0, -pipe_length / 2 + chamfer_length / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2 + overlap, r2 = 0, center = true);
}

module marking_text() {
  cube([overlap, overlap, overlap], center = true);
}

// Operations
module pipe_outer_with_socket() {
  union() {
    pipe_body();
    translate([0, 0, pipe_length / 2 - (socket_length * socket_enabled) / 2]) socket_end();
  }
}

module pipe_wall() {
  difference() {
    pipe_outer_with_socket();
    hollow_bore();
    translate([0, 0, pipe_length / 2 - (socket_length * socket_enabled) / 2]) socket_bore();
  }
}

module end_chamfers() {
  difference() {
    pipe_wall();
    chamfer_cone_pos();
    chamfer_cone_neg();
  }
}

module final_model() {
  union() {
    end_chamfers();
    marking_text();
  }
}

// Final Output
color("DimGray") final_model();