// Parameters
length_mm = 1000; //[500:2000:10]
ht125_outer_diameter_mm = 125; //[100:250:1]
ht125_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_socket_length_mm = 60; //[30:120:1]
fitting_socket_wall_extra_mm = 2.5; //[1:6:0.1]
fitting_socket_od_extra_mm = 6; //[2:15:0.5]
fitting_stop_ring_thickness_mm = 4; //[2:10:0.5]
fitting_stop_ring_radial_mm = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe cylinder
      cylinder(h=length_mm, r=ht125_outer_diameter_mm/2, center=false);
      
      // Inner void cylinder
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=ht125_outer_diameter_mm/2 - ht125_wall_thickness_mm, center=false);
    }
    
    if (include_end_fitting) {
      // End fitting geometry
      union() {
        // Outer socket cylinder
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_socket_length_mm, r=ht125_outer_diameter_mm/2 + fitting_socket_od_extra_mm/2, center=false);
        
        // Inner socket void cylinder
        translate([0, 0, length_mm - overlap_mm - overlap_mm])
          cylinder(h=fitting_socket_length_mm + 2*overlap_mm, r=ht125_outer_diameter_mm/2 - ht125_wall_thickness_mm + fitting_socket_wall_extra_mm, center=false);
        
        // Stop ring void cylinder
        translate([0, 0, length_mm + fitting_socket_length_mm - fitting_stop_ring_thickness_mm - overlap_mm - overlap_mm])
          cylinder(h=fitting_stop_ring_thickness_mm + 2*overlap_mm, r=ht125_outer_diameter_mm/2 - ht125_wall_thickness_mm + fitting_socket_wall_extra_mm - fitting_stop_ring_radial_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();