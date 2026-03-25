// Parameters
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
ht32_outer_diameter = 32; //[28:40:0.5]
wall_thickness = 1.8; //[1.0:3.0:0.1]
fit_overlap = 1; //[0.5:2:0.1]
socket_length = 22; //[12:40:1]
socket_wall_extra = 1.2; //[0.5:3:0.1]
socket_inner_clearance = 0.4; //[0.1:1.0:0.05]
stop_ring_length = 3; //[1:8:0.5]
stop_ring_thickness = 1.2; //[0.5:3:0.1]
chamfer_length = 2; //[0.5:6:0.5]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=ht32_outer_diameter/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht32_outer_diameter/2 - wall_thickness, center=false);
    }
    
    if (include_end_fitting) {
      // End fitting
      difference() {
        translate([0, 0, length_mm - socket_length - fit_overlap])
          cylinder(h=socket_length, r=ht32_outer_diameter/2 + socket_wall_extra, center=false);
        
        translate([0, 0, length_mm - socket_length - fit_overlap])
          cylinder(h=socket_length, r=ht32_outer_diameter/2 + socket_inner_clearance, center=false);
        
        translate([0, 0, length_mm - socket_length - fit_overlap])
          cylinder(h=stop_ring_length, r=ht32_outer_diameter/2 + socket_inner_clearance - stop_ring_thickness, center=false);
        
        translate([0, 0, length_mm - fit_overlap])
          cylinder(h=chamfer_length, r1=ht32_outer_diameter/2 + socket_inner_clearance, r2=0, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();