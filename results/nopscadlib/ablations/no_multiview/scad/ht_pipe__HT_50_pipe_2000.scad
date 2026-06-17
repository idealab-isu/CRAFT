// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 50; //[25:100:1]
length_mm = 2000; //[1000:4000:10]
include_end_fitting = 1; //[0:1:1]
ht50_od = 50; //[40:70:0.5]
ht50_wall = 1.8; //[1:4:0.1]
fit_socket_od_extra = 6; //[3:12:0.5]
fit_socket_length = 45; //[25:80:1]
fit_socket_wall = 2.5; //[1.5:6:0.1]
fit_stop_thickness = 3; //[1:8:0.5]
fit_stop_length = 6; //[2:15:0.5]
overlap = 1; //[0.5:2:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(r=ht50_od/2, h=length_mm, center=false);
      translate([0, 0, -overlap])
        cylinder(r=ht50_od/2 - ht50_wall, h=length_mm + overlap*2, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      translate([0, 0, length_mm - overlap]) {
        difference() {
          cylinder(r=ht50_od/2 + fit_socket_od_extra/2, h=fit_socket_length, center=false);
          translate([0, 0, -overlap])
            cylinder(r=ht50_od/2 + fit_socket_od_extra/2 - fit_socket_wall, h=fit_socket_length + overlap*2, center=false);
          translate([0, 0, (fit_socket_length - fit_stop_length) - overlap])
            cylinder(r=ht50_od/2 + fit_socket_od_extra/2 - fit_socket_wall - fit_stop_thickness, h=fit_stop_length + overlap*2, center=false);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();