// Parameters
length_mm = 500; //[250:1000:1]
ht32_outer_diameter_mm = 32; //[16:64:0.5]
ht32_wall_thickness_mm = 1.8; //[0.9:3.6:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 25; //[10:60:1]
fitting_radial_thickness_mm = 2.5; //[1:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

// HT Pipe - complete geometry (one connected solid)
module ht_pipe() {
  outer_r = ht32_outer_diameter_mm/2;
  inner_r = max(0.01, outer_r - ht32_wall_thickness_mm);

  fit_outer_r = outer_r + fitting_radial_thickness_mm;
  fit_inner_r = outer_r; // socket ID matches pipe OD

  // Ensure overlap is sane
  ov = min(overlap_mm, min(length_mm, fitting_length_mm)/2);

  color([0.85, 0.85, 0.8])  // PVC color
  union() {
    // Main pipe (hollow)
    difference() {
      cylinder(h=length_mm, r=outer_r, center=false);
      translate([0, 0, -ov])
        cylinder(h=length_mm + 2*ov, r=inner_r, center=false);
    }

    // End fitting (socket) connected to pipe with calculated overlap
    if (include_end_fitting) {
      translate([0, 0, length_mm - ov])  // overlaps into pipe by ov
      difference() {
        cylinder(h=fitting_length_mm + ov, r=fit_outer_r, center=false);
        translate([0, 0, -ov])
          cylinder(h=fitting_length_mm + 2*ov, r=fit_inner_r, center=false);
      }
    }
  }
}

// Assembly
ht_pipe();