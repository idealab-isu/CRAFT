// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 250; //[125:500:1]
pipe_outer_diameter_mm = 160; //[120:200:0.5]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
include_end_fitting = 1; //[0:1:1]
fit_overlap_mm = 1; //[0.5:2:0.1]
bore_clearance_mm = 0.2; //[0:0.6:0.05]
fitting_length_mm = 55; //[30:90:1]
fitting_wall_extra_mm = 2.5; //[1:6:0.1]
fitting_outer_diameter_extra_mm = 8; //[2:20:0.5]

// HT Pipe Segment - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=pipe_outer_diameter_mm/2, center=false);
      translate([0, 0, -bore_clearance_mm])
        cylinder(h=length_mm + 2*bore_clearance_mm, r=pipe_outer_diameter_mm/2 - wall_thickness_mm + bore_clearance_mm, center=false);
    }
    
    // End fitting (if included)
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - fit_overlap_mm])
          cylinder(h=fitting_length_mm, r=pipe_outer_diameter_mm/2 + fitting_outer_diameter_extra_mm/2, center=false);
        translate([0, 0, length_mm - fit_overlap_mm - bore_clearance_mm])
          cylinder(h=fitting_length_mm + 2*bore_clearance_mm, r=pipe_outer_diameter_mm/2 - wall_thickness_mm - fitting_wall_extra_mm + bore_clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();