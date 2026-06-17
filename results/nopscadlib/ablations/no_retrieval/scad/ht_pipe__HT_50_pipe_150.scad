// Parameters
outer_diameter = 50; //[25:100:1]
length = 150; //[75:300:1]
wall_thickness = 1.8; //[0.9:3.6:0.1]
socket_length = 35; //[18:70:1]
socket_wall_extra = 1.2; //[0.6:2.4:0.1]
socket_inner_clearance = 0.6; //[0.2:1.2:0.1]
chamfer_length = 2; //[1:6:0.5]
chamfer_radial = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Base Shapes
module pipe_body() {
  translate([0, 0, 0])
    cylinder(h=length, r=outer_diameter/2, center=true);
}

module inner_bore() {
  translate([0, 0, 0])
    cylinder(h=length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=outer_diameter/2 + socket_wall_extra, center=true);
}

module socket_bore() {
  translate([0, 0, length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=outer_diameter/2 + socket_inner_clearance, center=true);
}

module end_chamfer_male() {
  translate([0, 0, -length/2 + chamfer_length/2 - overlap])
    rotate([180, 0, 0])
      cylinder(h=chamfer_length, r1=outer_diameter/2 + chamfer_radial, r2=0, center=true);
}

module end_chamfer_socket() {
  translate([0, 0, length/2 - chamfer_length/2 + overlap])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + socket_wall_extra + chamfer_radial, r2=0, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module pipe_outer_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module pipe_hollowed() {
  difference() {
    pipe_outer_with_socket();
    inner_bore();
    socket_bore();
  }
}

module pipe_with_end_chamfers() {
  difference() {
    pipe_hollowed();
    end_chamfer_male();
    end_chamfer_socket();
  }
}

module final_model() {
  union() {
    pipe_with_end_chamfers();
    markings_text();
  }
}

// Final Output
final_model();