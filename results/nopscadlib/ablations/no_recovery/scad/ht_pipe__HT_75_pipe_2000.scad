// Parameters
nominal_diameter_mm = 75; //[40:160:1]
length_mm = 2000; //[500:4000:10]
pipe_od_mm = 75; //[40:160:1]
wall_thickness_mm = 2.7; //[1.5:6:0.1]
fit_socket_length_mm = 55; //[25:120:1]
fit_socket_wall_extra_mm = 1.8; //[0.8:4:0.1]
fit_stop_ring_length_mm = 8; //[3:20:1]
fit_stop_ring_radial_mm = 2.5; //[1:6:0.1]
fit_lead_in_length_mm = 6; //[2:20:1]
overlap_mm = 1; //[0.5:2:0.1]
include_end_fitting = 1; //[0:1:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      union() {
        // Socket shell
        difference() {
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=fit_socket_length_mm, r=pipe_od_mm/2 + fit_socket_wall_extra_mm, center=false);
          translate([0, 0, length_mm - overlap_mm + wall_thickness_mm])
            cylinder(h=fit_socket_length_mm, r=pipe_od_mm/2, center=false);
        }
        
        // Stop ring
        translate([0, 0, length_mm + fit_socket_length_mm - fit_stop_ring_length_mm])
          cylinder(h=fit_stop_ring_length_mm, r=pipe_od_mm/2 + fit_socket_wall_extra_mm + fit_stop_ring_radial_mm, center=false);
        
        // Lead-in cone
        translate([0, 0, length_mm + fit_socket_length_mm - fit_lead_in_length_mm])
          cylinder(h=fit_lead_in_length_mm, r1=pipe_od_mm/2 + fit_socket_wall_extra_mm, r2=pipe_od_mm/2 + fit_socket_wall_extra_mm + fit_stop_ring_radial_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();