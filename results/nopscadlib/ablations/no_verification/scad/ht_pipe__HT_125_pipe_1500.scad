// Parameters
nominal_od_mm = 125; //[60:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 60; //[30:120:1]
fitting_radial_add_mm = 6; //[2:15:0.5]
fitting_stop_ring_len_mm = 8; //[3:20:0.5]
fitting_stop_ring_rad_add_mm = 2; //[0.5:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=nominal_od_mm/2, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + overlap_mm*2, r=nominal_od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting detail
    if (include_end_fitting) {
      union() {
        // Outer fitting
        translate([0, 0, length_mm - fitting_length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=nominal_od_mm/2 + fitting_radial_add_mm, center=false);
        
        // Stop ring
        translate([0, 0, length_mm - fitting_stop_ring_len_mm - overlap_mm])
          cylinder(h=fitting_stop_ring_len_mm, r=nominal_od_mm/2 + fitting_radial_add_mm + fitting_stop_ring_rad_add_mm, center=false);
      }
      
      // Bore cutter for fitting
      translate([0, 0, length_mm - fitting_length_mm - overlap_mm*2])
        cylinder(h=fitting_length_mm + overlap_mm*2, r=nominal_od_mm/2 - wall_thickness_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();