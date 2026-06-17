// Parameters
pipe_length = 500; //[250:1000:1]
outer_diameter = 32; //[16:64:0.1]
wall_thickness = 1.8; //[0.9:3.6:0.1]
inner_diameter = 28.4; //[14.2:56.8:0.1]
socket_length = 45; //[20:90:1]
socket_outer_diameter = 38; //[32:60:0.1]
chamfer_length = 2; //[0.5:6:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  cylinder(h=pipe_length + 2*overlap, r=inner_diameter/2, center=true);
}

module socket_end() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module chamfered_ends() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
    rotate([180, 0, 0])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=0, center=true);
}

module markings_text() {
  // Placeholder for markings, represented as a small cube
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module pipe_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module pipe_with_socket_and_chamfer() {
  union() {
    pipe_with_socket();
    chamfered_ends();
  }
}

module pipe_hollowed() {
  difference() {
    pipe_with_socket_and_chamfer();
    inner_bore();
  }
}

module final_model() {
  union() {
    pipe_hollowed();
    markings_text();
  }
}

// Final Output
final_model();