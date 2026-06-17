// Parameters
pipe_length = 250; //[125:500:1]
outer_diameter = 110; //[55:220:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 55; //[28:110:1]
socket_outer_diameter = 118; //[112:140:1]
socket_wall_thickness = 3.6; //[1.8:7.2:0.1]
chamfer_length = 2; //[1:6:0.5]
marking_band_length = 12; //[6:30:1]
marking_band_height = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body_outer() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module inner_bore_main() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end_outer() {
  cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module inner_bore_socket() {
  cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_spigot_outer() {
  rotate([180, 0, 0])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=0, center=true);
}

module chamfer_socket_outer() {
  cylinder(h=chamfer_length, r1=socket_outer_diameter/2, r2=0, center=true);
}

module marking_band() {
  cylinder(h=marking_band_length, r=socket_outer_diameter/2 + marking_band_height, center=true);
}

// Operations
module pipe_outer_with_socket() {
  union() {
    pipe_body_outer();
    translate([0, 0, pipe_length/2 - socket_length/2]) socket_end_outer();
  }
}

module pipe_outer_with_marking() {
  union() {
    pipe_outer_with_socket();
    translate([0, 0, pipe_length/2 - socket_length + marking_band_length/2]) marking_band();
  }
}

module pipe_outer_with_chamfers() {
  union() {
    pipe_outer_with_marking();
    translate([0, 0, -pipe_length/2 + chamfer_length/2]) chamfer_spigot_outer();
    translate([0, 0, pipe_length/2 - chamfer_length/2]) chamfer_socket_outer();
  }
}

module pipe_hollowed() {
  difference() {
    pipe_outer_with_chamfers();
    inner_bore_main();
    translate([0, 0, pipe_length/2 - socket_length/2]) inner_bore_socket();
  }
}

// Final Output
pipe_hollowed();