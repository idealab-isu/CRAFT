// Parameters
pipe_length = 500; //[250:1000:1]
outer_diameter = 75; //[40:150:1]
wall_thickness = 2.5; //[1.2:6:0.1]
inner_diameter = 70; //[35:145:1]
socket_length = 60; //[30:120:1]
socket_outer_diameter = 82; //[60:160:1]
socket_wall_thickness = 3; //[1.5:8:0.1]
chamfer_length = 6; //[2:15:0.5]
chamfer_radial = 1.5; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_outer() {
  translate([0, 0, 0])
    cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
    cylinder(h=pipe_length + 2*overlap, r=inner_diameter/2, center=true);
}

module socket_outer() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_cut_socket_end() {
  translate([0, 0, pipe_length/2 - chamfer_length/2 + overlap])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2, r2=socket_outer_diameter/2 - chamfer_radial, center=true);
}

module chamfer_cut_plain_end() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
    rotate([180, 0, 0])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module pipe_plus_socket_outer() {
  union() {
    pipe_outer();
    socket_outer();
  }
}

module pipe_with_bores() {
  difference() {
    pipe_plus_socket_outer();
    inner_bore();
    socket_inner_bore();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_with_bores();
    chamfer_cut_socket_end();
    chamfer_cut_plain_end();
  }
}

module pipe_complete() {
  union() {
    pipe_with_chamfers();
    markings_text();
  }
}

// Final Output
pipe_complete();