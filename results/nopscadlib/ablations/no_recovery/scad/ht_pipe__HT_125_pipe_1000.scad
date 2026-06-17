// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 125; //[63:250:1]
length_mm = 1000; //[200:2000:10]
pipe_od = 125; //[63:250:1]
pipe_wall = 3.2; //[2:6.5:0.1]
fit_length = 70; //[40:140:1]
fit_wall_extra = 1.8; //[0.8:4:0.1]
fit_id_clearance = 1.0; //[0.2:2.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=pipe_od/2, center=false);
        translate([0, 0, -overlap])
          cylinder(h=length_mm + 2*overlap, r=pipe_od/2 - pipe_wall, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap])
          cylinder(h=fit_length, r=pipe_od/2 + fit_wall_extra, center=false);
        translate([0, 0, length_mm - overlap - overlap])
          cylinder(h=fit_length + 2*overlap, r=(pipe_od + fit_id_clearance)/2, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();