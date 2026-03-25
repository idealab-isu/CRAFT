// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
pipe_od = 50; //[25:100:1]
pipe_wall = 2.4; //[1.2:4.8:0.1]
socket_length = 45; //[20:90:1]
socket_wall = 3.0; //[1.5:6.0:0.1]
socket_od_extra = 8; //[2:20:1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // Integrated end fitting socket
    translate([0, 0, length_mm - overlap]) {
      difference() {
        cylinder(h=socket_length, r=(pipe_od + socket_od_extra)/2, center=false);
        translate([0, 0, 0])
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