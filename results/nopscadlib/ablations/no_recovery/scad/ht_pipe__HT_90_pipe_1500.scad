// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 90; //[45:180:1]
length_mm = 1500; //[750:3000:10]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_height = 55; //[30:110:1]
fitting_over_od = 6; //[3:12:0.5]
fitting_wall = 4; //[2:8:0.5]
socket_depth = 35; //[15:70:1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe Body
module ht_pipe_body() {
  difference() {
    cylinder(h=length_mm, r=nominal_diameter/2, center=false);
    translate([0, 0, pipe_wall])
      cylinder(h=length_mm, r=nominal_diameter/2 - pipe_wall, center=false);
  }
}

// End Fitting
module end_fitting() {
  difference() {
    cylinder(h=fitting_height, r=nominal_diameter/2 + fitting_over_od/2, center=false);
    translate([0, 0, 0])
      cylinder(h=fitting_height, r=nominal_diameter/2 - pipe_wall, center=false);
    translate([0, 0, 0])
      cylinder(h=socket_depth, r=nominal_diameter/2 + fitting_over_od/2 - fitting_wall, center=false);
  }
}

// HT Pipe - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      translate([0, 0, 0]) ht_pipe_body();
      translate([0, 0, length_mm - overlap]) end_fitting();
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();