// Parameters
nominal_size = 50; //[25:100:1]
length_mm = 1000; //[500:2000:10]
pipe_od = 50; //[25:100:1]
pipe_wall = 1.8; //[0.9:3.6:0.1]
fitting_length = 45; //[20:90:1]
fitting_wall_extra = 2.2; //[1.0:5.0:0.1]
fitting_id_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe segment
      difference() {
        cylinder(h=length_mm - fitting_length, r=pipe_od/2, center=false);
        translate([0, 0, 0])
          cylinder(h=length_mm - fitting_length + overlap, r=pipe_od/2 - pipe_wall, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - fitting_length - overlap])
          cylinder(h=fitting_length, r=pipe_od/2 + fitting_wall_extra, center=false);
        translate([0, 0, length_mm - fitting_length - overlap])
          cylinder(h=fitting_length + overlap, r=pipe_od/2 + fitting_id_clearance/2, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();