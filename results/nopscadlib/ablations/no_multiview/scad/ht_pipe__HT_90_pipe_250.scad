// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 90; //[45:180:1]
length_mm = 250; //[125:500:1]
orientation = 0; //[0:0:1]
center = 0; //[0:1:1]
pipe_od = 90; //[45:180:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
socket_length = 35; //[18:70:1]
socket_wall_extra = 2.0; //[1.0:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        translate([0, 0, 0])
          cylinder(h=length_mm, r=pipe_od/2, center=false, $fn=64);
        translate([0, 0, pipe_wall])
          cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false, $fn=64);
      }
      // End fitting socket
      difference() {
        translate([0, 0, length_mm - overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_wall_extra, center=false, $fn=64);
        translate([0, 0, length_mm - overlap + pipe_wall])
          cylinder(h=socket_length, r=pipe_od/2, center=false, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();