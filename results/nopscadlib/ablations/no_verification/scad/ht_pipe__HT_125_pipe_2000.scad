// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size_mm = 125; //[63:250:1]
length_mm = 2000; //[1000:4000:10]
pipe_od_mm = 125; //[63:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_od_extra_mm = 8; //[4:20:1]
fitting_wall_extra_mm = 1.8; //[0.8:4:0.1]
socket_depth_mm = 45; //[20:90:1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe segment
      difference() {
        cylinder(h=length_mm, r=pipe_od_mm/2, center=false);
        translate([0, 0, -overlap_mm])
          cylinder(h=length_mm + 2*overlap_mm, r=pipe_od_mm/2 - wall_thickness_mm, center=false);
      }
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=pipe_od_mm/2 + fitting_od_extra_mm/2, center=false);
        translate([0, 0, length_mm + fitting_length_mm - socket_depth_mm - overlap_mm])
          cylinder(h=socket_depth_mm + overlap_mm, r=pipe_od_mm/2 + fitting_od_extra_mm/2 - (wall_thickness_mm + fitting_wall_extra_mm), center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();