// HT 160 pipe 1000 mm (single connected solid)

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 1000; //[500:2000:1]
include_fitting = 1; //[0:1:1]
fitting_end = 1; //[1:1:1]
pipe_od_mm = 160; //[80:320:1]
pipe_wall_mm = 4.9; //[2.5:10:0.1]
fitting_length_mm = 90; //[45:180:1]
fitting_od_extra_mm = 10; //[5:20:1]
overlap_mm = 1; //[0.5:2:0.1]
pipe_body_length_mm = 910; //[410:1910:1]

$fn = 128;

// Derived
pipe_r  = pipe_od_mm/2;
pipe_ir = max(0.01, pipe_r - pipe_wall_mm);
fitting_r = pipe_r + fitting_od_extra_mm/2;

// Lengths (ensure total equals length_mm)
body_len  = (include_fitting ? max(0.01, length_mm - fitting_length_mm + overlap_mm) : length_mm);
total_len = (include_fitting ? body_len + fitting_length_mm - overlap_mm : body_len);

// HT Pipe - one connected solid
module ht_pipe() {
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER solid (body + optional fitting, overlapped for guaranteed connectivity)
    union() {
      cylinder(h=body_len, r=pipe_r, center=false);

      if (include_fitting) {
        translate([0, 0, body_len - overlap_mm])
          cylinder(h=fitting_length_mm, r=fitting_r, center=false);
      }
    }

    // INNER void (open through both ends; no arbitrary offsets)
    translate([0, 0, -0.01])
      cylinder(h=total_len + 0.02, r=pipe_ir, center=false);
  }
}

ht_pipe();