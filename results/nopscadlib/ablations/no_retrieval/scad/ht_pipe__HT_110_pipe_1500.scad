// Parameters
pipe_length = 1500; //[750:3000:10]
outer_diameter = 110; //[55:220:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 120; //[110:160:1]
chamfer_length = 10; //[3:25:1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  translate([0, 0, 0])
    cylinder(h=pipe_length, r=outer_diameter/2, center=true);
}

module pipe_bore() {
  translate([0, 0, 0])
    cylinder(h=pipe_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module socket_end() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module end_chamfer_cone_pos() {
  translate([0, 0, pipe_length/2 - chamfer_length/2 + overlap])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module end_chamfer_cone_neg() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

// Geometry Operations
module pipe_outer_with_socket() {
  union() {
    pipe_body();
    socket_end();
  }
}

module pipe_hollow() {
  difference() {
    pipe_outer_with_socket();
    pipe_bore();
  }
}

module pipe_with_end_chamfers() {
  difference() {
    pipe_hollow();
    end_chamfer_cone_pos();
    end_chamfer_cone_neg();
  }
}

// Final Model
module final_model() {
  pipe_with_end_chamfers();
}

// Render the final model
final_model();