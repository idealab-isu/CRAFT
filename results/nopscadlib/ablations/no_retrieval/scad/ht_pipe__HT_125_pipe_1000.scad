// Parameters
pipe_length = 1000; //[500:2000:1]
outer_diameter = 125; //[62.5:250:0.5]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 135; //[125:160:0.5]
socket_wall_thickness = 4; //[2:8:0.1]
chamfer_length = 2; //[1:6:0.1]
chamfer_radial = 1.5; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]

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

module chamfer_cut_spigot() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + chamfer_radial, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module chamfer_cut_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2 + chamfer_radial, r2=socket_outer_diameter/2 - chamfer_radial, center=true);
}

module markings_text() {
  // Placeholder for markings, represented as a small cube
  cube([overlap, overlap, overlap], center=true);
}

// Operations
module outer_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module all_bores() {
  union() {
    inner_bore();
    socket_inner_bore();
  }
}

module chamfer_edges() {
  union() {
    chamfer_cut_spigot();
    chamfer_cut_socket_outer();
  }
}

module pipe_hollowed() {
  difference() {
    outer_with_socket();
    all_bores();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_hollowed();
    chamfer_edges();
  }
}

// Final Model
module final_model() {
  union() {
    pipe_with_chamfers();
    markings_text();
  }
}

// Render the final model
color([0.85, 0.85, 0.8]) // Off-white color for the pipe
final_model();