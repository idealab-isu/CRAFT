// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 1500; //[750:3000:10]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
end_fitting_length_mm = 60; //[30:120:1]
end_fitting_radial_add_mm = 4; //[2:10:0.5]
connection_overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=nominal_diameter_mm/2, center=false);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting detail
    translate([0, 0, length_mm - end_fitting_length_mm - connection_overlap_mm]) {
      difference() {
        cylinder(h=end_fitting_length_mm, r=nominal_diameter_mm/2 + end_fitting_radial_add_mm, center=false);
        translate([0, 0, wall_thickness_mm])
          cylinder(h=end_fitting_length_mm + connection_overlap_mm, r=nominal_diameter_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();