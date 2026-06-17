// Parameters
nominal_size = 90; //[50:160:1]
length_mm = 1000; //[500:2000:10]
outer_diameter_mm = 90; //[50:160:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 60; //[30:120:1]
fitting_wall_extra_mm = 2.0; //[0.5:5.0:0.1]
fitting_od_extra_mm = 6.0; //[2.0:15.0:0.1]
socket_depth_mm = 45; //[20:90:1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
lead_in_length_mm = 10; //[3:25:1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      union() {
        // Outer cylinder of the fitting
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=outer_diameter_mm/2 + fitting_od_extra_mm/2, center=false);
        
        // Lead-in cone
        translate([0, 0, length_mm + fitting_length_mm - lead_in_length_mm])
          cylinder(h=lead_in_length_mm, r1=outer_diameter_mm/2 + socket_clearance_mm, r2=outer_diameter_mm/2 + socket_clearance_mm + wall_thickness_mm, center=false);
      }
      
      // Socket void
      translate([0, 0, length_mm + fitting_length_mm - socket_depth_mm - overlap_mm])
        cylinder(h=socket_depth_mm + overlap_mm, r=outer_diameter_mm/2 + socket_clearance_mm, center=false);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();