// Parameters
length_mm = 250; //[125:500:1]
ht50_outer_diameter = 50; //[45:60:0.5]
wall_thickness = 1.8; //[1:3.6:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length = 18; //[9:36:1]
fitting_od_increase = 6; //[3:12:0.5]
overlap = 1; //[0.5:2:0.1]

// HT Pipe Segment - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=ht50_outer_diameter/2, center=false);
      translate([0, 0, 0])
        cylinder(h=length_mm, r=ht50_outer_diameter/2 - wall_thickness, center=false);
    }
    
    // End fitting geometry
    if (include_end_fitting) {
      translate([0, 0, length_mm - fitting_length + overlap])
        difference() {
          cylinder(h=fitting_length, r=ht50_outer_diameter/2 + fitting_od_increase/2, center=false);
          translate([0, 0, 0])
            cylinder(h=fitting_length, r=ht50_outer_diameter/2 - wall_thickness, center=false);
        }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();