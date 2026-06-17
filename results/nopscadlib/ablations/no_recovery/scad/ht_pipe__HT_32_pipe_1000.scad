// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size_mm = 32; //[16:64:1]
length_mm = 1000; //[500:2000:10]
pipe_od_mm = 32; //[20:64:1]
pipe_wall_mm = 2.4; //[1.2:4.8:0.1]
fit_socket_len_mm = 45; //[25:90:1]
fit_socket_wall_extra_mm = 1.6; //[0.8:3.2:0.1]
fit_stop_ring_len_mm = 6; //[3:12:1]
fit_stop_ring_radial_mm = 2; //[1:4:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      translate([0, 0, pipe_wall_mm])
        cylinder(h=length_mm, r=pipe_od_mm/2 - pipe_wall_mm, center=false);
    }
    
    // End fitting socket
    difference() {
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=fit_socket_len_mm, r=pipe_od_mm/2 + fit_socket_wall_extra_mm, center=false);
      translate([0, 0, length_mm - overlap_mm + pipe_wall_mm])
        cylinder(h=fit_socket_len_mm, r=pipe_od_mm/2 - pipe_wall_mm, center=false);
    }
    
    // End fitting stop ring
    translate([0, 0, length_mm - overlap_mm])
      cylinder(h=fit_stop_ring_len_mm, r=pipe_od_mm/2 + fit_socket_wall_extra_mm + fit_stop_ring_radial_mm, center=false);
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();