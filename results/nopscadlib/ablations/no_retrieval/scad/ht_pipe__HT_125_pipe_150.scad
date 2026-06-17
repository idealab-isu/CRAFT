// Parameters
pipe_length = 150; //[75:300:1]
outer_diameter = 125; //[80:250:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 55; //[30:110:1]
socket_wall_extra = 1.8; //[0.8:4:0.1]
socket_outer_extra_diameter = 6; //[2:14:0.5]
seal_groove_width = 6; //[3:12:0.5]
seal_groove_depth = 1.6; //[0.8:3.2:0.1]
seal_groove_offset_from_end = 12; //[6:30:1]
chamfer_length = 2; //[1:6:0.5]
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
  cylinder(h=socket_length, r=outer_diameter/2 + socket_outer_extra_diameter/2, center=true);
}

module socket_bore() {
  cylinder(h=socket_length + 2*overlap, r=outer_diameter/2 - wall_thickness + socket_outer_extra_diameter/2 - socket_wall_extra, center=true);
}

module seal_groove() {
  cylinder(h=seal_groove_width, r=outer_diameter/2 - wall_thickness + socket_outer_extra_diameter/2 - socket_wall_extra + seal_groove_depth, center=true);
}

module end_chamfer_spigot_outer() {
  cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module end_chamfer_spigot_inner() {
  cylinder(h=chamfer_length, r1=outer_diameter/2 - wall_thickness, r2=outer_diameter/2 - wall_thickness - chamfer_radial, center=true);
}

module end_chamfer_socket_outer() {
  cylinder(h=chamfer_length, r1=outer_diameter/2 + socket_outer_extra_diameter/2, r2=outer_diameter/2 + socket_outer_extra_diameter/2 - chamfer_radial, center=true);
}

module end_chamfer_socket_inner() {
  cylinder(h=chamfer_length, r1=outer_diameter/2 - wall_thickness + socket_outer_extra_diameter/2 - socket_wall_extra, r2=outer_diameter/2 - wall_thickness + socket_outer_extra_diameter/2 - socket_wall_extra - chamfer_radial, center=true);
}

module markings_text() {
  cube([overlap, overlap, overlap], center=true);
}

// Operations
module op_union_outer() {
  union() {
    pipe_body();
    translate([0, 0, pipe_length/2 - socket_length/2 + overlap/2]) socket_end();
  }
}

module op_difference_bores() {
  difference() {
    op_union_outer();
    inner_bore();
    translate([0, 0, pipe_length/2 - socket_length/2 + overlap/2]) socket_bore();
  }
}

module op_difference_seal_groove() {
  difference() {
    op_difference_bores();
    translate([0, 0, pipe_length/2 - seal_groove_offset_from_end]) seal_groove();
  }
}

module op_difference_end_chamfers() {
  difference() {
    op_difference_seal_groove();
    translate([0, 0, -pipe_length/2 + chamfer_length/2]) end_chamfer_spigot_outer();
    translate([0, 0, -pipe_length/2 + chamfer_length/2]) end_chamfer_spigot_inner();
    translate([0, 0, pipe_length/2 - chamfer_length/2]) end_chamfer_socket_outer();
    translate([0, 0, pipe_length/2 - chamfer_length/2]) end_chamfer_socket_inner();
  }
}

module op_union_final() {
  union() {
    op_difference_end_chamfers();
    markings_text();
  }
}

// Final Output
op_union_final();