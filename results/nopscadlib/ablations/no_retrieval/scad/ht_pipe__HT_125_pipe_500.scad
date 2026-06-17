// Parameters
pipe_length = 500; //[250:1000:1]
outer_diameter = 125; //[62.5:250:0.1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
inner_diameter = 118.6; //[59.3:237.2:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 135; //[120:170:0.1]
socket_wall_thickness = 4; //[2:8:0.1]
socket_inner_diameter = 127; //[120:150:0.1]
groove_width = 6; //[3:12:0.1]
groove_depth = 1.8; //[0.8:3.5:0.1]
groove_offset_from_end = 18; //[8:40:0.1]
chamfer_length = 3; //[1:8:0.1]
chamfer_radial = 1.5; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_outer_body() {
  translate([0, 0, 0])
    cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module pipe_inner_bore() {
  translate([0, 0, 0])
    cylinder(h=pipe_length + 2*overlap, r=inner_diameter/2, center=true);
}

module socket_outer_body() {
  translate([0, 0, pipe_length/2 - socket_length/2])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2])
    cylinder(h=socket_length + 2*overlap, r=socket_inner_diameter/2, center=true);
}

module sealing_groove_cutter() {
  translate([0, 0, pipe_length/2 - groove_offset_from_end])
    cylinder(h=groove_width, r=socket_inner_diameter/2 + groove_depth, center=true);
}

module chamfer_socket_outer_cutter() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2 + overlap, r2=socket_outer_diameter/2 - chamfer_radial, center=true);
}

module chamfer_socket_inner_cutter() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=socket_inner_diameter/2 + chamfer_radial, r2=socket_inner_diameter/2 - overlap, center=true);
}

module chamfer_spigot_outer_cutter() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + overlap, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module chamfer_spigot_inner_cutter() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=inner_diameter/2 + chamfer_radial, r2=inner_diameter/2 - overlap, center=true);
}

module end_faces() {
  translate([0, 0, 0])
    cylinder(h=overlap, r=socket_outer_diameter/2, center=true);
}

// Operations
module pipe_shell() {
  difference() {
    pipe_outer_body();
    pipe_inner_bore();
  }
}

module pipe_with_socket_outer() {
  union() {
    pipe_shell();
    socket_outer_body();
  }
}

module pipe_with_socket_hollow() {
  difference() {
    pipe_with_socket_outer();
    socket_inner_bore();
  }
}

module pipe_with_groove() {
  difference() {
    pipe_with_socket_hollow();
    sealing_groove_cutter();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_with_groove();
    chamfer_socket_outer_cutter();
    chamfer_socket_inner_cutter();
    chamfer_spigot_outer_cutter();
    chamfer_spigot_inner_cutter();
  }
}

module socket_end() {
  union() {
    pipe_with_chamfers();
    end_faces();
  }
}

// Final Output
color([0.85, 0.85, 0.8]) // Off-white for 3D printed PLA
socket_end();