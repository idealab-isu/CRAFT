// Parameters
pipe_length = 500; //[250:1000:1]
outer_diameter = 40; //[20:80:0.5]
wall_thickness = 2; //[1:4:0.1]
inner_diameter = 36; //[18:72:0.5]
socket_length = 60; //[30:120:1]
socket_outer_diameter = 46; //[42:60:0.5]
socket_wall_thickness = 2.5; //[1.5:5:0.1]
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

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_outer_profile() {
  cone(h=chamfer_length, r1=outer_diameter/2, r2=0, center=true);
}

module chamfer_inner_profile() {
  cone(h=chamfer_length, r1=inner_diameter/2, r2=0, center=true);
}

module markings_text() {
  cube([overlap, overlap, overlap], center=true);
}

// Operations
module pipe_plus_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module pipe_hollowed() {
  difference() {
    pipe_plus_socket();
    inner_bore();
    socket_inner_bore();
  }
}

module chamfer_end1() {
  difference() {
    translate([0, 0, pipe_length/2 - chamfer_length/2 + overlap])
      chamfer_outer_profile();
    translate([0, 0, pipe_length/2 - chamfer_length/2 + overlap])
      chamfer_inner_profile();
  }
}

module chamfer_end2() {
  difference() {
    translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
      chamfer_outer_profile();
    translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
      chamfer_inner_profile();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_hollowed();
    chamfer_end1();
    chamfer_end2();
  }
}

module final_model() {
  union() {
    pipe_with_chamfers();
    markings_text();
  }
}

// Final Output
final_model();