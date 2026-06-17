// Parameters
length_mm = 250; //[125:500:1]
include_end_fitting = 1; //[0:1:1]
pipe_od = 75; //[60:150:0.1]
pipe_wall = 2.2; //[1.1:4.4:0.1]
socket_od = 84; //[70:170:0.1]
socket_length = 50; //[25:100:1]
socket_wall = 3.0; //[1.5:6.0:0.1]
socket_insertion_depth = 40; //[20:80:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe Body
module ht_pipe_body() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
    }
  }
}

// End Fitting Socket
module end_fitting_socket() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=socket_length, r=socket_od/2, center=false);
      union() {
        cylinder(h=socket_length, r=socket_od/2 - socket_wall, center=false);
        translate([0, 0, 0])
          cylinder(h=socket_insertion_depth, r=pipe_od/2 + overlap_mm, center=false);
      }
    }
  }
}

// HT Pipe with optional end fitting
module ht_pipe() {
  if (include_end_fitting) {
    union() {
      ht_pipe_body();
      translate([0, 0, length_mm - overlap_mm]) end_fitting_socket();
    }
  } else {
    ht_pipe_body();
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();