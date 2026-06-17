// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 90; //[50:180:1]
length_mm = 150; //[75:300:1]
orientation = 0; //[0:0:1]
center = 0; //[0:0:1]
pipe_od = 90; //[50:180:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
socket_length = 55; //[30:110:1]
socket_wall_extra = 1.8; //[0.8:4:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
connection_overlap = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, pipe_wall])
          cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
      }
      // End fitting socket
      difference() {
        translate([0, 0, length_mm - connection_overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_wall_extra, center=false);
        translate([0, 0, length_mm - connection_overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();