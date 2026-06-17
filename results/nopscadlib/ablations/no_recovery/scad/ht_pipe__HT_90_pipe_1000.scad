// Parameters
nominal_diameter = 90; //[45:180:1]
length_mm = 1000; //[500:2000:10]
pipe_od = 90; //[45:180:1]
pipe_wall = 2.7; //[1.5:6:0.1]
socket_length = 60; //[30:120:1]
socket_wall = 3.5; //[2:8:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, -overlap/2])
          cylinder(h=length_mm + overlap, r=pipe_od/2 - pipe_wall, center=false);
      }
      // End fitting socket
      difference() {
        translate([0, 0, length_mm - overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_wall + socket_clearance, center=false);
        translate([0, 0, length_mm - overlap - overlap/2])
          cylinder(h=socket_length + overlap, r=pipe_od/2 + socket_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();