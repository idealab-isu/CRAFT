// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 32; //[16:64:1]
length_mm = 500; //[250:1000:1]
pipe_od = 32; //[20:64:0.5]
pipe_wall = 2.4; //[1.2:4.8:0.1]
fitting_length = 35; //[20:70:1]
fitting_od_extra = 6; //[2:12:0.5]
fitting_wall_extra = 1.2; //[0.5:3:0.1]
socket_depth = 28; //[15:60:1]
overlap = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, 0])
          cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
      }
      
      // Integrated end fitting
      translate([0, 0, length_mm - overlap])
        difference() {
          cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_extra/2, center=false);
          translate([0, 0, fitting_length - socket_depth])
            cylinder(h=socket_depth, r=pipe_od/2 + fitting_od_extra/2 - (pipe_wall + fitting_wall_extra), center=false);
        }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();