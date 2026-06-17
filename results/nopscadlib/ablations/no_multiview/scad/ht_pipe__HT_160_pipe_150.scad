// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 160; //[80:320:1]
length_mm = 150; //[75:300:1]
od_mm = 160; //[80:320:1]
wall_mm = 4; //[2:8:0.5]
socket_length_mm = 25; //[12:50:1]
socket_wall_extra_mm = 2; //[1:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(h=length_mm, r=od_mm/2, center=false);
        translate([0, 0, wall_mm])
          cylinder(h=length_mm - wall_mm, r=od_mm/2 - wall_mm, center=false);
      }
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=socket_length_mm, r=od_mm/2 + socket_wall_extra_mm, center=false);
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=socket_length_mm, r=od_mm/2 - wall_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();