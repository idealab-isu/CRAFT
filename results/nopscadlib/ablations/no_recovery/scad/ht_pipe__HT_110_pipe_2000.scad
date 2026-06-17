// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 2000; //[1000:4000:10]
outer_diameter_mm = 110; //[55:220:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
inner_diameter_mm = 103.6; //[51.8:207.2:0.1]
include_end_fitting = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_wall_extra_mm = 2.5; //[1:6:0.1]
fitting_inner_clearance_mm = 0.6; //[0.2:1.5:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.5]
fitting_stop_position_from_end_mm = 25; //[10:80:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow tube body
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting geometry
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=outer_diameter_mm/2 + fitting_wall_extra_mm, center=false);
        translate([0, 0, length_mm - 2*overlap_mm])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=outer_diameter_mm/2 + fitting_inner_clearance_mm, center=false);
        translate([0, 0, length_mm - overlap_mm + fitting_stop_position_from_end_mm - fitting_stop_thickness_mm/2 - overlap_mm])
          cylinder(h=fitting_stop_thickness_mm + 2*overlap_mm, r=outer_diameter_mm/2 + fitting_inner_clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();