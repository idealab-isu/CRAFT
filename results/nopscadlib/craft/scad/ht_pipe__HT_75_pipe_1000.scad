// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 75; //[40:150:1]
length_mm = 1000; //[500:2000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 75; //[40:150:1]
wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 55; //[30:110:1]
fitting_od_extra_mm = 6; //[2:15:0.5]
fitting_wall_extra_mm = 1.5; //[0.5:4:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.5]
fitting_stop_length_mm = 8; //[3:20:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Main pipe body
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=od_mm/2 - wall_thickness_mm, center=false);
    }
    
    if (include_end_fitting) {
      // End fitting shell
      difference() {
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=od_mm/2 + fitting_od_extra_mm/2, center=false);
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm + fitting_wall_extra_mm])
          cylinder(h=fitting_length_mm, r=od_mm/2 - wall_thickness_mm, center=false);
      }
      
      // Fitting stop ring
      difference() {
        translate([0, 0, length_mm - fitting_stop_length_mm - overlap_mm])
          cylinder(h=fitting_stop_length_mm, r=od_mm/2 - wall_thickness_mm + fitting_stop_thickness_mm, center=false);
        translate([0, 0, length_mm - fitting_stop_length_mm - overlap_mm])
          cylinder(h=fitting_stop_length_mm, r=od_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();