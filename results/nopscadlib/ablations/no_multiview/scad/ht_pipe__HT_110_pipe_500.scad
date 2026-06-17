// Parameters
pipe_standard = 0; //[0:1:1]
nominal_diameter = 110; //[55:220:1]
length_mm = 500; //[250:1000:1]
pipe_od = 110; //[90:160:1]
pipe_wall = 3.2; //[2:6.5:0.1]
socket_od_extra = 6; //[3:12:0.5]
socket_length = 60; //[30:120:1]
socket_wall_extra = 1.5; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Hollow tube body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, -overlap/2])
        cylinder(h=length_mm + overlap, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    translate([0, 0, length_mm - socket_length]) {
      difference() {
        cylinder(h=socket_length, r=pipe_od/2 + socket_od_extra/2, center=false);
        translate([0, 0, -overlap/2])
          cylinder(h=socket_length + overlap, r=pipe_od/2 - pipe_wall + socket_wall_extra, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();