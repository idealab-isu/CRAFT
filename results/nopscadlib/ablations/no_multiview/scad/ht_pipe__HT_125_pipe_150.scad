// Parameters
length_mm = 150; //[75:300:1]
outer_diameter_mm = 125; //[62.5:250:0.5]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 35; //[15:70:1]
fitting_outer_diameter_mm = 140; //[125:180:0.5]
fitting_socket_wall_mm = 4; //[2:8:0.1]
fitting_stop_thickness_mm = 3; //[1:8:0.1]
overlap_mm = 1; //[0.5:2:0.1]

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
      // End fitting
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2, center=false);
        // Socket cutter
        translate([0, 0, length_mm - overlap_mm*2])
          cylinder(h=fitting_length_mm + overlap_mm*2, r=fitting_outer_diameter_mm/2 - fitting_socket_wall_mm, center=false);
        // Stop ring cutter
        translate([0, 0, length_mm + fitting_length_mm - fitting_stop_thickness_mm - overlap_mm])
          cylinder(h=fitting_stop_thickness_mm + overlap_mm*2, r=outer_diameter_mm/2 - wall_thickness_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();