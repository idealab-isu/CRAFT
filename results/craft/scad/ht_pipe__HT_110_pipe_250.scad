// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[50:200:1]
length_mm = 250; //[125:500:1]
pipe_od_mm = 110; //[55:220:0.5]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 55; //[25:110:1]
fitting_wall_extra_mm = 2.0; //[0.5:6.0:0.1]
fitting_od_extra_mm = 6.0; //[2.0:20.0:0.5]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Module for the hollow tube
module hollow_tube() {
  difference() {
    cylinder(h=length_mm, r=pipe_od_mm/2, center=true);
    translate([0, 0, -overlap_mm])
      cylinder(h=length_mm + 2*overlap_mm, r=pipe_od_mm/2 - pipe_wall_mm, center=true);
  }
}

// Module for the end fitting
module end_fitting() {
  if (include_end_fitting) {
    difference() {
      translate([0, 0, length_mm/2 + fitting_length_mm/2 - overlap_mm])
        cylinder(h=fitting_length_mm, r=pipe_od_mm/2 + fitting_od_extra_mm/2, center=true);
      translate([0, 0, length_mm/2 + fitting_length_mm/2 - overlap_mm])
        cylinder(h=fitting_length_mm + 2*overlap_mm, r=pipe_od_mm/2 + socket_clearance_mm, center=true);
    }
  }
}

// Main module for the HT pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    union() {
      hollow_tube();
      end_fitting();
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();