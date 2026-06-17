// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 125; //[63:250:1]
length_mm = 500; //[250:1000:1]
pipe_od_mm = 125; //[63:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_socket_length_mm = 60; //[30:120:1]
fitting_socket_wall_extra_mm = 2.5; //[1:6:0.1]
fitting_stop_ring_thickness_mm = 4; //[2:10:0.5]
fitting_stop_ring_radial_mm = 2; //[1:6:0.5]
fitting_lead_in_length_mm = 10; //[5:25:1]
include_end_fitting = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe segment
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      
      // Inner void of the pipe
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + overlap_mm*2, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
      
      if (include_end_fitting) {
        // End fitting socket outer
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_socket_length_mm, r=pipe_od_mm/2 + fitting_socket_wall_extra_mm, center=false);
        
        // End fitting socket inner void
        translate([0, 0, length_mm - overlap_mm*2])
          cylinder(h=fitting_socket_length_mm + overlap_mm*2, r=pipe_od_mm/2, center=false);
        
        // End fitting stop ring void
        translate([0, 0, length_mm + fitting_socket_length_mm - fitting_stop_ring_thickness_mm - overlap_mm])
          cylinder(h=fitting_stop_ring_thickness_mm + overlap_mm*2, r=pipe_od_mm/2 - wall_thickness_mm - fitting_stop_ring_radial_mm, center=false);
        
        // End fitting lead-in cone void
        translate([0, 0, length_mm + fitting_socket_length_mm - fitting_lead_in_length_mm])
          cylinder(h=fitting_lead_in_length_mm, r1=pipe_od_mm/2 + fitting_socket_wall_extra_mm, r2=pipe_od_mm/2, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();