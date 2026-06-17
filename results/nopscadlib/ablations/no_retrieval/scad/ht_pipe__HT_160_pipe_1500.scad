// Parameters
pipe_length = 1500; //[750:3000:1]
outer_diameter = 160; //[80:320:1]
wall_thickness = 4.7; //[2.35:9.4:0.1]
socket_length = 70; //[35:140:1]
socket_wall_extra = 2.3; //[1.0:5.0:0.1]
socket_od_extra = 6; //[2:15:0.5]
chamfer_length = 3; //[1:8:0.5]
chamfer_radial = 2; //[0.5:6:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module pipe_body() {
  translate([0, 0, 0])
    cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module pipe_bore() {
  translate([0, 0, 0])
    cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=outer_diameter/2 + socket_od_extra/2, center=true);
}

module socket_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=outer_diameter/2 - (wall_thickness + socket_wall_extra), center=true);
}

module chamfer_cut_socket_end() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + socket_od_extra/2 + chamfer_radial, r2=outer_diameter/2 + socket_od_extra/2, center=true);
}

module chamfer_cut_plain_end() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + chamfer_radial, r2=outer_diameter/2, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module pipe_shell() {
  difference() {
    pipe_body();
    pipe_bore();
  }
}

module pipe_with_socket_outer() {
  union() {
    pipe_shell();
    socket_end();
  }
}

module pipe_with_socket_hollow() {
  difference() {
    pipe_with_socket_outer();
    socket_bore();
  }
}

module chamfer_edges() {
  difference() {
    pipe_with_socket_hollow();
    chamfer_cut_socket_end();
    chamfer_cut_plain_end();
  }
}

module complete_model() {
  union() {
    chamfer_edges();
    markings_text();
  }
}

// Final Output
complete_model();