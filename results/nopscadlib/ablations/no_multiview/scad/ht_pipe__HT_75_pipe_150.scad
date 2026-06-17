// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 75; //[40:160:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
pipe_od = 75; //[40:160:1]
pipe_wall = 2.7; //[1.5:5.5:0.1]
tube_id = 69.6; //[30:155:0.1]
fitting_length = 35; //[20:70:1]
fitting_od = 86; //[60:140:1]
fitting_wall = 3.2; //[2:7:0.1]
fitting_id = 79.6; //[40:160:0.1]
fitting_overlap = 1; //[0.5:2:0.1]
fitting_stop_thickness = 2; //[1:5:0.5]
fitting_stop_depth = 12; //[6:25:1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, pipe_wall])
        cylinder(h=length_mm, r=tube_id/2, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - fitting_overlap])
          cylinder(h=fitting_length, r=fitting_od/2, center=false);
        translate([0, 0, length_mm - fitting_overlap + fitting_wall])
          cylinder(h=fitting_length, r=fitting_id/2, center=false);
        translate([0, 0, length_mm - fitting_overlap + fitting_stop_depth])
          cylinder(h=fitting_stop_thickness, r=fitting_id/2, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();