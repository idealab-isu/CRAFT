// Parameters
outer_diameter = 110; //[55:220:1]
length = 2000; //[1000:4000:10]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 125; //[112:160:1]
socket_wall_thickness = 3.6; //[1.8:7.2:0.1]
chamfer_length = 8; //[3:20:1]
chamfer_radial = 2; //[1:6:0.5]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  translate([0, 0, 0])
    cylinder(h=length, r=outer_diameter/2, center=true);
}

module hollow_bore() {
  translate([0, 0, 0])
    cylinder(h=length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_bore() {
  translate([0, 0, length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module chamfer_cut_pos() {
  translate([0, 0, length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + chamfer_radial, r2=0, center=true);
}

module chamfer_cut_neg() {
  translate([0, 0, -length/2 + chamfer_length/2])
    rotate([180, 0, 0])
      cylinder(h=chamfer_length, r1=outer_diameter/2 + chamfer_radial, r2=0, center=true);
}

// Operations
module pipe_plus_socket() {
  union() {
    pipe_body();
    socket_end();
    // Manufacturer marking text is not included as per rules
  }
}

module pipe_hollowed() {
  difference() {
    pipe_plus_socket();
    hollow_bore();
    socket_bore();
  }
}

module chamfered_ends() {
  difference() {
    pipe_hollowed();
    chamfer_cut_pos();
    chamfer_cut_neg();
  }
}

// Final Output
chamfered_ends();