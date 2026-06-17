// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 2000; //[500:4000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 160; //[80:320:1]
wall_thickness_mm = 4.7; //[2.5:9.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 90; //[45:180:1]
fitting_od_extra_mm = 12; //[6:24:0.5]
fitting_wall_extra_mm = 2; //[0.5:5:0.1]
socket_depth_mm = 60; //[30:120:1]
socket_clearance_mm = 1; //[0.2:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=od_mm/2 + fitting_od_extra_mm/2, center=false);
        union() {
          translate([0, 0, length_mm - overlap_mm])
            cylinder(h=socket_depth_mm + overlap_mm, r=od_mm/2 + socket_clearance_mm, center=false);
          translate([0, 0, length_mm - overlap_mm/2])
            cylinder(h=fitting_length_mm + overlap_mm, r=od_mm/2 - wall_thickness_mm, center=false);
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