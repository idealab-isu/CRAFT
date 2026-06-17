// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 125; //[63:250:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
pipe_od = 125; //[63:250:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
socket_length = 55; //[30:110:1]
socket_wall_extra = 2.0; //[1.0:4.0:0.1]
socket_clearance = 0.6; //[0.2:1.2:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // Integrated socket fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap])
          cylinder(h=socket_length, r=pipe_od/2 + socket_wall_extra, center=false);
        translate([0, 0, length_mm - overlap])
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