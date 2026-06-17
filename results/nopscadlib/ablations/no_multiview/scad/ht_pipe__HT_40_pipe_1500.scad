// Parameters
nominal_diameter = 40; //[20:80:1]
length_mm = 1500; //[750:3000:10]
pipe_od = 40; //[20:80:1]
pipe_wall = 1.8; //[0.9:3.6:0.1]
fitting_length = 45; //[25:90:1]
fitting_wall = 3.0; //[1.5:6.0:0.1]
fitting_od_extra = 6; //[2:12:0.5]
socket_clearance = 0.6; //[0.2:1.2:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm - fitting_length + overlap, r=pipe_od/2, center=false);
      translate([0, 0, pipe_wall])
        cylinder(h=length_mm - fitting_length + overlap, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - fitting_length])
        cylinder(h=fitting_length, r=pipe_od/2 + fitting_od_extra/2, center=false);
      translate([0, 0, length_mm - fitting_length + fitting_wall])
        cylinder(h=fitting_length, r=pipe_od/2 + socket_clearance, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();