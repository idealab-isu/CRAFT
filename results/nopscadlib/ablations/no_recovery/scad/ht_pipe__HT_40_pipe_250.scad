// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 250; //[125:500:1]
pipe_od = 40; //[30:80:0.5]
pipe_wall = 1.8; //[1:4:0.1]
fitting_length = 45; //[25:90:1]
fitting_wall_extra = 1.2; //[0.5:3:0.1]
fitting_od_extra = 4; //[2:10:0.5]
socket_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Main pipe segment
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, -overlap])
          cylinder(h=length_mm + 2*overlap, r=pipe_od/2 - pipe_wall, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - fitting_length])
          cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_extra/2, center=false);
        translate([0, 0, length_mm - fitting_length - overlap])
          cylinder(h=fitting_length + overlap, r=pipe_od/2 + socket_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();