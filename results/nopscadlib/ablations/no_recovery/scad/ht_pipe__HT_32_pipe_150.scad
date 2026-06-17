// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 32; //[16:64:1]
length_mm = 150; //[75:300:1]
center = 0; //[0:1:1]
od_mm = 32; //[16:64:0.5]
wall_mm = 2.4; //[1.2:4.8:0.1]
fitting_length_mm = 25; //[12:50:1]
fitting_od_scale = 1.15; //[1.05:1.35:0.01]
fitting_socket_wall_mm = 2.0; //[1.0:4.0:0.1]
connect_overlap_mm = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe with end fitting
      union() {
        // Main pipe segment
        translate([0, 0, 0])
          cylinder(h=length_mm, r=od_mm/2, center=false, $fn=64);
        // End fitting
        translate([0, 0, length_mm - connect_overlap_mm])
          cylinder(h=fitting_length_mm, r=(od_mm*fitting_od_scale)/2, center=false, $fn=64);
      }
      // Hollow bore
      translate([0, 0, -connect_overlap_mm])
        cylinder(h=length_mm + 2*connect_overlap_mm, r=od_mm/2 - wall_mm, center=false, $fn=64);
      // End fitting socket bore
      translate([0, 0, length_mm - connect_overlap_mm - connect_overlap_mm])
        cylinder(h=fitting_length_mm + 2*connect_overlap_mm, r=od_mm/2 - wall_mm - fitting_socket_wall_mm, center=false, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();