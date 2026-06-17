// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 1000; //[500:2000:10]
center = 0; //[0:1:1]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
fit_socket_length_mm = 70; //[35:140:1]
fit_socket_wall_extra_mm = 2.5; //[1:6:0.1]
fit_stop_ring_length_mm = 8; //[4:20:1]
fit_stop_ring_radial_mm = 3; //[1:8:0.1]
fit_overlap_mm = 1; //[0.5:2:0.1]
fit_socket_id_clearance_mm = 1; //[0.2:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting socket
    difference() {
      translate([0, 0, length_mm - fit_overlap_mm])
        cylinder(h=fit_socket_length_mm, r=nominal_diameter_mm/2 + fit_socket_wall_extra_mm, center=false);
      translate([0, 0, length_mm - fit_overlap_mm])
        cylinder(h=fit_socket_length_mm, r=nominal_diameter_mm/2 + fit_socket_id_clearance_mm, center=false);
    }
    
    // Stop ring
    translate([0, 0, length_mm - fit_overlap_mm + fit_socket_length_mm - fit_stop_ring_length_mm])
      cylinder(h=fit_stop_ring_length_mm, r=nominal_diameter_mm/2 + fit_socket_wall_extra_mm + fit_stop_ring_radial_mm, center=false);
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();