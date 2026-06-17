// Parameters
length_mm = 150; //[75:300:1]
outer_diameter_mm = 75; //[60:90:0.5]
wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
fitting_length_mm = 35; //[20:70:1]
fitting_radial_thickness_mm = 3.5; //[2:8:0.1]
fitting_bore_clearance_mm = 0.4; //[0.1:1.2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
include_end_fitting = 1; //[0:1:1]

// HT Pipe Segment - Complete Geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    difference() {
      // Outer pipe
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=false);
      
      // Hollow bore
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + overlap_mm*2, r=outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    if (include_end_fitting) {
      difference() {
        // End fitting outer
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=outer_diameter_mm/2 + fitting_radial_thickness_mm, center=false);
        
        // End fitting inner cutter
        translate([0, 0, length_mm - overlap_mm*2])
          cylinder(h=fitting_length_mm + overlap_mm*2, r=outer_diameter_mm/2 + fitting_bore_clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();