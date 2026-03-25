// Parameters
length_mm = 1500; //[750:3000:10]
ht110_outer_diameter_mm = 110; //[90:140:1]
ht110_wall_thickness_mm = 3.2; //[2:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 45; //[20:90:1]
fitting_radial_thickness_mm = 4; //[2:10:0.5]
connect_overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe Segment - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=ht110_outer_diameter_mm/2, center=true);
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*connect_overlap_mm, r=ht110_outer_diameter_mm/2 - ht110_wall_thickness_mm, center=true);
    }
    
    // End fitting
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm/2 - fitting_length_mm/2 + connect_overlap_mm])
          cylinder(h=fitting_length_mm, r=ht110_outer_diameter_mm/2 + fitting_radial_thickness_mm, center=true);
        translate([0, 0, length_mm/2 - fitting_length_mm/2 + connect_overlap_mm])
          cylinder(h=fitting_length_mm + 2*connect_overlap_mm, r=ht110_outer_diameter_mm/2 - ht110_wall_thickness_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();