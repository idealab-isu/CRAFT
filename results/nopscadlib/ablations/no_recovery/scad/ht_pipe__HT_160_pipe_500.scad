// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 500; //[250:1000:1]
include_end_fitting = 1; //[0:1:1]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
od_mm = 160; //[80:320:1]
fit_length_mm = 70; //[35:140:1]
fit_od_extra_mm = 8; //[3:20:0.5]
fit_wall_extra_mm = 1.5; //[0.5:4:0.1]
socket_depth_mm = 55; //[25:110:1]
overlap_mm = 1; //[0.5:2:0.1]

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
          cylinder(h=fit_length_mm, r=(od_mm + fit_od_extra_mm)/2, center=false);
        translate([0, 0, length_mm - overlap_mm/2])
          cylinder(h=socket_depth_mm + overlap_mm, r=od_mm/2 + wall_thickness_mm, center=false);
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fit_length_mm + overlap_mm, r=(od_mm + fit_od_extra_mm)/2 - (wall_thickness_mm + fit_wall_extra_mm), center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();