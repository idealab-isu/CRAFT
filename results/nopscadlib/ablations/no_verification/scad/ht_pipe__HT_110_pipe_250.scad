// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 250; //[125:500:1]
pipe_od_mm = 110; //[55:220:0.5]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 55; //[28:110:1]
fitting_wall_extra_mm = 2.0; //[1.0:4.0:0.1]
fitting_od_extra_mm = 6.0; //[3.0:12.0:0.5]
socket_clearance_mm = 1.0; //[0.4:2.0:0.1]
stop_ring_thickness_mm = 3.0; //[1.5:6.0:0.5]
stop_ring_radial_mm = 2.0; //[1.0:4.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      // Inner bore
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=pipe_od_mm/2 - pipe_wall_mm, center=false);
    }
    
    // Integrated end fitting
    difference() {
      union() {
        // Fitting outer
        translate([0, 0, length_mm - fitting_length_mm])
          cylinder(h=fitting_length_mm, r=pipe_od_mm/2 + fitting_od_extra_mm/2, center=false);
        // Pipe outer
        cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      }
      // Socket void
      translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
        cylinder(h=fitting_length_mm + 2*overlap_mm, r=pipe_od_mm/2 + socket_clearance_mm, center=false);
      // Stop ring void
      translate([0, 0, length_mm - fitting_length_mm + (fitting_length_mm - stop_ring_thickness_mm)/2 - overlap_mm])
        cylinder(h=stop_ring_thickness_mm + 2*overlap_mm, r=pipe_od_mm/2 + socket_clearance_mm - stop_ring_radial_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();