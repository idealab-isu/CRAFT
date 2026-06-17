// Parameters
length_mm = 1500; //[750:3000:10]
ht75_outer_diameter_mm = 75; //[60:90:1]
ht75_wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 55; //[30:120:1]
fitting_outer_diameter_mm = 90; //[80:110:1]
fitting_wall_thickness_mm = 3.2; //[2:6:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Pipe body
    difference() {
      cylinder(h=length_mm, r=ht75_outer_diameter_mm/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht75_outer_diameter_mm/2 - ht75_wall_thickness_mm, center=false);
    }
    
    // End fitting (if included)
    if (include_end_fitting) {
      translate([0, 0, length_mm - connection_overlap_mm])
        difference() {
          cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2, center=false);
          translate([0, 0, 0])
            cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2 - fitting_wall_thickness_mm, center=false);
        }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();