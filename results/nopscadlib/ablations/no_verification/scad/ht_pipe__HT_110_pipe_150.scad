$fn = 128;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 150; //[75:300:1]
outer_diameter_mm = 110; //[55:220:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 35; //[18:70:1]
fitting_wall_extra_mm = 2.5; //[1.0:6.0:0.1]
fitting_inner_clearance_mm = 0.6; //[0.2:1.5:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Derived radii
pipe_r_o = outer_diameter_mm/2;
pipe_r_i = pipe_r_o - wall_thickness_mm;

fitting_r_o = pipe_r_o + fitting_wall_extra_mm;
fitting_r_i = pipe_r_o + fitting_inner_clearance_mm;

// Placement (centered model, fitting on +Z end)
fitting_z = (length_mm/2) + (fitting_length_mm/2) - overlap_mm;

module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: one connected solid (overlapped union)
    union() {
      cylinder(h=length_mm, r=pipe_r_o, center=true);

      if (include_end_fitting)
        translate([0, 0, fitting_z])
          cylinder(h=fitting_length_mm, r=fitting_r_o, center=true);
    }

    // INNER: subtract bores (extended to avoid coplanar artifacts)
    union() {
      cylinder(h=length_mm + 2*overlap_mm, r=pipe_r_i, center=true);

      if (include_end_fitting)
        translate([0, 0, fitting_z])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=fitting_r_i, center=true);
    }
  }
}

ht_pipe();