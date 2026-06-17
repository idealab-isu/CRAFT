// Parameters
pipe_length = 150; //[75:300:1]
outer_diameter = 75; //[40:150:1]
wall_thickness = 2.5; //[1.2:5:0.1]
socket_length = 45; //[25:90:1]
socket_wall_extra = 1.5; //[0.5:4:0.1]
chamfer_length = 2; //[0.5:6:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pipe_body() {
  cylinder(h = pipe_length, r = outer_diameter / 2, center = true);
}

module inner_bore() {
  cylinder(h = pipe_length + 2 * overlap, r = outer_diameter / 2 - wall_thickness, center = true);
}

module socket_end() {
  translate([0, 0, pipe_length / 2 - socket_length / 2 + overlap])
    cylinder(h = socket_length, r = outer_diameter / 2 + socket_wall_extra, center = true);
}

module chamfer_outer_spigot() {
  translate([0, 0, -pipe_length / 2 + chamfer_length / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2, r2 = 0, center = true);
}

module chamfer_inner_spigot() {
  translate([0, 0, -pipe_length / 2 + chamfer_length / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2 - wall_thickness, r2 = 0, center = true);
}

module chamfer_outer_socket() {
  translate([0, 0, pipe_length / 2 - chamfer_length / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2 + socket_wall_extra, r2 = 0, center = true);
}

module chamfer_inner_socket() {
  translate([0, 0, pipe_length / 2 - chamfer_length / 2])
    cylinder(h = chamfer_length, r1 = outer_diameter / 2 - wall_thickness, r2 = 0, center = true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center = true);
}

// Operations
module outer_union() {
  union() {
    pipe_body();
    socket_end();
  }
}

module chamfers_union() {
  union() {
    chamfer_outer_spigot();
    chamfer_inner_spigot();
    chamfer_outer_socket();
    chamfer_inner_socket();
  }
}

module pipe_with_bore() {
  difference() {
    outer_union();
    inner_bore();
  }
}

module pipe_with_chamfers() {
  difference() {
    pipe_with_bore();
    chamfers_union();
  }
}

module final_model() {
  union() {
    pipe_with_chamfers();
    markings_text();
  }
}

// Final Output
final_model();