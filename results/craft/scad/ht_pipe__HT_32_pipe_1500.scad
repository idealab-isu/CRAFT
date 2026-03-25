// HT 32 pipe 1500 mm (single connected solid, oriented along X for reliable orthographic views)

$fn = 128;

// Parameters
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]

pipe_od_mm = 32; //[16:64:1]
pipe_wall_mm = 2.4; //[1.2:4.8:0.1]

fit_overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 35; //[18:70:1]
fitting_od_mm = 35.2; //[17.6:70.4:0.1]

// Derived
pipe_r = pipe_od_mm/2;
pipe_ir = max(0.01, pipe_r - pipe_wall_mm);

fitting_r = fitting_od_mm/2;
fitting_ir = pipe_ir;

// Small overlap to guarantee manifold union between parts
join_eps = max(0.2, fit_overlap_mm);

module hollow_cyl(h, r_outer, r_inner) {
  difference() {
    cylinder(h=h, r=r_outer, center=true);
    cylinder(h=h + 2*join_eps, r=r_inner, center=true);
  }
}

module ht_pipe() {
  color([0.85, 0.85, 0.8])
  rotate([0, 90, 0])  // orient pipe along X so front/back/left/right views are not degenerate
  union() {
    // Main pipe (centered)
    hollow_cyl(length_mm, pipe_r, pipe_ir);

    // End fitting at +X end (after rotation), connected with calculated overlap
    if (include_end_fitting) {
      translate([0, 0, length_mm/2 + fitting_length_mm/2 - join_eps])
        hollow_cyl(fitting_length_mm, fitting_r, fitting_ir);
    }
  }
}

ht_pipe();