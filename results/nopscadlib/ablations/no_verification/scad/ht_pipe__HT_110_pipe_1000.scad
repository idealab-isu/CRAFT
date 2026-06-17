// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1000; //[500:2000:10]
center = 0; //[0:1:1]
ht110_outer_diameter_mm = 110; //[55:220:1]
ht110_wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fit_socket_length_mm = 60; //[30:120:1]
fit_socket_wall_extra_mm = 2.5; //[1:6:0.1]
fit_stop_ring_thickness_mm = 4; //[2:10:0.5]
fit_stop_ring_radial_mm = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=ht110_outer_diameter_mm/2, center=false);
      
      // Inner void
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=ht110_outer_diameter_mm/2 - ht110_wall_thickness_mm, center=false);
    }
    
    // End fitting socket
    union() {
      // Outer socket
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fit_socket_length_mm, r=ht110_outer_diameter_mm/2 + fit_socket_wall_extra_mm, center=false);
      
      // Inner void of socket
      translate([0, 0, length_mm - overlap_mm - overlap_mm/2])
        difference() {
          cylinder(h=fit_socket_length_mm + overlap_mm, r=ht110_outer_diameter_mm/2 - ht110_wall_thickness_mm + fit_socket_wall_extra_mm, center=false);
          
          // Stop ring void
          translate([0, 0, fit_socket_length_mm - fit_stop_ring_thickness_mm - overlap_mm/2])
            cylinder(h=fit_stop_ring_thickness_mm + overlap_mm, r=ht110_outer_diameter_mm/2 - ht110_wall_thickness_mm + fit_socket_wall_extra_mm - fit_stop_ring_radial_mm, center=false);
        }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();