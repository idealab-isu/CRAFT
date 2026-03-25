// Parameters
nominal_size = 110; //[50:200:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 110; //[55:220:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_length = 55; //[25:110:1]
fitting_od_scale = 1.08; //[1.02:1.2:0.01]
fitting_wall_scale = 1.25; //[1.0:1.8:0.05]
socket_depth = 35; //[15:70:1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
connect_overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(r=pipe_od/2, h=length_mm, center=false);
      translate([0, 0, pipe_wall])
        cylinder(r=pipe_od/2 - pipe_wall, h=length_mm, center=false);
    }
    
    // End fitting
    translate([0, 0, length_mm - connect_overlap]) {
      difference() {
        cylinder(r=(pipe_od * fitting_od_scale) / 2, h=fitting_length, center=false);
        cylinder(r=pipe_od/2 - pipe_wall, h=fitting_length + connect_overlap, center=false);
        translate([0, 0, fitting_length - socket_depth])
          cylinder(r=pipe_od/2 + socket_clearance, h=socket_depth, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();