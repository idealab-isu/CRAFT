// Parameters
nominal_type = 40; //[20:80:1]
length_mm = 150; //[75:300:1]
include_fitting_end = 1; //[0:1:1]
center = 0; //[0:1:1]
ht40_outer_diameter = 40; //[30:60:0.1]
ht40_wall_thickness = 1.8; //[0.9:3.6:0.1]
fitting_socket_length = 25; //[12.5:50:0.5]
fitting_socket_wall_extra = 1.2; //[0.6:2.4:0.1]
fitting_socket_clearance = 0.4; //[0.2:1.0:0.05]
overlap_mm = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    // Main pipe segment
    difference() {
      cylinder(r=ht40_outer_diameter/2, h=length_mm, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(r=ht40_outer_diameter/2 - ht40_wall_thickness, h=length_mm + 2*overlap_mm, center=false);
    }
    
    // Optional fitting socket
    if (include_fitting_end) {
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(r=ht40_outer_diameter/2 + fitting_socket_wall_extra, h=fitting_socket_length, center=false);
        translate([0, 0, length_mm - 2*overlap_mm])
          cylinder(r=ht40_outer_diameter/2 + fitting_socket_clearance, h=fitting_socket_length + 2*overlap_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, (0.5 - center) * (-(length_mm + include_fitting_end*fitting_socket_length))])
    ht_pipe();
}

assembly();