// Parameters
nominal_diameter_mm = 125; //[60:250:1]
length_mm = 1500; //[750:3000:10]
outer_diameter_mm = 125; //[60:250:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
socket_length_mm = 60; //[30:120:1]
socket_wall_extra_mm = 2.5; //[1:6:0.1]
socket_bore_clearance_mm = 0.6; //[0.2:1.5:0.1]

// HT Pipe Segment - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) { // PVC color
    // Main pipe segment
    difference() {
      translate([0, 0, 0])
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=false);
    }
    
    // End fitting geometry
    if (include_end_fitting) {
      difference() {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=socket_length_mm, r=outer_diameter_mm/2 + socket_wall_extra_mm, center=false);
        translate([0, 0, length_mm - overlap_mm - overlap_mm])
          cylinder(h=socket_length_mm + 2*overlap_mm, r=outer_diameter_mm/2 + socket_bore_clearance_mm, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();