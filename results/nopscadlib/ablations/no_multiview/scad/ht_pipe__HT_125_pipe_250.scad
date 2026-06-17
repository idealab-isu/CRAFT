// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 125; //[63:250:1]
length_mm = 250; //[100:600:1]
include_end_fitting = 1; //[0:1:1]
od_mm = 125; //[63:250:1]
wall_mm = 3.2; //[1.6:6.4:0.1]
fit_len_mm = 55; //[25:110:1]
fit_od_extra_mm = 6; //[2:15:0.5]
fit_wall_extra_mm = 1.5; //[0.5:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=od_mm/2 - wall_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fit_len_mm, r=od_mm/2 + fit_od_extra_mm/2, center=false);
        translate([0, 0, length_mm - overlap_mm - overlap_mm/2])
          cylinder(h=fit_len_mm + overlap_mm, r=od_mm/2 - wall_mm - fit_wall_extra_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();