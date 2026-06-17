// Parameters
length_mm = 500; //[250:1000:1]
od_mm = 40; //[30:80:1]
wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 35; //[18:70:1]
fitting_wall_extra_mm = 1.2; //[0.6:2.4:0.1]
fitting_id_clearance_mm = 0.4; //[0.2:1.0:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Main pipe segment
    difference() {
      cylinder(h=length_mm, r=od_mm/2, center=false);
      translate([0, 0, -overlap_mm/2])
        cylinder(h=length_mm + overlap_mm, r=od_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      translate([0, 0, length_mm - overlap_mm]) {
        difference() {
          cylinder(h=fitting_length_mm, r=od_mm/2 + fitting_wall_extra_mm, center=false);
          translate([0, 0, -overlap_mm/2])
            cylinder(h=fitting_length_mm + overlap_mm, r=od_mm/2 + fitting_id_clearance_mm, center=false);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();