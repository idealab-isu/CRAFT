$fn = 128;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 32; //[16:64:1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
pipe_od_mm = 32; //[16:64:1]
pipe_wall_mm = 1.8; //[0.9:3.6:0.1]
overlap_mm = 1; //[0.5:2:0.1]
fitting_length_mm = 45; //[20:90:1]
fitting_od_extra_mm = 6; //[2:12:0.5]
fitting_wall_extra_mm = 1.2; //[0.5:3:0.1]

// Derived (robustness)
pipe_or = pipe_od_mm/2;
pipe_ir = max(0.01, pipe_or - pipe_wall_mm);

fitting_or = pipe_or + fitting_od_extra_mm/2;
fitting_ir = max(0.01, fitting_or - (pipe_wall_mm + fitting_wall_extra_mm));

// Ensure valid, visible wall thickness everywhere
min_wall = 0.2;
pipe_ir = min(pipe_ir, pipe_or - min_wall);
fitting_ir = min(fitting_ir, fitting_or - min_wall);

// HT Pipe - complete geometry (ONE connected solid)
module ht_pipe() {
  difference() {
    // OUTER solid (connected via overlap)
    union() {
      cylinder(h=length_mm, r=pipe_or, center=false);

      if (include_end_fitting)
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=fitting_length_mm, r=fitting_or, center=false);
    }

    // INNER void (continuous subtraction, extended for clean booleans)
    union() {
      // Main pipe inner
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=pipe_ir, center=false);

      // Fitting inner
      if (include_end_fitting)
        translate([0, 0, (length_mm - overlap_mm) - overlap_mm])
          cylinder(h=fitting_length_mm + 2*overlap_mm, r=fitting_ir, center=false);
    }
  }
}

// Assembly
ht_pipe();