// Parameters
length_mm = 250; //[125:500:1]
ht75_outer_diameter_mm = 75; //[60:90:0.5]
ht75_wall_thickness_mm = 2.7; //[1.5:5:0.1]
include_end_fitting = 1; //[0:1:1]
end_fitting_length_mm = 18; //[8:40:1]
end_fitting_radial_thickness_mm = 2.5; //[1:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=ht75_outer_diameter_mm/2, center=true);
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*overlap_mm, r=ht75_outer_diameter_mm/2 - ht75_wall_thickness_mm, center=true);
    }
    
    // End fitting interface ring
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm/2 - end_fitting_length_mm/2 + overlap_mm])
          cylinder(h=end_fitting_length_mm, r=ht75_outer_diameter_mm/2 + end_fitting_radial_thickness_mm, center=true);
        translate([0, 0, length_mm/2 - end_fitting_length_mm/2 + overlap_mm])
          cylinder(h=end_fitting_length_mm + 2*overlap_mm, r=ht75_outer_diameter_mm/2 - ht75_wall_thickness_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();