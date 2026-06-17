// Parameters
pipe_length = 500; //[250:1000:1]
outer_diameter = 110; //[55:220:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 2.0; //[1.0:4.0:0.1]
socket_outer_extra_radius = 4.0; //[2.0:10.0:0.1]
seal_groove_width = 6.0; //[3.0:12.0:0.1]
seal_groove_depth = 1.5; //[0.8:3.0:0.1]
seal_groove_offset_from_end = 18.0; //[8.0:40.0:0.5]
chamfer_length = 2.0; //[1.0:6.0:0.1]
chamfer_radial = 1.5; //[0.5:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module pipe_body_outer() {
  translate([0, 0, 0])
    cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
    cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_outer() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=outer_diameter/2 + socket_outer_extra_radius, center=true);
}

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=outer_diameter/2 - (wall_thickness + socket_wall_extra), center=true);
}

module seal_groove_cutter() {
  translate([0, 0, pipe_length/2 - seal_groove_offset_from_end])
    cylinder(h=seal_groove_width, r=outer_diameter/2 - (wall_thickness + socket_wall_extra) + seal_groove_depth, center=true);
}

module chamfer_socket_end_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + socket_outer_extra_radius, r2=outer_diameter/2 + socket_outer_extra_radius - chamfer_radial, center=true);
}

module chamfer_plain_end_outer() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module manufacturer_markings() {
  translate([0, 0, 0])
    cylinder(h=overlap, r=outer_diameter/2, center=true);
}

// Operations
module pipe_shell() {
  difference() {
    pipe_body_outer();
    inner_bore();
  }
}

module socket_end() {
  difference() {
    socket_outer();
    socket_inner_bore();
  }
}

module pipe_with_socket() {
  union() {
    pipe_shell();
    socket_end();
  }
}

module pipe_with_seal_groove() {
  difference() {
    pipe_with_socket();
    seal_groove_cutter();
  }
}

module end_chamfers() {
  difference() {
    pipe_with_seal_groove();
    chamfer_socket_end_outer();
    chamfer_plain_end_outer();
  }
}

module final_model() {
  union() {
    end_chamfers();
    manufacturer_markings();
  }
}

// Final Output
final_model();