// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 2000; //[1000:4000:10]
outer_diameter_mm = 32; //[20:64:0.5]
wall_thickness_mm = 1.8; //[1:4:0.1]
inner_diameter_mm = 28.4; //[16:60:0.5]
include_end_fitting = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 45; //[20:90:1]
fitting_outer_diameter_mm = 40; //[32:80:0.5]
fitting_wall_thickness_mm = 2.5; //[1.5:6:0.1]

// HT Pipe Segment - Complete Geometry
module ht_pipe_segment() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      translate([0, 0, 0])
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true, $fn=64);
      // Inner void
      translate([0, 0, 0])
        cylinder(h=length_mm + 2*overlap_mm, r=inner_diameter_mm/2, center=true, $fn=64);
    }
  }
}

// End Fitting - Complete Geometry
module end_fitting() {
  if (include_end_fitting) {
    color([0.85, 0.85, 0.8]) {
      difference() {
        // Outer fitting
        translate([0, 0, length_mm/2 + fitting_length_mm/2 - overlap_mm])
          cylinder(h=fitting_length_mm, r=fitting_outer_diameter_mm/2, center=true, $fn=64);
        // Inner void
        translate([0, 0, length_mm/2 + fitting_length_mm/2 - overlap_mm])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=(fitting_outer_diameter_mm - 2*fitting_wall_thickness_mm)/2, center=true, $fn=64);
      }
    }
  }
}

// HT Pipe - Complete Assembly
module ht_pipe() {
  union() {
    ht_pipe_segment();
    end_fitting();
  }
}

// Final Assembly
module assembly() {
  ht_pipe();
}

assembly();