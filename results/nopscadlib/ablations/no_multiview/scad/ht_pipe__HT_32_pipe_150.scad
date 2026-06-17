// Parameters
standard = 32; //[32:32:1]
nominal_diameter = 32; //[16:64:1]
length_mm = 150; //[75:300:1]
pipe_od = 32; //[20:64:0.5]
pipe_wall = 1.8; //[1.0:3.6:0.1]
fitting_length = 25; //[12:50:1]
fitting_od_extra = 6; //[2:12:0.5]
fitting_wall_extra = 1.2; //[0.5:3:0.1]
socket_depth = 18; //[8:40:1]
socket_clearance = 0.4; //[0.1:1.0:0.05]
stop_ring_thickness = 2; //[1:5:0.5]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, -overlap])
        cylinder(h=length_mm + 2*overlap, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    difference() {
      union() {
        cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_extra/2, center=false);
        translate([0, 0, length_mm - fitting_length - overlap])
          cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_extra/2, center=false);
      }
      translate([0, 0, length_mm - socket_depth - overlap])
        cylinder(h=socket_depth + overlap, r=pipe_od/2 + socket_clearance, center=false);
      translate([0, 0, length_mm - socket_depth - stop_ring_thickness - overlap])
        cylinder(h=stop_ring_thickness + overlap, r=pipe_od/2 - pipe_wall, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();