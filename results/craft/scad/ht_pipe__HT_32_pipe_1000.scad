// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 32; //[16:64:1]
length_mm = 1000; //[500:2000:10]
ht32_outer_diameter = 32; //[24:40:0.5]
ht32_wall_thickness = 1.8; //[1.0:3.0:0.1]
fit_socket_length = 45; //[25:80:1]
fit_socket_wall = 2.5; //[1.5:5.0:0.1]
fit_stop_ring_length = 6; //[2:15:1]
fit_stop_ring_radial = 1.5; //[0.5:4.0:0.1]
fit_inner_clearance = 0.3; //[0.0:1.0:0.05]
connect_overlap = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow tube body
    difference() {
      cylinder(r=ht32_outer_diameter/2, h=length_mm, center=false);
      translate([0, 0, -connect_overlap])
        cylinder(r=ht32_outer_diameter/2 - ht32_wall_thickness, h=length_mm + 2*connect_overlap, center=false);
    }
    
    // End fitting
    difference() {
      union() {
        // Socket outer
        translate([0, 0, length_mm - connect_overlap])
          cylinder(r=ht32_outer_diameter/2 + fit_socket_wall, h=fit_socket_length, center=false);
        // Stop ring outer
        translate([0, 0, length_mm - connect_overlap])
          cylinder(r=ht32_outer_diameter/2 + fit_socket_wall + fit_stop_ring_radial, h=fit_stop_ring_length, center=false);
      }
      // Socket inner void
      translate([0, 0, length_mm - connect_overlap - connect_overlap])
        cylinder(r=ht32_outer_diameter/2 + fit_inner_clearance, h=fit_socket_length + 2*connect_overlap, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();