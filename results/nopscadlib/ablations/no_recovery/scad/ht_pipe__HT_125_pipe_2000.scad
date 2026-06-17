// Parameters
pipe_standard = 0; //[0:1:1]
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 125; //[60:250:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_length = 60; //[30:120:1]
fitting_wall_extra = 1.8; //[0.8:4:0.1]
fitting_socket_clearance = 0.6; //[0.2:1.2:0.1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, -overlap])
        cylinder(h=length_mm + overlap*2, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - overlap])
        cylinder(h=fitting_length, r=pipe_od/2 + fitting_wall_extra, center=false);
      translate([0, 0, length_mm - overlap - overlap])
        cylinder(h=fitting_length + overlap*2, r=pipe_od/2 + fitting_socket_clearance, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();