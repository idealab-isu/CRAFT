// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 2000; //[1000:4000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_radial_thickness_mm = 4; //[2:10:0.5]
fitting_inner_clearance_mm = 0.8; //[0.2:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // Integrated end fitting
    translate([0, 0, length_mm - overlap_mm]) {
      difference() {
        cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 + fitting_radial_thickness_mm, center=false);
        translate([0, 0, 0])
          cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 + fitting_inner_clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();