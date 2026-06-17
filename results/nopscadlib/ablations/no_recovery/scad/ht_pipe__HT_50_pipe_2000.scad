// Parameters
length_mm = 2000; //[1000:4000:10]
include_socket_end = 1; //[0:1:1]
center = 0; //[0:1:1]
pipe_od = 50; //[40:100:1]
pipe_wall = 1.8; //[1:4:0.1]
socket_length = 45; //[25:90:1]
socket_wall_extra = 1.2; //[0.5:3:0.1]
socket_od_extra = 6; //[2:15:0.5]
socket_overlap = 1; //[0.5:2:0.1]
epsilon = 0.5; //[0.2:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      // Inner void
      translate([0, 0, -epsilon])
        cylinder(h=length_mm + 2*epsilon, r=pipe_od/2 - pipe_wall, center=false);
    }
  }
}

// Module for Socket End Fitting
module socket_end_fitting() {
  if (include_socket_end) {
    color([0.85, 0.85, 0.8]) {
      difference() {
        // Outer socket
        translate([0, 0, length_mm - socket_overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_od_extra/2, center=false);
        // Inner void
        translate([0, 0, length_mm - socket_overlap - epsilon])
          cylinder(h=socket_length + 2*epsilon, r=pipe_od/2 - pipe_wall, center=false);
      }
    }
  }
}

// Assembly of the HT Pipe Segment
module assembly() {
  union() {
    ht_pipe();
    socket_end_fitting();
  }
}

// Final assembly with centering option
translate([0, 0, -(length_mm/2)*center]) assembly();