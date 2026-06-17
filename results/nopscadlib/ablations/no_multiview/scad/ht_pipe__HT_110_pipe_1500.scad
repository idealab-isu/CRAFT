// Parameters
nominal_diameter_mm = 110; //[50:220:1]
length_mm = 1500; //[750:3000:10]
pipe_od = 110; //[55:220:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_socket_length = 60; //[30:120:1]
fitting_socket_wall = 4.0; //[2.0:8.0:0.1]
fitting_overlap = 1.0; //[0.5:2.0:0.1]
inner_clearance = 0.5; //[0.0:1.5:0.1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm - fitting_socket_length + fitting_overlap, r=pipe_od/2, center=false);
        translate([0, 0, 0])
          cylinder(h=length_mm - fitting_socket_length + fitting_overlap, r=pipe_od/2 - pipe_wall, center=false);
      }
      // Integrated end fitting
      difference() {
        translate([0, 0, length_mm - fitting_socket_length])
          cylinder(h=fitting_socket_length, r=pipe_od/2 + fitting_socket_wall, center=false);
        translate([0, 0, length_mm - fitting_socket_length])
          cylinder(h=fitting_socket_length, r=pipe_od/2 + inner_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();