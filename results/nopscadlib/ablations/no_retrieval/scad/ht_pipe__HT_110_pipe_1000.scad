// Parameters
pipe_length = 1000; //[500:2000:10]
outer_diameter = 110; //[55:220:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 125; //[112:160:1]
socket_wall_thickness = 4; //[2:8:0.1]
overlap = 1; //[0.5:2:0.1]
chamfer_length = 2; //[1:6:0.5]
marking_band_width = 12; //[6:30:1]
marking_band_depth = 0.4; //[0.2:1:0.1]
marking_band_offset_from_end = 120; //[40:300:5]

// Base Shapes
module pipe_body() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module hollow_bore() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_plain_end_outer_cut() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module chamfer_plain_end_inner_cut() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 - wall_thickness + overlap, r2=0, center=true);
}

module chamfer_socket_end_outer_cut() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2 + overlap, r2=0, center=true);
}

module chamfer_socket_end_inner_cut() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2 - socket_wall_thickness + overlap, r2=0, center=true);
}

module marking_band_cut() {
  translate([0, 0, -pipe_length/2 + marking_band_offset_from_end])
    cylinder(h=marking_band_width, r=outer_diameter/2 - marking_band_depth, center=true);
}

// Operations
module pipe_plus_socket_union() {
  union() {
    pipe_body();
    socket_end();
  }
}

module pipe_socket_hollowed() {
  difference() {
    pipe_plus_socket_union();
    hollow_bore();
    socket_bore();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_socket_hollowed();
    chamfer_plain_end_outer_cut();
    chamfer_plain_end_inner_cut();
    chamfer_socket_end_outer_cut();
    chamfer_socket_end_inner_cut();
  }
}

module pipe_with_markings() {
  difference() {
    pipe_with_chamfers();
    marking_band_cut();
  }
}

// Final Output
pipe_with_markings();