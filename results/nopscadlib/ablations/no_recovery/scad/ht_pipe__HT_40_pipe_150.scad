// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter = 40; //[20:80:1]
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
ht40_outer_diameter = 40; //[30:60:0.5]
ht40_wall_thickness = 1.8; //[1:4:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length = 25; //[12:50:1]
fitting_od_extra = 6; //[2:15:0.5]
socket_clearance = 0.6; //[0.2:1.5:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Pipe segment
    difference() {
      cylinder(h=length_mm, r=ht40_outer_diameter/2, center=true);
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*overlap_mm, r=ht40_outer_diameter/2 - ht40_wall_thickness, center=true);
    }
    
    // End fitting
    if (include_end_fitting) {
      translate([0, 0, length_mm/2 + fitting_length/2 - overlap_mm]) {
        difference() {
          cylinder(h=fitting_length, r=ht40_outer_diameter/2 + fitting_od_extra/2, center=true);
          translate([0, 0, 0])
            cylinder(h=fitting_length + 2*overlap_mm, r=ht40_outer_diameter/2 + socket_clearance, center=true);
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