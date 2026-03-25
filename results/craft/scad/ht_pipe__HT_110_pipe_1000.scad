// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1000; //[500:2000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_radial_increase_mm = 4; //[2:10:0.5]
fitting_wall_extra_mm = 0.8; //[0.2:2.0:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    union() {
      // Pipe body
      difference() {
        cylinder(r=nominal_diameter_mm/2, h=length_mm, center=false);
        translate([0, 0, wall_thickness_mm])
          cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=length_mm, center=false);
      }
      
      // End fitting
      difference() {
        translate([0, 0, length_mm - connection_overlap_mm])
          cylinder(r=nominal_diameter_mm/2 + fitting_radial_increase_mm, h=fitting_length_mm, center=false);
        translate([0, 0, length_mm - connection_overlap_mm])
          cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=fitting_length_mm, center=false);
        translate([0, 0, length_mm - connection_overlap_mm + wall_thickness_mm])
          cylinder(r=nominal_diameter_mm/2 - (wall_thickness_mm + fitting_wall_extra_mm), h=fitting_length_mm - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();