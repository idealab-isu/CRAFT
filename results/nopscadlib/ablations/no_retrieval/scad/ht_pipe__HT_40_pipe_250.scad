// Parameters
pipe_length = 250; //[125:500:1]
outer_diameter = 40; //[20:80:1]
wall_thickness = 2; //[1:4:0.1]
socket_length = 45; //[25:90:1]
socket_wall_extra = 1.5; //[0.5:3:0.1]
socket_od_extra = 6; //[2:12:0.5]
chamfer_length = 2; //[0.5:5:0.1]
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
    cylinder(h=socket_length, r=(outer_diameter + socket_od_extra)/2, center=true);
}

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=(outer_diameter + socket_od_extra)/2 - (wall_thickness + socket_wall_extra), center=true);
}

module chamfer_cut_spigot() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module chamfer_cut_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=(outer_diameter + socket_od_extra)/2 + overlap, r2=0, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module pipe_plus_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module hollow_with_socket_bore() {
  difference() {
    pipe_plus_socket();
    inner_bore();
    socket_inner_bore();
  }
}

module chamfers() {
  difference() {
    hollow_with_socket_bore();
    chamfer_cut_spigot();
    chamfer_cut_socket_outer();
  }
}

module final_model() {
  union() {
    chamfers();
    markings_text();
  }
}

// Final Output
final_model();