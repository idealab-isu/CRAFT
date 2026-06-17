// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 1500; //[750:3000:10]
pipe_wall_mm = 2.4; //[1.2:4.8:0.1]
pipe_od_mm = 50; //[25:100:1]
fitting_length_mm = 45; //[20:90:1]
fitting_wall_extra_mm = 2.0; //[1.0:6.0:0.5]
fitting_socket_depth_mm = 30; //[10:70:1]
overlap_mm = 1; //[0.5:2:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=pipe_od_mm/2 - pipe_wall_mm, center=false);
    }
    
    // End fitting
    difference() {
      union() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=pipe_od_mm/2 + fitting_wall_extra_mm, center=false);
        // Ensure solid connection with pipe body
        translate([0, 0, 0])
          cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
      }
      translate([0, 0, length_mm + fitting_length_mm - fitting_socket_depth_mm - overlap_mm])
        cylinder(h=fitting_socket_depth_mm + 2*overlap_mm, r=pipe_od_mm/2 + fitting_wall_extra_mm - pipe_wall_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();