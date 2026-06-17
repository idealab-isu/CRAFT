// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 32; //[16:64:1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
ht32_outer_diameter = 32; //[28:40:1]
ht32_wall_thickness = 1.8; //[1:3.6:0.1]
fitting_length = 45; //[25:90:1]
fitting_outer_diameter = 40; //[34:60:1]
fitting_wall_extra = 1.2; //[0.5:3:0.1]
fitting_stop_ring_length = 6; //[2:15:1]
fitting_stop_ring_od_extra = 2; //[0.5:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=ht32_outer_diameter/2, center=false);
      translate([0, 0, ht32_wall_thickness])
        cylinder(h=length_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
    }
    
    if (include_end_fitting) {
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
        translate([0, 0, length_mm - overlap_mm + ht32_wall_thickness])
          cylinder(h=fitting_length + overlap_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
      }
      
      // Stop ring
      difference() {
        translate([0, 0, length_mm + fitting_length - fitting_stop_ring_length])
          cylinder(h=fitting_stop_ring_length, r=(fitting_outer_diameter + fitting_stop_ring_od_extra)/2, center=false);
        translate([0, 0, length_mm + fitting_length - fitting_stop_ring_length + ht32_wall_thickness])
          cylinder(h=fitting_stop_ring_length + overlap_mm, r=fitting_outer_diameter/2 - (ht32_wall_thickness + fitting_wall_extra), center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();