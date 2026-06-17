// Parameters
pipe_standard = 0; //[0:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 250; //[125:500:1]
pipe_od_mm = 110; //[90:140:0.5]
pipe_wall_mm = 3.2; //[2:6.5:0.1]
socket_length_mm = 55; //[30:90:1]
socket_wall_extra_mm = 2.5; //[1:6:0.1]
socket_od_extra_mm = 6; //[2:14:0.5]
fit_overlap_mm = 1; //[0.5:2:0.1]
clearance_mm = 0.4; //[0.1:1.2:0.05]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      // Inner void
      translate([0, 0, -fit_overlap_mm])
        cylinder(h=length_mm + fit_overlap_mm*2, r=pipe_od_mm/2 - pipe_wall_mm, center=false);
    }
    
    // End fitting socket
    translate([0, 0, length_mm - socket_length_mm - fit_overlap_mm]) {
      difference() {
        cylinder(h=socket_length_mm, r=pipe_od_mm/2 + socket_od_extra_mm/2, center=false);
        // Inner void of socket
        translate([0, 0, -fit_overlap_mm])
          cylinder(h=socket_length_mm + fit_overlap_mm*2, r=pipe_od_mm/2 + clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();