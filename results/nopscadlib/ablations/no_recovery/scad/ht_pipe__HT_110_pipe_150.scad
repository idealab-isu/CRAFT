// Parameters
length_mm = 150; //[75:300:1]
outer_diameter_mm = 110; //[55:220:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 45; //[20:90:1]
fitting_outer_diameter_mm = 125; //[112:160:1]
fitting_wall_thickness_mm = 4; //[2:8:0.1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Main pipe segment
module ht_pipe_segment() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      translate([0, 0, wall_thickness_mm])
        cylinder(h=length_mm, r=outer_diameter_mm/2 - wall_thickness_mm, center=true);
    }
  }
}

// End fitting detail
module end_fitting_detail() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      translate([0, 0, length_mm/2 - fitting_length_mm/2 + overlap_mm])
        cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2, center=true);
      translate([0, 0, length_mm/2 - fitting_length_mm/2 + overlap_mm])
        cylinder(h=fitting_length_mm, r=outer_diameter_mm/2 + socket_clearance_mm, center=true);
    }
  }
}

// Complete pipe with optional end fitting
module ht_pipe() {
  if (include_end_fitting) {
    union() {
      ht_pipe_segment();
      end_fitting_detail();
    }
  } else {
    ht_pipe_segment();
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();