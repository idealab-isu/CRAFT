// Parameters
nominal_size = 75; //[40:160:1]
length_mm = 1500; //[750:3000:10]
include_end_fitting = 1; //[0:1:1]
od_mm = 75; //[40:160:1]
wall_mm = 2.7; //[1.5:6:0.1]
fit_len_mm = 55; //[25:120:1]
fit_od_extra_mm = 6; //[2:15:0.5]
fit_socket_wall_extra_mm = 1.5; //[0.5:4:0.1]
fit_stop_ring_len_mm = 6; //[2:15:0.5]
fit_stop_ring_extra_mm = 2; //[0.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Module for the hollow tube
module hollow_tube() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer tube
      cylinder(r=od_mm/2, h=length_mm, center=false);
      // Inner void
      translate([0, 0, -overlap_mm])
        cylinder(r=od_mm/2 - wall_mm, h=length_mm + 2*overlap_mm, center=false);
    }
  }
}

// Module for the end fitting
module end_fitting() {
  if (include_end_fitting) {
    color([0.85, 0.85, 0.8]) {
      union() {
        difference() {
          // Outer fitting
          translate([0, 0, length_mm - overlap_mm])
            cylinder(r=od_mm/2 + fit_od_extra_mm/2, h=fit_len_mm, center=false);
          // Inner void
          translate([0, 0, length_mm - 2*overlap_mm])
            cylinder(r=od_mm/2 - wall_mm - fit_socket_wall_extra_mm, h=fit_len_mm + 2*overlap_mm, center=false);
        }
        // Stop ring
        translate([0, 0, length_mm + fit_len_mm - fit_stop_ring_len_mm - overlap_mm])
          cylinder(r=od_mm/2 + fit_od_extra_mm/2 + fit_stop_ring_extra_mm, h=fit_stop_ring_len_mm, center=false);
      }
    }
  }
}

// Module for the complete HT pipe
module ht_pipe() {
  union() {
    hollow_tube();
    end_fitting();
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();