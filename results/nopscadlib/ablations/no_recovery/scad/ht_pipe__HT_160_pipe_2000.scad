// Parameters
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 2000; //[1000:4000:10]
od_mm = 160; //[80:320:1]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
overlap_mm = 1; //[0.5:2:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 70; //[35:140:1]
fitting_od_factor = 1.12; //[1.05:1.3:0.01]
fitting_wall_extra_mm = 1.5; //[0.5:4:0.1]
fitting_bead_length_mm = 12; //[6:30:1]
fitting_bead_od_extra_mm = 6; //[2:15:0.5]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe body
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting detail
    if (include_end_fitting) {
      difference() {
        // Outer fitting
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=(od_mm*fitting_od_factor)/2, center=false);
        // Inner void of fitting
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm + wall_thickness_mm])
          cylinder(h=fitting_length_mm, r=(od_mm/2 - wall_thickness_mm) - fitting_wall_extra_mm, center=false);
      }
      
      // Bead on fitting
      translate([0, 0, length_mm - fitting_bead_length_mm])
        cylinder(h=fitting_bead_length_mm, r=((od_mm*fitting_od_factor) + fitting_bead_od_extra_mm)/2, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();