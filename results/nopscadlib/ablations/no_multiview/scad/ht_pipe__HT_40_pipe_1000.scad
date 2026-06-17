// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 40; //[20:80:1]
length_mm = 1000; //[500:2000:10]
ht40_outer_diameter = 40; //[30:80:1]
ht40_wall_thickness = 1.8; //[1:4:0.1]
fitting_length = 55; //[30:120:1]
fitting_outer_diameter = 46; //[40:90:1]
fitting_wall_thickness = 2.2; //[1.2:6:0.1]
fitting_overlap = 1; //[0.5:2:0.1]
inner_void_clearance = 0.2; //[0:0.6:0.05]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=ht40_outer_diameter/2, center=false);
        translate([0, 0, -fitting_overlap])
          cylinder(h=length_mm + fitting_overlap, r=ht40_outer_diameter/2 - ht40_wall_thickness + inner_void_clearance, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - fitting_overlap])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
        translate([0, 0, length_mm - fitting_overlap])
          cylinder(h=fitting_length + fitting_overlap, r=fitting_outer_diameter/2 - fitting_wall_thickness + inner_void_clearance, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();