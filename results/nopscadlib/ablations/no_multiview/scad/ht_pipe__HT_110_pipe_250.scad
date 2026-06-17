// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 250; //[125:500:1]
include_end_fitting = 1; //[0:1:1]
od_mm = 110; //[55:220:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 35; //[15:70:1]
fitting_wall_extra_mm = 2.5; //[1:6:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Outer pipe
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=true);
      // Inner void
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=od_mm/2 - wall_thickness_mm, center=true);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm/2 + fitting_length_mm/2 - overlap_mm])
          cylinder(h=fitting_length_mm, r=od_mm/2 + fitting_wall_extra_mm, center=true);
        translate([0, 0, length_mm/2 + fitting_length_mm/2 - overlap_mm + wall_thickness_mm])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=od_mm/2 - wall_thickness_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();