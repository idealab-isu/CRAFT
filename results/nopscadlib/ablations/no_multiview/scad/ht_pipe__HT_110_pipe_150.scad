// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 110; //[55:220:1]
length_mm = 150; //[75:300:1]
pipe_od = 110; //[55:220:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
fitting_length = 45; //[25:90:1]
fitting_od_increase = 8; //[4:16:0.5]
fitting_wall_extra = 1.5; //[0.5:4:0.1]
socket_depth = 35; //[15:70:1]
overlap = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, -overlap])
        cylinder(h=length_mm + overlap*2, r=pipe_od/2 - wall_thickness, center=false);
    }
    
    // End fitting
    difference() {
      union() {
        cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_increase/2, center=false);
        translate([0, 0, length_mm - fitting_length + overlap])
          cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_increase/2, center=false);
      }
      translate([0, 0, length_mm - socket_depth])
        cylinder(h=socket_depth + overlap, r=pipe_od/2 + fitting_od_increase/2 - (wall_thickness + fitting_wall_extra), center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();