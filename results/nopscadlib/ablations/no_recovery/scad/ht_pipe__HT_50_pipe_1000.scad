// Parameters
pipe_standard = 1; //[1:1]
nominal_diameter = 50; //[25:100:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 50; //[25:100:1]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 45; //[25:90:1]
fitting_od_mm = 56; //[50:80:1]
socket_wall_extra_mm = 2.2; //[1:5:0.1]
socket_depth_mm = 35; //[15:70:1]
socket_clearance_mm = 0.4; //[0.1:1:0.1]
chamfer_length_mm = 6; //[2:15:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      translate([0, 0, length_mm - overlap_mm]) {
        difference() {
          cylinder(h=fitting_length_mm, r=fitting_od_mm/2, center=false);
          translate([0, 0, -overlap_mm])
            cylinder(h=socket_depth_mm + overlap_mm, r=od_mm/2 + socket_clearance_mm, center=false);
          translate([0, 0, socket_depth_mm - chamfer_length_mm])
            cylinder(h=chamfer_length_mm, r1=od_mm/2 + socket_clearance_mm + chamfer_length_mm, r2=od_mm/2 + socket_clearance_mm, center=false);
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