// Parameters
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 500; //[250:1000:1]
wall_thickness_mm = 4.9; //[2.5:10:0.1]
fitting_length_mm = 70; //[35:140:1]
fitting_od_extra_mm = 10; //[5:25:0.5]
socket_wall_extra_mm = 2.0; //[1.0:6.0:0.1]
socket_depth_mm = 55; //[25:110:1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
connection_overlap_mm = 1.0; //[0.5:2.0:0.1]

// Module for the HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      cylinder(r=nominal_diameter_mm/2, h=length_mm, center=false);
      // Inner void
      translate([0, 0, 0])
        cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=length_mm, center=false);
    }
  }
}

// Module for the End Fitting
module end_fitting() {
  color([0.85, 0.85, 0.8]) {
    // Outer fitting
    difference() {
      translate([0, 0, length_mm - connection_overlap_mm])
        cylinder(r=nominal_diameter_mm/2 + fitting_od_extra_mm/2, h=fitting_length_mm, center=false);
      // Socket voids
      union() {
        translate([0, 0, length_mm + fitting_length_mm - socket_depth_mm])
          cylinder(r=nominal_diameter_mm/2 + socket_clearance_mm, h=socket_depth_mm, center=false);
        translate([0, 0, length_mm - connection_overlap_mm])
          cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=fitting_length_mm, center=false);
      }
    }
  }
}

// Assembly of the HT Pipe Segment
module assembly() {
  ht_pipe();
  end_fitting();
}

// Call the assembly
assembly();