// Parameters
pipe_length = 250; //[125:500:1]
outer_diameter = 32; //[16:64:0.5]
wall_thickness = 1.8; //[0.9:3.6:0.1]
socket_length = 35; //[18:70:1]
socket_outer_diameter = 38; //[34:50:0.5]
socket_wall_thickness = 2.2; //[1.2:4.4:0.1]
chamfer_length = 2; //[1:6:0.5]
chamfer_radial = 1; //[0.5:3:0.25]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body_outer() {
  cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module hollow_bore_main() {
  cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end_outer() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module socket_end_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=socket_outer_diameter/2 - socket_wall_thickness, center=true);
}

module end_chamfer_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2 + overlap])
    cylinder(h=chamfer_length, r1=socket_outer_diameter/2, r2=socket_outer_diameter/2 - chamfer_radial, center=true);
}

module end_chamfer_plain_outer() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
    rotate([180, 0, 0])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_radial, center=true);
}

module manufacturer_markings() {
  translate([outer_diameter/2 - wall_thickness/2, 0, 0])
    cube([outer_diameter/2, outer_diameter/6, wall_thickness/2], center=true);
}

// Operations
module pipe_body_with_socket() {
  union() {
    pipe_body_outer();
    socket_end_outer();
  }
}

module pipe_body_with_socket_and_chamfers() {
  union() {
    pipe_body_with_socket();
    end_chamfer_socket_outer();
    end_chamfer_plain_outer();
  }
}

module pipe_body_with_details() {
  union() {
    pipe_body_with_socket_and_chamfers();
    manufacturer_markings();
  }
}

module hollow_bore() {
  union() {
    hollow_bore_main();
    socket_end_bore();
  }
}

// Final Output
difference() {
  pipe_body_with_details();
  hollow_bore();
}