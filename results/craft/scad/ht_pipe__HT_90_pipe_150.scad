// Parameters
length_mm = 150; //[75:300:1]
outer_diameter_mm = 90; //[45:180:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_fitting = 1; //[0:1:1]
fitting_end = 1; //[0:1:1]
fitting_length_mm = 35; //[18:70:1]
fitting_outer_diameter_mm = 98; //[90:120:1]
fitting_wall_thickness_mm = 3.6; //[1.8:7.2:0.1]
fitting_socket_depth_mm = 25; //[12:50:1]
fitting_stop_thickness_mm = 2; //[1:5:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=true);
    }
    
    if (include_fitting) {
      // Fitting
      difference() {
        translate([0, 0, fitting_end ? length_mm/2 + fitting_length_mm/2 - overlap_mm : -(length_mm/2 + fitting_length_mm/2 - overlap_mm)])
          cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2, center=true);
        
        translate([0, 0, fitting_end ? length_mm/2 + fitting_length_mm/2 - overlap_mm : -(length_mm/2 + fitting_length_mm/2 - overlap_mm)])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=fitting_outer_diameter_mm/2 - fitting_wall_thickness_mm, center=true);
        
        translate([0, 0, fitting_end ? length_mm/2 + fitting_length_mm/2 - fitting_socket_depth_mm/2 : -(length_mm/2 + fitting_length_mm/2 - fitting_socket_depth_mm/2)])
          cylinder(h=fitting_socket_depth_mm, r=outer_diameter_mm/2 + overlap_mm, center=true);
        
        translate([0, 0, fitting_end ? length_mm/2 + fitting_length_mm/2 - fitting_socket_depth_mm + fitting_stop_thickness_mm/2 : -(length_mm/2 + fitting_length_mm/2 - fitting_socket_depth_mm + fitting_stop_thickness_mm/2)])
          cylinder(h=fitting_stop_thickness_mm + 2*overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();