// Parameters
nominal_diameter_mm = 110; //[55:220:1]
length_mm = 500; //[250:1000:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
fitting_length_mm = 60; //[30:120:1]
fitting_radial_thickness_mm = 4; //[2:10:0.5]
fitting_inner_clearance_mm = 1; //[0.2:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
  od_r = nominal_diameter_mm/2;
  id_r = od_r - wall_thickness_mm;

  // Socket (outer sleeve) radii
  fit_od_r = od_r + fitting_radial_thickness_mm;
  fit_id_r = od_r + fitting_inner_clearance_mm;

  // Safety clamps to avoid invalid/empty geometry
  id_r_safe     = max(0.01, id_r);
  fit_id_r_safe = max(0.01, fit_id_r);

  // Ensure the socket cavity is not larger than the socket outer radius
  fit_id_r_clamped = min(fit_id_r_safe, fit_od_r - 0.01);

  // Ensure the socket cavity is not smaller than the main OD (otherwise no socket clearance)
  fit_id_r_final = max(fit_id_r_clamped, od_r + 0.01);

  // Place socket at the BOTTOM end (z=0) so it is visible in typical views
  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER solid: pipe + socket, connected (overlap by overlap_mm)
    union() {
      cylinder(h=length_mm, r=od_r, center=false);

      translate([0, 0, 0])
        cylinder(h=fitting_length_mm + overlap_mm, r=fit_od_r, center=false);
    }

    // INNER voids: main bore + socket cavity, with overlaps to avoid coincident faces
    union() {
      // Main bore through entire length
      translate([0, 0, -overlap_mm])
        cylinder(h=length_mm + 2*overlap_mm, r=id_r_safe, center=false);

      // Socket cavity from bottom end upward
      translate([0, 0, -overlap_mm])
        cylinder(h=fitting_length_mm + 2*overlap_mm, r=fit_id_r_final, center=false);
    }
  }
}

ht_pipe();