// Parameters
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 1500; //[750:3000:1]
pipe_wall_thickness = 4; //[2:8:0.5]
end_fitting_length = 60; //[30:120:1]
end_fitting_radial_add = 6; //[3:12:0.5]
end_fitting_overlap = 1; //[0.5:2:0.5]
inner_void_extra_height = 2; //[1:5:0.5]

$fn = 128;

module ht_pipe() {
  outer_r = nominal_diameter_mm/2;
  inner_r = outer_r - pipe_wall_thickness;

  // Safety to avoid invalid/empty geometry
  inner_r_safe = max(0.01, inner_r);
  overlap_safe = max(0.01, end_fitting_overlap);
  extra_h = max(0.01, inner_void_extra_height);

  // Socket starts so it overlaps into the main pipe by overlap_safe
  fitting_z0 = length_mm - end_fitting_length - overlap_safe;

  // Keep socket within the pipe length (still overlapping)
  fitting_z0_clamped = min(max(0, fitting_z0), length_mm - overlap_safe);

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER SOLID: main OD + socket OD, connected via overlap
    union() {
      cylinder(h=length_mm, r=outer_r, center=false);

      translate([0, 0, fitting_z0_clamped])
        cylinder(h=end_fitting_length + overlap_safe, r=outer_r + end_fitting_radial_add, center=false);
    }

    // INNER VOID: continuous through entire length, extended to avoid coplanar artifacts
    translate([0, 0, -extra_h])
      cylinder(h=length_mm + 2*extra_h, r=inner_r_safe, center=false);
  }
}

ht_pipe();