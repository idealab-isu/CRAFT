// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 110; //[55:220:1]
length_mm = 2000; //[1000:4000:10]
pipe_od = 110; //[55:220:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
fitting_length = 60; //[30:120:1]
fitting_wall_extra = 2.0; //[1.0:5.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Main pipe segment
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, -overlap/2])
          cylinder(h=length_mm + overlap, r=pipe_od/2 - pipe_wall, center=false);
      }
      // End fitting
      translate([0, 0, length_mm - overlap])
        difference() {
          cylinder(h=fitting_length, r=pipe_od/2 + fitting_wall_extra, center=false);
          translate([0, 0, -overlap/2])
            cylinder(h=fitting_length + overlap, r=pipe_od/2 - pipe_wall, center=false);
        }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();