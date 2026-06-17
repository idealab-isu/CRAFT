// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 90; //[45:180:1]
length_mm = 2000; //[1000:4000:10]
center = 0; //[0:1:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 70; //[35:140:1]
fitting_outer_diameter_extra_mm = 12; //[6:24:1]
socket_wall_extra_mm = 1.8; //[0.8:3.6:0.1]
socket_depth_mm = 55; //[25:110:1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    // Hollow tube body
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    difference() {
      translate([0, 0, length_mm - connection_overlap_mm])
        cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 + fitting_outer_diameter_extra_mm/2, center=false);
      translate([0, 0, length_mm + fitting_length_mm - socket_depth_mm])
        cylinder(h=socket_depth_mm, r=nominal_diameter_mm/2 + socket_wall_extra_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();