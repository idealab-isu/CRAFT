// Parameters
pipe_standard = 0; //[0:0:1]
nominal_diameter_mm = 75; //[40:150:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 75; //[40:150:1]
pipe_wall = 2.5; //[1.5:5:0.1]
fitting_length = 60; //[30:120:1]
fitting_od_factor = 1.12; //[1.05:1.3:0.01]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe segment
    difference() {
      cylinder(h=length_mm - fitting_length + overlap, r=pipe_od/2, center=false);
      translate([0, 0, pipe_wall])
        cylinder(h=length_mm - fitting_length + overlap, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // Integrated end fitting
    difference() {
      translate([0, 0, length_mm - fitting_length])
        cylinder(h=fitting_length, r=(pipe_od * fitting_od_factor)/2, center=false);
      translate([0, 0, length_mm - fitting_length + pipe_wall])
        cylinder(h=fitting_length, r=pipe_od/2 - pipe_wall, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();