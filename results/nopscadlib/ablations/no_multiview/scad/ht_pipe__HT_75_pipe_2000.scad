// Parameters
nominal_size = 75; //[50:150:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 75; //[60:110:1]
pipe_wall = 2.7; //[1.5:5.5:0.1]
overlap = 1; //[0.5:2:0.1]
fitting_length = 60; //[30:120:1]
fitting_od_scale = 1.12; //[1.02:1.3:0.01]
fitting_wall_scale = 1.25; //[1.0:2.0:0.05]
fitting_stop_thickness = 4; //[2:10:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe Body
    difference() {
      cylinder(h=length_mm, r=pipe_od/2, center=false);
      translate([0, 0, pipe_wall])
        cylinder(h=length_mm, r=pipe_od/2 - pipe_wall, center=false);
    }
    
    // End Fitting
    translate([0, 0, length_mm - overlap]) {
      difference() {
        cylinder(h=fitting_length, r=(pipe_od*fitting_od_scale)/2, center=false);
        translate([0, 0, pipe_wall])
          cylinder(h=fitting_length, r=pipe_od/2 - pipe_wall, center=false);
      }
      
      // Stop Ring
      translate([0, 0, fitting_length - fitting_stop_thickness]) {
        difference() {
          cylinder(h=fitting_stop_thickness, r=pipe_od/2 - pipe_wall + fitting_stop_thickness, center=false);
          translate([0, 0, -overlap])
            cylinder(h=fitting_stop_thickness + overlap, r=pipe_od/2 - pipe_wall, center=false);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();