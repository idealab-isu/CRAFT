// Parameters
pipe_length = 500; //[250:1000:1]
outer_diameter = 50; //[25:100:1]
wall_thickness = 1.8; //[0.9:3.6:0.1]
socket_length = 60; //[30:120:1]
socket_outer_diameter = 56; //[50:80:1]
socket_wall_thickness = 2.2; //[1.1:4.4:0.1]
chamfer_length = 2; //[1:6:0.5]
chamfer_radial = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module pipe_body() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2 + overlap])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2, r2=socket_outer_diameter/2 - chamfer_radial, center=true);
}

module chamfer_plain_outer() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
    rotate([180, 0, 0])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module markings() {
  cylinder(h=overlap, r=outer_diameter/2, center=true);
}

// Operations
module outer_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module outer_with_socket_and_chamfers() {
  union() {
    outer_with_socket();
    chamfer_socket_outer();
    chamfer_plain_outer();
  }
}

module pipe_hollowed() {
  difference() {
    outer_with_socket_and_chamfers();
    inner_bore();
    socket_inner_bore();
  }
}

module final_model() {
  union() {
    pipe_hollowed();
    markings();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white for PVC pipe
final_model();