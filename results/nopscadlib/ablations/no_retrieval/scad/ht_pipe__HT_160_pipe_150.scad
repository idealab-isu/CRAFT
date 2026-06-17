// Parameters
outer_diameter = 160; //[80:320:1]
length = 150; //[75:300:1]
wall_thickness = 4; //[2:8:0.5]
socket_length = 45; //[20:90:1]
socket_extra_radius = 3; //[1:8:0.5]
chamfer_length = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module pipe_body() {
  translate([0, 0, 0])
    cylinder(h=length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
    cylinder(h=length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, length/2 - socket_length/2 + overlap/2])
    cylinder(h=socket_length, r=outer_diameter/2 + socket_extra_radius, center=true);
}

module chamfer_edges() {
  translate([0, 0, length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + socket_extra_radius + overlap, r2=outer_diameter/2 + socket_extra_radius, center=true);
}

// Operations
module outer_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module outer_minus_chamfer() {
  difference() {
    outer_with_socket();
    chamfer_edges();
  }
}

module final_pipe() {
  difference() {
    outer_minus_chamfer();
    inner_bore();
  }
}

// Final Output
color("Silver") final_pipe();