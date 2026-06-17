// Parameters
pipe_length = 250; //[125:500:1]
outer_diameter = 75; //[40:150:1]
wall_thickness = 2.5; //[1.2:5:0.1]
socket_length = 50; //[25:100:1]
socket_outer_diameter = 82; //[76:100:1]
socket_wall_thickness = 3; //[1.5:6:0.1]
chamfer_length = 2; //[0.5:5:0.1]
chamfer_radial = 1; //[0.5:3:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  translate([0, 0, 0])
    cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
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

module chamfer_spigot_outer() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module chamfer_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2, r2=socket_outer_diameter/2 - chamfer_radial, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module op_union_outer() {
  union() {
    pipe_body();
    socket_end();
  }
}

module op_union_bores() {
  union() {
    inner_bore();
    socket_inner_bore();
  }
}

module op_hollow_pipe() {
  difference() {
    op_union_outer();
    op_union_bores();
  }
}

module op_union_chamfers() {
  union() {
    chamfer_spigot_outer();
    chamfer_socket_outer();
  }
}

module op_apply_chamfers() {
  difference() {
    op_hollow_pipe();
    op_union_chamfers();
  }
}

module op_final_union() {
  union() {
    op_apply_chamfers();
    markings_text();
  }
}

// Final Output
op_final_union();