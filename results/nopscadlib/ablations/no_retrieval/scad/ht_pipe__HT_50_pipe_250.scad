// Parameters
pipe_length = 250; //[125:500:1]
outer_diameter = 50; //[25:100:1]
wall_thickness = 1.8; //[0.9:3.6:0.1]
socket_length = 45; //[25:90:1]
socket_wall_extra = 1.2; //[0.6:2.4:0.1]
socket_od_extra = 4; //[2:8:0.5]
chamfer_length = 2; //[1:6:0.5]
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
    cylinder(h=socket_length, r=outer_diameter/2 + socket_od_extra/2, center=true);
}

module socket_inner_bore() {
  translate([0, 0, pipe_length/2 - socket_length/2 + overlap])
    cylinder(h=socket_length + 2*overlap, r=outer_diameter/2 - wall_thickness - socket_wall_extra, center=true);
}

module chamfer_spigot_outer() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=0, center=true);
}

module chamfer_spigot_inner() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 - wall_thickness, r2=0, center=true);
}

module chamfer_socket_outer() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 + socket_od_extra/2, r2=0, center=true);
}

module chamfer_socket_inner() {
  translate([0, 0, pipe_length/2 - chamfer_length/2])
    cylinder(h=chamfer_length, r1=outer_diameter/2 - wall_thickness - socket_wall_extra, r2=0, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module outer_union() {
  union() {
    pipe_body();
    socket_end();
  }
}

module bore_union() {
  union() {
    inner_bore();
    socket_inner_bore();
  }
}

module chamfers_union() {
  union() {
    chamfer_spigot_outer();
    chamfer_spigot_inner();
    chamfer_socket_outer();
    chamfer_socket_inner();
  }
}

module pipe_hollowed() {
  difference() {
    outer_union();
    bore_union();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_hollowed();
    chamfers_union();
  }
}

// Final Model
module final_model() {
  union() {
    pipe_with_chamfers();
    markings_text();
  }
}

// Render the final model
final_model();