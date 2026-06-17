// Parameters
pipe_length = 1000; //[500:2000:1]
outer_diameter = 160; //[80:320:1]
wall_thickness = 4.7; //[2.35:9.4:0.1]
socket_length = 70; //[35:140:1]
socket_outer_diameter = 170; //[160:220:1]
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
    cylinder(h=socket_length, r=socket_outer_diameter/2, center=true);
}

module chamfer_edges() {
  translate([0, 0, -pipe_length/2 + chamfer_length/2 - overlap])
    cylinder(h=chamfer_length, r1=outer_diameter/2, r2=outer_diameter/2 - chamfer_length, center=true);
}

module markings_text() {
  translate([0, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Operations
module complete_model() {
  union() {
    difference() {
      union() {
        pipe_body();
        socket_end();
      }
      inner_bore();
      chamfer_edges();
    }
    markings_text();
  }
}

// Final Output
complete_model();