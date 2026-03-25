// Parameters
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 250; //[125:500:1]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 55; //[25:110:1]
fitting_wall_extra_mm = 2.5; //[1:6:0.1]
fitting_inner_clearance_mm = 1; //[0.2:3:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.1]
fitting_stop_length_mm = 6; //[2:15:0.1]
fitting_stop_offset_from_end_mm = 18; //[5:40:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    // Pipe segment
    difference() {
      cylinder(r=nominal_diameter_mm/2, h=length_mm, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=length_mm + overlap_mm, center=false);
    }
    
    if (include_end_fitting) {
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(r=nominal_diameter_mm/2 + fitting_wall_extra_mm, h=fitting_length_mm, center=false);
        translate([0, 0, length_mm - overlap_mm - overlap_mm/2])
          cylinder(r=nominal_diameter_mm/2 + fitting_inner_clearance_mm, h=fitting_length_mm + overlap_mm, center=false);
        translate([0, 0, length_mm + fitting_stop_offset_from_end_mm - overlap_mm/2])
          cylinder(r=nominal_diameter_mm/2 + fitting_inner_clearance_mm - fitting_stop_thickness_mm, h=fitting_stop_length_mm + overlap_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();