// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 40; //[20:80:1]
length_mm = 1000; //[500:2000:10]
pipe_od = 40; //[20:80:1]
pipe_wall = 1.8; //[1.0:3.6:0.1]
fit_socket_od = 46; //[35:70:0.5]
fit_socket_len = 55; //[30:110:1]
fit_socket_wall = 2.2; //[1.2:4.4:0.1]
fit_stop_thickness = 3; //[1:8:0.5]
fit_stop_len = 6; //[2:15:0.5]
fit_overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      translate([0, 0, 0])
        cylinder(h=length_mm, r=pipe_od/2, center=false, $fn=64);
      translate([0, 0, -fit_overlap])
        cylinder(h=length_mm + fit_overlap*2, r=pipe_od/2 - pipe_wall, center=false, $fn=64);
    }
    
    // End fitting
    union() {
      // Outer shell
      difference() {
        translate([0, 0, length_mm - fit_overlap])
          cylinder(h=fit_socket_len, r=fit_socket_od/2, center=false, $fn=64);
        translate([0, 0, length_mm - fit_overlap*2])
          cylinder(h=fit_socket_len + fit_overlap*2, r=fit_socket_od/2 - fit_socket_wall, center=false, $fn=64);
      }
      
      // Stop ring
      difference() {
        translate([0, 0, length_mm + fit_socket_len - fit_stop_len - fit_overlap])
          cylinder(h=fit_stop_len, r=pipe_od/2, center=false, $fn=64);
        translate([0, 0, length_mm + fit_socket_len - fit_stop_len - fit_overlap*2])
          cylinder(h=fit_stop_len + fit_overlap*2, r=pipe_od/2 - fit_stop_thickness, center=false, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();