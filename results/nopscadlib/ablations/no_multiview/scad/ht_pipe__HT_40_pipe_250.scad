// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 40; //[20:80:1]
length_mm = 250; //[125:500:1]
include_end_fitting = 1; //[0:1:1]
od_mm = 40; //[20:80:0.5]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
fit_length_mm = 35; //[18:70:1]
fit_wall_extra_mm = 1.2; //[0.6:2.4:0.1]
fit_socket_clearance_mm = 0.4; //[0.2:0.8:0.05]
fit_stop_thickness_mm = 2.0; //[1.0:4.0:0.1]
fit_stop_depth_mm = 12; //[6:24:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      translate([0, 0, 0])
        cylinder(r=od_mm/2, h=length_mm, center=false, $fn=64);
      // Hollow bore
      translate([0, 0, -overlap_mm/2])
        cylinder(r=od_mm/2 - wall_thickness_mm, h=length_mm + overlap_mm, center=false, $fn=64);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        // Outer fitting
        translate([0, 0, length_mm - overlap_mm])
          cylinder(r=od_mm/2 + fit_wall_extra_mm, h=fit_length_mm, center=false, $fn=64);
        // Socket void
        translate([0, 0, length_mm - overlap_mm - overlap_mm/2])
          cylinder(r=od_mm/2 + fit_socket_clearance_mm, h=fit_length_mm + overlap_mm, center=false, $fn=64);
        // Stop void
        translate([0, 0, length_mm - overlap_mm + fit_stop_depth_mm - fit_stop_thickness_mm/2])
          cylinder(r=od_mm/2 + fit_socket_clearance_mm, h=fit_stop_thickness_mm, center=false, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();