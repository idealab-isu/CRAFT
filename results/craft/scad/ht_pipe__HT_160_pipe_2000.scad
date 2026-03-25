// Parameters
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 2000; //[1000:4000:10]
wall_thickness_mm = 4.7; //[2.5:9.5:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 60; //[30:120:1]
fitting_wall_extra_mm = 2.5; //[1:6:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer cylinder of the pipe
      cylinder(r=nominal_diameter_mm/2, h=length_mm, center=true, $fn=64);
      // Inner cylinder of the pipe
      cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=length_mm + 2*connection_overlap_mm, center=true, $fn=64);
    }
  }
}

// End fitting - complete geometry
module end_fitting() {
  if (include_end_fitting) {
    color([0.85, 0.85, 0.8]) { // PVC color
      difference() {
        // Outer cylinder of the end fitting
        translate([0, 0, length_mm/2 + fitting_length_mm/2 - connection_overlap_mm])
          cylinder(r=nominal_diameter_mm/2 + fitting_wall_extra_mm, h=fitting_length_mm, center=true, $fn=64);
        // Inner cylinder of the end fitting
        translate([0, 0, length_mm/2 + fitting_length_mm/2 - connection_overlap_mm])
          cylinder(r=nominal_diameter_mm/2 - wall_thickness_mm, h=fitting_length_mm + 2*connection_overlap_mm, center=true, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  union() {
    ht_pipe();
    end_fitting();
  }
}

assembly();