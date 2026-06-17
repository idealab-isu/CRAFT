// Parameters
pipe_length = 1000; //[500:2000:1]
outer_diameter = 75; //[40:150:1]
wall_thickness = 2.5; //[1.2:5:0.1]
socket_length = 60; //[30:120:1]
socket_outer_diameter = 82; //[75:110:1]
chamfer_length = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.1]

// Geometry
module pipe_body() {
  cylinder(h = pipe_length, r = outer_diameter / 2, center = true);
}

module inner_bore() {
  cylinder(h = pipe_length + 2 * overlap, r = outer_diameter / 2 - wall_thickness, center = true);
}

module socket_end() {
  translate([0, 0, pipe_length / 2 - socket_length / 2 + overlap])
    cylinder(h = socket_length, r = socket_outer_diameter / 2, center = true);
}

module chamfer_edges() {
  translate([0, 0, pipe_length / 2 - chamfer_length / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2, r2 = 0, center = true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center = true);
}

// Operations
module outer_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module pipe_hollow() {
  difference() {
    outer_with_socket();
    inner_bore();
  }
}

module pipe_with_chamfer_cut() {
  difference() {
    pipe_hollow();
    chamfer_edges();
  }
}

module final_model() {
  union() {
    pipe_with_chamfer_cut();
    markings_text();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white color for 3D printed PLA
final_model();