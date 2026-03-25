// Parameters
length_mm = 250; //[125:500:1]
include_end_fitting = 1; //[0:1:1]
ht32_outer_diameter = 32; //[16:64:0.5]
ht32_wall_thickness = 1.8; //[0.9:3.6:0.1]
fitting_outer_diameter = 40; //[30:60:0.5]
fitting_length = 35; //[18:70:1]
fitting_wall_extra = 2.2; //[1:5:0.1]
socket_clearance = 0.4; //[0.1:1.2:0.05]
socket_stop_thickness = 2; //[1:5:0.1]
socket_stop_position = 22; //[10:50:1]
socket_stop_width = 3; //[1:8:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=ht32_outer_diameter/2, center=false);
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
    }
    
    // End fitting
    if (include_end_fitting) {
      union() {
        // Outer fitting
        translate([0, 0, length_mm - fitting_length - overlap_mm])
          cylinder(h=fitting_length, r=fitting_outer_diameter/2, center=false);
        
        // Socket stop ring
        translate([0, 0, length_mm - fitting_length - overlap_mm + socket_stop_position - socket_stop_width/2])
          difference() {
            cylinder(h=socket_stop_width, r=ht32_outer_diameter/2 + socket_clearance + socket_stop_thickness, center=false);
            translate([0, 0, -overlap_mm])
              cylinder(h=socket_stop_width + 2*overlap_mm, r=ht32_outer_diameter/2 + socket_clearance, center=false);
          }
      }
      
      // Socket voids
      difference() {
        translate([0, 0, length_mm - fitting_length - overlap_mm - overlap_mm])
          cylinder(h=fitting_length + 2*overlap_mm, r=ht32_outer_diameter/2 + socket_clearance, center=false);
        translate([0, 0, length_mm - fitting_length - overlap_mm - overlap_mm])
          cylinder(h=fitting_length + 2*overlap_mm, r=ht32_outer_diameter/2 - ht32_wall_thickness, center=false);
      }
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();