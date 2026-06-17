// Parameters
length_mm = 500; //[250:1000:1]
pipe_od_mm = 110; //[90:160:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 45; //[25:90:1]
fitting_od_scale = 1.12; //[1.05:1.25:0.01]
socket_wall_extra_mm = 2.0; //[0.5:5.0:0.1]
socket_depth_mm = 35; //[15:70:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Hollow tube body
    difference() {
      cylinder(r=pipe_od_mm/2, h=length_mm - include_end_fitting*fitting_length_mm + overlap_mm, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(r=pipe_od_mm/2 - wall_thickness_mm, h=length_mm - include_end_fitting*fitting_length_mm + overlap_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - fitting_length_mm])
          cylinder(r=(pipe_od_mm*fitting_od_scale)/2, h=fitting_length_mm, center=false);
        translate([0, 0, length_mm - socket_depth_mm])
          cylinder(r=pipe_od_mm/2 + socket_wall_extra_mm, h=socket_depth_mm, center=false);
        translate([0, 0, length_mm - fitting_length_mm])
          cylinder(r=pipe_od_mm/2 - wall_thickness_mm, h=fitting_length_mm + overlap_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();