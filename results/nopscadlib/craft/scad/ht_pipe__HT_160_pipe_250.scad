$fn = 180;

// Parameters
pipe_standard = 1; //[1:1:1]
nominal_diameter_mm = 160; //[80:320:1]
length_mm = 250; //[125:500:1]
wall_thickness_mm = 4.7; //[2.35:9.4:0.1]
include_end_fitting = 1; //[0:1:1]
fit_socket_length_mm = 55; //[30:110:1]
fit_socket_wall_extra_mm = 3; //[1.5:6:0.5]
fit_stop_ring_thickness_mm = 3; //[1.5:6:0.5]
fit_stop_ring_radial_extra_mm = 2; //[1:5:0.5]
fit_socket_clearance_mm = 1; //[0.5:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// HT Pipe - ONE connected solid
module ht_pipe() {
  r_outer = nominal_diameter_mm/2;
  r_inner = r_outer - wall_thickness_mm;

  socket_h = include_end_fitting ? fit_socket_length_mm : 0;
  socket_r_outer = r_outer + fit_socket_wall_extra_mm;
  socket_r_inner = r_outer + fit_socket_clearance_mm;

  ring_h = include_end_fitting ? fit_stop_ring_thickness_mm : 0;
  ring_r_outer = socket_r_outer + fit_stop_ring_radial_extra_mm;

  total_h = length_mm + socket_h + ring_h;

  // Safety: avoid invalid/empty geometry
  eps = 0.01;
  r_inner_ok = max(eps, r_inner);
  socket_r_inner_ok = max(eps, socket_r_inner);

  color([0.85, 0.85, 0.8])
  difference() {
    // OUTER: connected by construction (overlaps)
    union() {
      cylinder(h=length_mm, r=r_outer, center=false);

      if (include_end_fitting) {
        translate([0, 0, length_mm - overlap_mm])
          cylinder(h=socket_h + overlap_mm, r=socket_r_outer, center=false);

        translate([0, 0, length_mm + socket_h - overlap_mm])
          cylinder(h=ring_h + overlap_mm, r=ring_r_outer, center=false);
      }
    }

    // INNER: continuous bore through entire part
    translate([0, 0, -overlap_mm])
      cylinder(h=total_h + 2*overlap_mm, r=r_inner_ok, center=false);

    // Socket clearance bore (only in socket+ring region)
    if (include_end_fitting) {
      translate([0, 0, length_mm - overlap_mm])
        cylinder(h=socket_h + ring_h + 2*overlap_mm, r=socket_r_inner_ok, center=false);
    }
  }
}

ht_pipe();