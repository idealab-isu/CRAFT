// Parameters
nominal_size = 75; //[40:160:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
pipe_od = 75; //[60:110:1]
wall_thickness = 2.7; //[1.5:5.5:0.1]
socket_length = 60; //[30:120:1]
socket_wall_extra = 2.5; //[1:6:0.1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
stop_ring_thickness = 3; //[1:8:0.1]
stop_ring_depth = 1.5; //[0.5:4:0.1]
chamfer_length = 2; //[0.5:6:0.1]
overlap = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm - socket_length + overlap, r=pipe_od/2, center=false);
      translate([0, 0, -overlap])
        cylinder(h=length_mm - socket_length + overlap + 2*overlap, r=pipe_od/2 - wall_thickness, center=false);
    }
    
    // End fitting socket
    translate([0, 0, length_mm - socket_length]) {
      difference() {
        union() {
          cylinder(h=socket_length, r=pipe_od/2 + socket_wall_extra, center=false);
          translate([0, 0, socket_length - chamfer_length])
            cylinder(h=chamfer_length, r1=pipe_od/2 + socket_clearance, r2=pipe_od/2 + socket_clearance + chamfer_length, center=false);
        }
        translate([0, 0, -overlap])
          cylinder(h=socket_length + 2*overlap, r=pipe_od/2 + socket_clearance, center=false);
        translate([0, 0, socket_length - stop_ring_thickness - overlap])
          cylinder(h=stop_ring_thickness + 2*overlap, r=pipe_od/2 + socket_clearance - stop_ring_depth, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();