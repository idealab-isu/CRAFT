// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 75; //[40:160:1]
length_mm = 500; //[250:1000:1]
center = 0; //[0:1:1]
pipe_od = 75; //[40:160:1]
pipe_wall = 2.7; //[1.5:6:0.1]
socket_length = 55; //[30:120:1]
socket_wall_extra = 1.8; //[0.5:5:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
connect_overlap = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(r=pipe_od/2, h=length_mm, center=false);
      translate([0, 0, pipe_wall])
        cylinder(r=pipe_od/2 - pipe_wall, h=length_mm, center=false);
    }
    
    // End fitting socket
    difference() {
      translate([0, 0, length_mm - connect_overlap])
        cylinder(r=pipe_od/2 + socket_wall_extra, h=socket_length, center=false);
      translate([0, 0, length_mm - connect_overlap])
        cylinder(r=pipe_od/2 + socket_clearance, h=socket_length, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();