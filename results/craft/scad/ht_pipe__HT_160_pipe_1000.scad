// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
fit_overlap_mm = 1; //[0.5:2:0.1]
socket_length_mm = 70; //[35:140:1]
socket_wall_extra_mm = 2.5; //[1:6:0.1]
socket_od_extra_mm = 6; //[2:16:0.5]
chamfer_height_mm = 3; //[1:8:0.5]
chamfer_radial_mm = 2; //[0.5:6:0.5]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Hollow tube body
    difference() {
      translate([0, 0, 0])
        cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
      translate([0, 0, -fit_overlap_mm])
        cylinder(h=length_mm + fit_overlap_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting detail
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - fit_overlap_mm])
          cylinder(h=socket_length_mm, r=nominal_diameter_mm/2 + socket_od_extra_mm/2, center=false);
        translate([0, 0, length_mm - fit_overlap_mm])
          cylinder(h=socket_length_mm + fit_overlap_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
        translate([0, 0, length_mm - fit_overlap_mm + socket_length_mm - chamfer_height_mm])
          cylinder(h=chamfer_height_mm, r1=nominal_diameter_mm/2 + socket_od_extra_mm/2, r2=nominal_diameter_mm/2 + socket_od_extra_mm/2 - chamfer_radial_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();