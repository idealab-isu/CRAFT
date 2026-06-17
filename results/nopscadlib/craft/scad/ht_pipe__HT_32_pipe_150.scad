// HT 32 pipe 150 mm (single connected solid)

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size_mm = 32; //[16:64:1]
length_mm = 150; //[75:300:1]
od_mm = 32; //[16:64:0.5]
wall_mm = 2.4; //[1.2:4.8:0.1]
bore_d_mm = 27.2; //[13.6:54.4:0.1]
include_end_fitting = 1; //[0:1:1]
fitting_length_mm = 25; //[12.5:50:0.5]
fitting_od_extra_mm = 6; //[3:12:0.5]
fitting_wall_extra_mm = 1.2; //[0.6:2.4:0.1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  // Derived radii (prefer bore_d_mm if provided; otherwise compute from wall)
  od_r = od_mm/2;
  bore_r_from_wall = max(0.01, od_r - wall_mm);
  bore_r = (bore_d_mm > 0) ? max(0.01, bore_d_mm/2) : bore_r_from_wall;

  fitting_od_r = (od_mm + fitting_od_extra_mm)/2;

  // Fitting inner radius: keep it <= main bore so the collar doesn't create an internal "step" that can
  // cause coincident/degenerate surfaces; also keep it > 0.
  fitting_bore_r_raw = bore_r - fitting_wall_extra_mm;
  fitting_bore_r = max(0.01, min(bore_r, fitting_bore_r_raw));

  // Place collar at the +Z end, overlapping into the main pipe by overlap_mm (guarantees connectivity)
  collar_center_z = (length_mm/2) - (fitting_length_mm/2) + overlap_mm;

  color([0.85, 0.85, 0.8])
  union() {
    // Main pipe (hollow)
    difference() {
      cylinder(h=length_mm, r=od_r, center=true);
      cylinder(h=length_mm + 2*overlap_mm, r=bore_r, center=true);
    }

    // End fitting collar (hollow), connected via overlap into main pipe
    if (include_end_fitting) {
      translate([0, 0, collar_center_z])
      difference() {
        cylinder(h=fitting_length_mm, r=fitting_od_r, center=true);
        cylinder(h=fitting_length_mm + 2*overlap_mm, r=fitting_bore_r, center=true);
      }
    }
  }
}

// Assembly
ht_pipe();