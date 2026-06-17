// Parameters
nominal_diameter_mm = 90; //[45:180:1]
length_mm = 1500; //[750:3000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
center = 0; //[0:1:1]
fit_overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 35; //[15:70:1]
fitting_od_extra_mm = 6; //[2:15:0.5]
fitting_wall_extra_mm = 1.2; //[0.2:3:0.1]
fitting_stop_ring_len_mm = 6; //[2:15:0.5]
fitting_stop_ring_extra_mm = 2; //[0.5:6:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=center == 1);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=center == 1);
    }
    
    // End fitting detail
    if (include_end_fitting == 1) {
      translate([0, 0, length_mm - fit_overlap_mm]) {
        difference() {
          cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 + fitting_od_extra_mm, center=false);
          cylinder(h=fitting_length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
        }
        // Stop ring
        translate([0, 0, fitting_length_mm - fitting_stop_ring_len_mm])
          cylinder(h=fitting_stop_ring_len_mm, r=nominal_diameter_mm/2 + fitting_od_extra_mm + fitting_stop_ring_extra_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();