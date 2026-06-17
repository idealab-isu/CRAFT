// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1000; //[500:2000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_wall_extra_mm = 1.8; //[0.5:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm - fitting_length_mm, r=nominal_diameter_mm/2, center=false);
        translate([0, 0, wall_thickness_mm])
          cylinder(h=length_mm - fitting_length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 + fitting_wall_extra_mm, center=false);
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm + wall_thickness_mm])
          cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();