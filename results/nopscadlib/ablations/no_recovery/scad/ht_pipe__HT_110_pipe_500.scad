// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 500; //[250:1000:1]
end_fitting = 1; //[0:1:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_radial_extra_mm = 6; //[2:15:0.5]
connection_overlap_mm = 1; //[0.5:2:0.1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm - (end_fitting * fitting_length_mm) + connection_overlap_mm, 
               r=nominal_diameter_mm/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm - (end_fitting * fitting_length_mm) + connection_overlap_mm, 
                 r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // Integrated end fitting
    if (end_fitting == 1) {
      difference() {
        translate([0, 0, length_mm - (end_fitting * fitting_length_mm) - connection_overlap_mm])
          cylinder(h=end_fitting * fitting_length_mm, 
                   r=nominal_diameter_mm/2 + fitting_radial_extra_mm, center=false);
        translate([0, 0, length_mm - (end_fitting * fitting_length_mm) - connection_overlap_mm])
          cylinder(h=end_fitting * fitting_length_mm, 
                   r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();