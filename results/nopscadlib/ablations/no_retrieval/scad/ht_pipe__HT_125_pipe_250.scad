// Parameters
pipe_length = 250; //[125:500:1]
outer_diameter = 125; //[62.5:250:0.5]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 55; //[30:110:1]
socket_outer_diameter = 132; //[126:160:0.5]
socket_wall_thickness = 3.6; //[2:7.2:0.1]
chamfer_length = 2; //[1:6:0.5]
marking_band_width = 6; //[2:15:0.5]
marking_band_depth = 0.4; //[0.1:1.2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_inner_bore() {
  cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_cut_spigot_outer() {
  rotate([180, 0, 0])
    translate([0, 0, -pipe_length/2 + chamfer_length/2])
      cylinder(h=chamfer_length, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module chamfer_cut_spigot_inner() {
  rotate([180, 0, 0])
    translate([0, 0, -pipe_length/2 + chamfer_length/2])
      cylinder(h=chamfer_length, r1=outer_diameter/2 - wall_thickness + overlap, r2=0, center=true);
}

module chamfer_cut_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2 + overlap, r2=0, center=true);
}

module chamfer_cut_socket_inner() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2 - socket_wall_thickness + overlap, r2=0, center=true);
}

module marking_band_1_outer() {
  translate([0, 0, -pipe_length/2 + socket_length + marking_band_width/2])
    cylinder(h=marking_band_width, r=outer_diameter/2, center=true);
}

module marking_band_1_inner() {
  translate([0, 0, -pipe_length/2 + socket_length + marking_band_width/2])
    cylinder(h=marking_band_width + 2*overlap, r=outer_diameter/2 - marking_band_depth, center=true);
}

module marking_band_2_outer() {
  translate([0, 0, pipe_length/2 - socket_length - marking_band_width/2])
    cylinder(h=marking_band_width, r=outer_diameter/2, center=true);
}

module marking_band_2_inner() {
  translate([0, 0, pipe_length/2 - socket_length - marking_band_width/2])
    cylinder(h=marking_band_width + 2*overlap, r=outer_diameter/2 - marking_band_depth, center=true);
}

// Operations
module outer_union() {
  union() {
    pipe_body();
    translate([0, 0, pipe_length/2 - socket_length/2 + overlap]) socket_end();
  }
}

module bore_union() {
  union() {
    inner_bore();
    translate([0, 0, pipe_length/2 - socket_length/2 + overlap]) socket_inner_bore();
  }
}

module marking_band_1_diff() {
  difference() {
    marking_band_1_outer();
    marking_band_1_inner();
  }
}

module marking_band_2_diff() {
  difference() {
    marking_band_2_outer();
    marking_band_2_inner();
  }
}

module markings_union() {
  union() {
    marking_band_1_diff();
    marking_band_2_diff();
  }
}

module outer_with_markings() {
  union() {
    outer_union();
    markings_union();
  }
}

module chamfers_union() {
  union() {
    chamfer_cut_spigot_outer();
    chamfer_cut_spigot_inner();
    chamfer_cut_socket_outer();
    chamfer_cut_socket_inner();
  }
}

module pipe_hollowed() {
  difference() {
    outer_with_markings();
    bore_union();
  }
}

module pipe_final() {
  difference() {
    pipe_hollowed();
    chamfers_union();
  }
}

// Final Output
pipe_final();